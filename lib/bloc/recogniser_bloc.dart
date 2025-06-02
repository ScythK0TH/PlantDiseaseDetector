import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_pdd/bloc/recogniser_event.dart';
import 'package:project_pdd/bloc/recogniser_state.dart';
import 'package:project_pdd/classifier/classifier.dart';
import 'package:project_pdd/classifier/image_processing_helper.dart';

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
      final processed = await compute(processImage, event.image.path)
          .timeout(const Duration(seconds: 7));

      if (processed == null) {
        emit(state.copyWith(status: RecogniserStatus.notSupportedFormat));
        return;
      }

      final result = _classifier.predict(processed);

      emit(state.copyWith(
        status: RecogniserStatus.found,
        pid: result.pid,
        label: result.label,
        accuracy: result.score,
      ));
    } on TimeoutException {
      emit(state.copyWith(status: RecogniserStatus.timeout));
    } catch (_) {
      emit(state.copyWith(status: RecogniserStatus.notFound));
    }
  }
}
