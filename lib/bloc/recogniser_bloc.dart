import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_pdd/bloc/recogniser_event.dart';
import 'package:project_pdd/bloc/recogniser_state.dart';
import 'package:project_pdd/classifier/classifier.dart';

const _labelsFileName = 'labels.txt';
const _modelFileName = 'assets/my_model/plantVillage_model.tflite';

class RecogniserBloc extends Bloc<RecogniserEvent, RecogniserState> {
  late final Classifier _classifier;

  RecogniserBloc() : super(const RecogniserState()) {
    on<RecogniserStarted>(_onStarted);
    on<RecogniserReset>((event, emit) {
      emit(const RecogniserState());
    });
    on<PhotoPicked>(_onPhotoPicked);
  }

  Future<void> _onStarted(RecogniserStarted event, Emitter emit) async {
    _classifier = (await Classifier.loadWith(
        labelsFileName: _labelsFileName, modelFileName: _modelFileName))!;
  }

  Future<void> _onPhotoPicked(PhotoPicked event, Emitter emit) async {
    emit(
        state.copyWith(status: RecogniserStatus.analyzing, image: event.image));

    try {
      final image = await compute(_decodeImageFromPath, event.image.path)
          .timeout(const Duration(seconds: 7));

      if (image == null) {
        emit(state.copyWith(status: RecogniserStatus.notSupportedFormat));
        return;
      }

      final results = _classifier.predict(image);

      emit(state.copyWith(
        status: RecogniserStatus.found,
        pid: results.first.pid,
        label: results.first.label,
        accuracy: results.first.score,
        results: results,
      ));
    } on TimeoutException {
      emit(state.copyWith(status: RecogniserStatus.timeout));
    } catch (_) {
      emit(state.copyWith(status: RecogniserStatus.notFound));
    }
  }
}

img.Image? _decodeImageFromPath(String path) {
  final bytes = File(path).readAsBytesSync();
  return img.decodeImage(bytes);
}
