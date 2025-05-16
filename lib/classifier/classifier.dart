import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:project_pdd/classifier/classifier_category.dart';
import 'package:project_pdd/classifier/classifier_model.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

typedef ClassifierLabel = List<String>;

class Classifier {
  final ClassifierModel _model;
  final ClassifierLabel _labels;

  Classifier._({
    required ClassifierModel model,
    required ClassifierLabel labels,
  })  : _model = model,
        _labels = labels;

  static Future<Classifier?> loadWith({
    required String labelsFileName,
    required String modelFileName,
  }) async {
    try {
      final model = await _loadModel(modelFileName);
      final labels = await _loadLabels(labelsFileName);
      return Classifier._(model: model, labels: labels);
    } catch (e) {
      debugPrint('Can not be initialize Classifier: ${e.toString()}');
      if (e is Error) {
        debugPrintStack(stackTrace: e.stackTrace);
      }
      return null;
    }
  }

  static Future<ClassifierModel> _loadModel(String modelFileName) async {
    final interpreter = await Interpreter.fromAsset(modelFileName);

    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;
    final inputType = interpreter.getInputTensor(0).type;
    final outputType = interpreter.getOutputTensor(0).type;

    debugPrint('Model loaded: $modelFileName');
    debugPrint('Input shape: $inputShape');
    debugPrint('Output shape: $outputShape');
    debugPrint('Input type: $inputType');
    debugPrint('Output type: $outputType');

    return ClassifierModel(
      interpreter: interpreter,
      inputShape: inputShape,
      outputShape: outputShape,
      inputType: inputType,
      outputType: outputType,
    );
  }

  static Future<ClassifierLabel> _loadLabels(String labelsFileName) async {
    final labelData =
        await rootBundle.loadString('assets/my_model/$labelsFileName');

    final labels = labelData
        .split('\n')
        .where((line) => line.isNotEmpty)
        .map((label) => label.substring(label.indexOf(' ')).trim())
        .toList();

    debugPrint('Labels: $labels');
    return labels;
  }

  void close() {
    _model.interpreter.close();
  }

  ClassifierCategory predict(img.Image image) {
    debugPrint('Predicting...');
    debugPrint(
      'Image: ${image.width}x${image.height}, '
      'size: ${image.length} bytes',
    );

    final inputImage = _preProcessInput(image);
    final reshapeImage = _reshapeInput(inputImage);

    debugPrint(
      'Pre-processed image: ${_model.inputShape} '
      'size: ${inputImage.lengthInBytes} bytes',
    );

    final output = List.filled(
      _model.outputShape.reduce((a, b) => a * b),
      0.0,
    ).reshape(_model.outputShape);

    _model.interpreter.run(reshapeImage, output);

    debugPrint('Output: ${output[0]}');

    final resultCategories = _postProcessOutput(output[0]);
    final topResult = resultCategories.first;

    debugPrint('Top category: $topResult');

    return topResult;
  }

  Float32List _preProcessInput(img.Image image) {
    // 1. ครอปภาพตรงกลางให้เป็นสี่เหลี่ยมจัตุรัส
    final minLength = min(image.width, image.height);
    final xOffset = ((image.width - minLength) / 2).round();
    final yOffset = ((image.height - minLength) / 2).round();

    final cropped = img.copyCrop(
      image,
      x: xOffset,
      y: yOffset,
      width: minLength,
      height: minLength,
    );

    // 2. Resize ภาพให้ตรงกับ inputShape ของโมเดล
    final inputSize = _model.inputShape[1];
    final resized =
        img.copyResize(cropped, width: inputSize, height: inputSize);

    // 3. แปลง pixel เป็น Float32List
    final Float32List input = Float32List(inputSize * inputSize * 3);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);

        input[pixelIndex++] = pixel.r.toDouble();
        input[pixelIndex++] = pixel.g.toDouble();
        input[pixelIndex++] = pixel.b.toDouble();
      }
    }
    return input;
  }

  List<ClassifierCategory> _postProcessOutput(List<double> output) {
    final categoryList = <ClassifierCategory>[];

    for (int i = 0; i < _labels.length; i++) {
      final label = _labels[i];
      final confidence = output[i];

      categoryList.add(ClassifierCategory(label, confidence, i));
      debugPrint('id: $i, label: $label, score: $confidence');
    }

    categoryList.sort((a, b) => b.score.compareTo(a.score));
    return categoryList;
  }

  List<List<List<List<double>>>> _reshapeInput(Float32List input) {
    int inputSize = _model.inputShape[1];
    return List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) => List.generate(
            3,
            (c) => input[(y * inputSize + x) * 3 + c],
          ),
        ),
      ),
    );
  }
}
