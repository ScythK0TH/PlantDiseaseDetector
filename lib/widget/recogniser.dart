import 'dart:io';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/constant.dart';
import 'package:project_pdd/bloc/recogniser_bloc.dart';
import 'package:project_pdd/bloc/recogniser_event.dart';
import 'package:project_pdd/bloc/recogniser_state.dart';
import 'package:project_pdd/home.dart';
import 'package:project_pdd/style.dart';
import 'package:project_pdd/widget/photo_view.dart';
import 'package:project_pdd/widget/profile_page.dart';
import 'package:project_pdd/widget/storage_page.dart';

class Recogniser extends StatefulWidget {
  final String userId; // Pass the logged-in user's _id
  const Recogniser({required this.userId, super.key});

  @override
  State<Recogniser> createState() => _RecogniserState();
}

class _RecogniserState extends State<Recogniser> {
  bool isPressing = false;
  bool isResultButtonPressing = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (_) => RecogniserBloc()..add(RecogniserStarted()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Plant Analyzer'.tr(),
                      style: subTitleTextStyleDark(context, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<RecogniserBloc, RecogniserState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    PhotoViewScreen(file: state.image),
                    const SizedBox(height: 50),
                    SizedBox(
                      height: 150,
                      child: SingleChildScrollView(
                          child: _buildResultView(state, context)),
                    ),
                    const SizedBox(height: 20),
                    if (state.status != RecogniserStatus.analyzing) ...[
                      if (state.status == RecogniserStatus.found) ...[
                      _buildResultButton(context, 'Save Result'.tr(),
                        screenWidth, false, 'save', state),
                      const SizedBox(height: 20),
                      _buildResultButton(context, 'Cancel'.tr(),
                        screenWidth, true, 'cancel', state),
                      const SizedBox(height: 20),
                      ] else ...[
                        _buildPickButton(context, 'Take a photo'.tr(),
                          ImageSource.camera, screenWidth, false, 'photo'),
                        const SizedBox(height: 20),
                        _buildPickButton(context, 'Pick from gallery'.tr(),
                            ImageSource.gallery, screenWidth, true, 'gallery'),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ElevatedButton SaveButton() => ElevatedButton(onPressed: onPressed, child: child);

  Widget _buildResultView(RecogniserState state, BuildContext context) {
    if (state.status == RecogniserStatus.analyzing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF151C21),
            strokeWidth: 3,
          ),
          const SizedBox(height: 12),
          Text(
            'Analyzing...'.tr(),
            style: subTitleTextStyleDark(context, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    if (state.status == RecogniserStatus.initial) {
      return const SizedBox();
    }

    final label = switch (state.status) {
      RecogniserStatus.found => state.label,
      RecogniserStatus.timeout => 'Please try again.',
      _ => 'Fail to recognise',
    };

    final accuracy = state.status == RecogniserStatus.found
        ? 'Probability:'.tr() + ' ${(state.accuracy * 100).toStringAsFixed(2)}%'
        : '';

    List<String> splitText(String text, TextStyle style, double maxWidth) {
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1000,
        textDirection: Directionality.of(context),
      )..layout(maxWidth: maxWidth);

      final words = text.split(' ');
      List<String> lines = [];
      String currentLine = '';

      for (var word in words) {
        final tempLine = '$currentLine$word ';
        textPainter.text = TextSpan(text: tempLine, style: style);
        textPainter.layout(maxWidth: maxWidth);

        if (textPainter.didExceedMaxLines) {
          lines.add(currentLine.trim());
          currentLine = '$word ';
        } else {
          currentLine = tempLine;
        }
      }

      if (currentLine.isNotEmpty) {
        lines.add(currentLine.trim());
      }

      return lines;
    }

    final maxWidth = MediaQuery.of(context).size.width * 0.8;

    List<String> labelLines = splitText(
        label, subTitleTextStyleDark(context, fontWeight: FontWeight.bold), maxWidth);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var line in labelLines)
          Text(
            line.tr(),
            style: subTitleTextStyleDark(context, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 12),
        if (accuracy.isNotEmpty)
          Text(
            accuracy,
            style: successTextStyle(fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget _buildPickButton(BuildContext context, String title,
      ImageSource source, double width, bool isOutlined, String type) {
    IconData icon = type == 'photo' ? Icons.camera_alt : Icons.photo_library;

    return ElevatedButton(
      onPressed: isPressing
          ? null
          : () async {
              setState(() => isPressing = true);
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(
                source: source,
              );
              if (pickedFile != null) {
                context
                    .read<RecogniserBloc>()
                    .add(PhotoPicked(File(pickedFile.path)));
              }
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) setState(() => isPressing = false);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined
            ? Colors.transparent
            : (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36.0),
          side: isOutlined
              ? BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : primaryColor,
                  width: 3.0)
              : BorderSide.none,
        ),
        minimumSize: Size(width, 60.0),
        elevation: isOutlined ? 0 : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isOutlined
                ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : primaryColor)
                : (Theme.of(context).brightness == Brightness.dark
                    ? primaryColor
                    : Colors.white),
            size: 24.0,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: isOutlined
                ? descTextStyleDark(context, fontWeight: FontWeight.normal)
                : descTextStyleWhite(context, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildResultButton(BuildContext context, String title,
    double width, bool isOutlined, String type, RecogniserState state) {

    return ElevatedButton(
      onPressed: isResultButtonPressing
          ? null
          : () async {
              setState(() => isResultButtonPressing = true);
              if (type == 'save') {
                await _savedData(context, state, widget.userId);
              } else if (type == 'cancel') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(userId: widget.userId, initialIndex: 0),
                  ),
                );
              }
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) setState(() => isResultButtonPressing = false);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined
            ? Colors.transparent
            : (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36.0),
          side: isOutlined
              ? BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : primaryColor,
                  width: 3.0)
              : BorderSide.none,
        ),
        minimumSize: Size(width, 60.0),
        elevation: isOutlined ? 0 : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          Text(
            title,
            style: isOutlined
                ? descTextStyleDark(context, fontWeight: FontWeight.normal)
                : descTextStyleWhite(context, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

Future<String> cropAndResizeToContainer(File file, double containerWidth, double containerHeight) async {
  final originalBytes = await file.readAsBytes();
  final image = img.decodeImage(originalBytes);
  if (image == null) throw Exception('Failed to decode image');

  // Calculate aspect ratio of the container
  final containerAspect = containerWidth / containerHeight;
  final imageAspect = image.width / image.height;

  int cropWidth, cropHeight, offsetX, offsetY;

  if (imageAspect > containerAspect) {
    // Image is wider than container: crop width
    cropHeight = image.height;
    cropWidth = (cropHeight * containerAspect).toInt();
    offsetX = ((image.width - cropWidth) / 2).toInt();
    offsetY = 0;
  } else {
    // Image is taller than container: crop height
    cropWidth = image.width;
    cropHeight = (cropWidth / containerAspect).toInt();
    offsetX = 0;
    offsetY = ((image.height - cropHeight) / 2).toInt();
  }

  final cropped = img.copyCrop(image, x: offsetX, y: offsetY, width: cropWidth, height: cropHeight);

  // Resize to container size (optional, or set a fixed size)
  final resized = img.copyResize(cropped, width: containerWidth.toInt(), height: containerHeight.toInt());

  return base64Encode(img.encodeJpg(resized, quality: 80));
}

Future<void> _savedData(BuildContext context, RecogniserState state, String userId) async {
    if (userId.isEmpty) {
      print('Error: userId is empty.');
      return;
    }

    mongo.ObjectId mongoUserId;
    try {
      mongoUserId = mongo.ObjectId.fromHexString(userId); // Convert userId to ObjectId
    } catch (e) {
      print('Error: Invalid userId format. ' + e.toString());
      return;
    }
    final predict = state.label;
    final image = state.image != null ? await cropAndResizeToContainer(state.image!, 350, 300) : null;
    String title = state.image != null ? state.image!.path.split('/').last : 'Unknown';
    if (title.length > 15) {
      title = title.substring(title.length - 15);
    }
    final accuracy = state.accuracy;
    final dateTime = DateTime.now().toString();
    final pid = state.pid;

    try {
      print('Connecting to MongoDB...');
      final db = await mongo.Db.create(MONGO_URL);
      await db.open();
      print('Connected to MongoDB.');

      final collection = db.collection('plants');
      if (image != null) {
        await collection.insert({
          'userId': mongoUserId,
          'image': image,
          'date': dateTime,
          'predict_id': pid,
          'predict': predict,
          'title': title,
          'probability': accuracy,
        });
      } else {
        print('Error: Image is null.');
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomePage(userId: userId),
        ),
      );
      await db.close();
    } catch (e) {
      print('Error: $e');
    }
  }