import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:project_pdd/classifier/classifier.dart';
import 'package:project_pdd/style.dart';
import 'package:project_pdd/widget/photo_view.dart';

const _labelsFileName = 'labels.txt';
const _modelFileName = 'assets/my_model/plantVillage_model.tflite';

class Recogniser extends StatefulWidget {
  const Recogniser({super.key});

  @override
  State<Recogniser> createState() => _RecogniserState();
}

enum _ResultStatus { notStarted, notFound, found }

class _RecogniserState extends State<Recogniser> {
  bool _isAnalyzing = false;
  final picker = ImagePicker();
  File? _selectedImageFile;

  _ResultStatus _resultStatus = _ResultStatus.notStarted;
  String _plantLabel = '';
  double _accuracy = 0.0;

  late Classifier _classifier;

  @override
  void initState() {
    super.initState();
    _loadClassifier();
  }

  Future<void> _loadClassifier() async {
    debugPrint(
      'Start loading of Classifier with '
      'labels at $_labelsFileName, '
      'model at $_modelFileName',
    );

    final classifier = await Classifier.loadWith(
      labelsFileName: _labelsFileName,
      modelFileName: _modelFileName,
    );
    _classifier = classifier!;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close, color: bgColor),
            iconSize: 36.0,
          ),
          title: Text('Plant Hub',
              style: subTitleTextStyleWhite(fontWeight: FontWeight.bold)),
          centerTitle: true,
          toolbarHeight: screenHeight * 0.075),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            _buildPhotolView(),
            SizedBox(
              height: 20.0,
            ),
            _buildResultView(),
            const Spacer(flex: 2),
            _buildPickPhotoButton(
              title: 'Take a photo',
              width: screenWidth * 0.55,
              source: ImageSource.camera,
              isOutlined: false,
            ),
            SizedBox(
              height: 20.0,
            ),
            _buildPickPhotoButton(
              title: 'Pick from gallery',
              width: screenWidth * 0.55,
              source: ImageSource.gallery,
              isOutlined: true,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotolView() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        PhotoViewScreen(
          file: _selectedImageFile,
        ),
        _buildAnalyzingText(),
      ],
    );
  }

  Widget _buildAnalyzingText() {
    if (!_isAnalyzing) {
      return const SizedBox.shrink();
    }
    return Text('Analyzing...',
        style: subTitleTextStyleDark(fontWeight: FontWeight.normal));
  }

  Widget _buildPickPhotoButton({
    required ImageSource source,
    required String title,
    double width = 300.0,
    double height = 70.0,
    bool isOutlined = false,
  }) {
    return ElevatedButton(
      onPressed: () => _onPickPhoto(source),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36.0),
          side: isOutlined
              ? BorderSide(color: primaryColor, width: 3.0)
              : BorderSide.none,
        ),
        minimumSize: Size(width, height),
        elevation: isOutlined ? 0 : null,
      ),
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        child: Text(
          title,
          style: isOutlined
              ? descTextStyleDark(fontWeight: FontWeight.normal)
              : descTextStyleWhite(fontWeight: FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    var title = '';

    if (_resultStatus == _ResultStatus.notFound) {
      title = 'Fail to recognise';
    } else if (_resultStatus == _ResultStatus.found) {
      title = _plantLabel;
    } else {
      title = '';
    }

    var accuracyLabel = '';
    if (_resultStatus == _ResultStatus.found) {
      accuracyLabel = 'Accuracy: ${(_accuracy * 100).toStringAsFixed(2)}%';
    }

    return Column(
      children: [
        Text(title, style: subTitleTextStyleDark(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text(accuracyLabel,
            style: successTextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _setAnalyzing(bool flag) {
    setState(() {
      _isAnalyzing = flag;
    });
  }

  void _onPickPhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      return;
    }

    final imageFile = File(pickedFile.path);
    setState(() {
      _selectedImageFile = imageFile;
    });

    _analyzeImage(imageFile);
  }

  void _analyzeImage(File image) {
    _setAnalyzing(true);

    final imageInput = img.decodeImage(image.readAsBytesSync())!;

    final resultCategory = _classifier.predict(imageInput);

    final result = resultCategory.score >= 0.8
        ? _ResultStatus.found
        : _ResultStatus.notFound;
    final plantLabel = resultCategory.label;
    final accuracy = resultCategory.score;

    _setAnalyzing(false);

    setState(() {
      _resultStatus = result;
      _plantLabel = plantLabel;
      _accuracy = accuracy;
    });
  }
}
