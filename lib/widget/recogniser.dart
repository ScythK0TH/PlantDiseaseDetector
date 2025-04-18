import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_pdd/bloc/recogniser_bloc.dart';
import 'package:project_pdd/bloc/recogniser_event.dart';
import 'package:project_pdd/bloc/recogniser_state.dart';
import 'package:project_pdd/style.dart';
import 'package:project_pdd/widget/photo_view.dart';

class Recogniser extends StatelessWidget {
  const Recogniser({super.key});

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
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_circle_left_rounded,
                        color: primaryColor,
                        size: 24.0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Center(
                    child: Text(
                      'Plant Hub',
                      style: subTitleTextStyleDark(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.flag,
                        color: primaryColor,
                        size: 24.0,
                      ),
                      onPressed: () {
                        // Do something
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true, // ไม่จำเป็นมากเพราะจัดตำแหน่งเองแล้ว
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
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 150,
                      child: SingleChildScrollView(
                          child: _buildResultView(state, context)),
                    ),
                    const SizedBox(height: 40),
                    _buildPickButton(context, 'Take a photo',
                        ImageSource.camera, screenWidth, false, 'photo'),
                    const SizedBox(height: 20),
                    _buildPickButton(context, 'Pick from gallery',
                        ImageSource.gallery, screenWidth, true, 'gallery'),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultView(RecogniserState state, BuildContext context) {
    if (state.status == RecogniserStatus.analyzing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 12),
          Text(
            'Analyzing...',
            style: subTitleTextStyleDark(fontWeight: FontWeight.bold),
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
        ? 'Accuracy: ${(state.accuracy * 100).toStringAsFixed(2)}%'
        : '';

    List<String> splitText(String text, TextStyle style, double maxWidth) {
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1000,
        textDirection: TextDirection.ltr,
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
        label, subTitleTextStyleDark(fontWeight: FontWeight.bold), maxWidth);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var line in labelLines)
          Text(
            line,
            style: subTitleTextStyleDark(fontWeight: FontWeight.bold),
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
    // Determine the icon based on the type
    IconData icon = type == 'photo' ? Icons.camera_alt : Icons.photo_library;

    return ElevatedButton(
      onPressed: () async {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: source,
        );
        if (pickedFile != null) {
          context
              .read<RecogniserBloc>()
              .add(PhotoPicked(File(pickedFile.path)));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36.0),
          side: isOutlined
              ? BorderSide(color: primaryColor, width: 3.0)
              : BorderSide.none,
        ),
        minimumSize: Size(width, 60.0),
        elevation: isOutlined ? 0 : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center content
        children: [
          Icon(
            icon,
            color: isOutlined ? primaryColor : Colors.white,
            size: 24.0, // Icon size
          ),
          const SizedBox(width: 10), // Space between icon and text
          Text(
            title,
            style: isOutlined
                ? descTextStyleDark(fontWeight: FontWeight.normal)
                : descTextStyleWhite(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
