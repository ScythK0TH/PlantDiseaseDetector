import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_pdd/bloc/recogniser_event.dart';
import 'package:project_pdd/bloc/recogniser_state.dart';
import 'package:project_pdd/classifier/classifier.dart';

final List<Map<String, String>> modelConfigs = [
  {
    'model': 'assets/my_model/mbnv3_plant_modify.tflite',
    'labels': 'labels.txt',
    'display': 'MobileNetV3 Small',
    'desc': 'Minimalistic Modify'
  },
  {
    'model': 'assets/my_model/mbnv3_plant_original.tflite',
    'labels': 'labels.txt',
    'display': 'MobileNetV3 Small',
    'desc': 'Minimalistic Original'
  },
];

class RecogniserBloc extends Bloc<RecogniserEvent, RecogniserState> {
  Classifier? _classifier;

  RecogniserBloc() : super(const RecogniserState()) {
    on<RecogniserStarted>(_onStarted);
    on<ModelChanged>(_onModelChanged);
    on<RecogniserReset>((event, emit) {
      emit(RecogniserState(
        selectedModelIndex: state.selectedModelIndex,
      ));
    });
    on<PhotoPicked>(_onPhotoPicked);
  }

  Future<void> _onStarted(RecogniserStarted event, Emitter emit) async {
    final config = modelConfigs[state.selectedModelIndex];
    _classifier = await Classifier.loadWith(
      labelsFileName: config['labels']!,
      modelFileName: config['model']!,
    );
  }

  Future<void> _onModelChanged(ModelChanged event, Emitter emit) async {
    final config = modelConfigs[event.modelIndex];
    _classifier = await Classifier.loadWith(
      labelsFileName: config['labels']!,
      modelFileName: config['model']!,
    );
    emit(state.copyWith(selectedModelIndex: event.modelIndex));
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

      final results = _classifier!.predict(image); // เติม ! ตรงนี้

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
