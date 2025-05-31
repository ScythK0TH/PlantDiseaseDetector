import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/bloc/recogniser_bloc.dart';
import 'package:project_pdd/bloc/recogniser_event.dart';
import 'package:project_pdd/bloc/recogniser_state.dart';
import 'package:project_pdd/home.dart';
import 'package:project_pdd/main.dart';
import 'package:project_pdd/services/database.dart';
import 'package:project_pdd/style.dart';
import 'package:project_pdd/ui/styles.dart';
import 'package:project_pdd/widget/photo_view.dart';
import 'package:project_pdd/ui/responsive.dart';

class Recogniser extends StatefulWidget {
  final String userId; // Pass the logged-in user's _id
  final VoidCallback?
      onClose; // พิเศษสำหรับ Recogniser ที่ไม่ต้องการ BottomNavigationBar
  const Recogniser({required this.userId, this.onClose, super.key});

  @override
  State<Recogniser> createState() => _RecogniserState();
}

class _RecogniserState extends State<Recogniser> {
  bool isPressing = false;
  bool isResultButtonPressing = false;
  int selectedModel = 0;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = Responsive.isSmallMobile(context);
    final isMobile = Responsive.isMobile(context);

    return BlocProvider(
      create: (_) => RecogniserBloc()..add(RecogniserStarted()),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: AppTheme.isDarkMode(context)
                    ? Brightness.light
                    : Brightness.dark,
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Plant Analyzer'.tr(),
                          style: AppTheme.largeTitle(context),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.themedBgIconColor(context),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.close,
                                  color: AppTheme.themedIconColor(context)),
                              tooltip: 'Close',
                              onPressed: widget.onClose, // เรียก callback
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            body: BlocBuilder<RecogniserBloc, RecogniserState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8.0),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36.0),
                          ),
                          child: PhotoViewScreen(file: state.image),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Top result'.tr(),
                          style: AppTheme.mediumTitle(context),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8.0),
                        // ส่วนแสดงผลลัพธ์
                        Container(
                          padding: state.image == null
                              ? const EdgeInsets.all(0.0)
                              : const EdgeInsets.all(12.0),
                          width:
                              isSmallMobile || isMobile ? double.infinity : 600,
                          height: isSmallMobile || isMobile ? 250 : 300,
                          decoration: BoxDecoration(
                            color: state.image == null
                                ? Colors.transparent 
                                : null,
                            gradient: state.image == null
                                ? null
                                : (state.status == RecogniserStatus.found
                                    ? AppTheme.primaryGradient
                                    : AppTheme.alertGradient),
                            borderRadius: BorderRadius.circular(36.0),
                          ),
                          child: state.image == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: _buildModelSelector(
                                              context,
                                              'MobileNetV3 Small',
                                              'Minimalistic Modify',
                                              onTap: () {
                                                setState(
                                                    () => selectedModel = 0);
                                              },
                                              selected: selectedModel == 0,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Expanded(
                                            child: _buildModelSelector(
                                              context,
                                              'Comming Soon',
                                              'Coming Soon',
                                              onTap: () {
                                                setState(
                                                    () => selectedModel = 1);
                                              },
                                              selected: selectedModel == 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: _buildResultView(state, context),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        // ส่วนปุ่มต่างๆ
                        if (state.status != RecogniserStatus.analyzing) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                if (state.status == RecogniserStatus.found) ...[
                                  _buildResultButton(
                                      context,
                                      'Save Result'.tr(),
                                      screenWidth,
                                      false,
                                      'save',
                                      state),
                                  const SizedBox(height: 20),
                                  _buildResultButton(context, 'Cancel'.tr(),
                                      screenWidth, true, 'cancel', state),
                                ] else ...[
                                  _buildPickButton(
                                      context,
                                      'Take a photo'.tr(),
                                      ImageSource.camera,
                                      screenWidth,
                                      false,
                                      'photo'),
                                  const SizedBox(height: 20),
                                  _buildPickButton(
                                      context,
                                      'Pick from gallery'.tr(),
                                      ImageSource.gallery,
                                      screenWidth,
                                      true,
                                      'gallery'),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (isResultButtonPressing)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color:
                    const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.2),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : primaryColor,
                  ),
                ),
              ),
            ),
        ],
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
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Color(0xFF151C21),
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

    List<String> labelLines = splitText(label,
        subTitleTextStyleDark(context, fontWeight: FontWeight.bold), maxWidth);

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

  Widget _buildResultButton(BuildContext context, String title, double width,
      bool isOutlined, String type, RecogniserState state) {
    return ElevatedButton(
      onPressed: isResultButtonPressing
          ? null
          : () async {
              setState(() => isResultButtonPressing = true);
              if (type == 'save') {
                await _savedData(context, state, widget.userId);
              } else if (type == 'cancel') {
                //Reset the state
                context.read<RecogniserBloc>().add(RecogniserReset());
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

  Widget _buildModelSelector(
    BuildContext context,
    String modelName,
    String description, {
    VoidCallback? onTap,
    bool selected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(36),
          border: selected
              ? null
              : Border.all(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                modelName,
                style: AppTheme.mediumTitle(context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.start,
              ),
            ),
            Flexible(
              child: Text(
                description.tr(),
                style: AppTheme.smallContent(context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> cropAndResizeToContainer(
    File file, double containerWidth, double containerHeight) async {
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

  final cropped = img.copyCrop(image,
      x: offsetX, y: offsetY, width: cropWidth, height: cropHeight);

  // Resize to container size (optional, or set a fixed size)
  final resized = img.copyResize(cropped,
      width: containerWidth.toInt(), height: containerHeight.toInt());

  return base64Encode(img.encodeJpg(resized, quality: 80));
}

Future<void> _savedData(
    BuildContext context, RecogniserState state, String userId) async {
  if (userId.isEmpty) {
    print('Error: userId is empty.');
    return;
  }

  mongo.ObjectId mongoUserId;
  try {
    mongoUserId =
        mongo.ObjectId.fromHexString(userId); // Convert userId to ObjectId
  } catch (e) {
    print('Error: Invalid userId format. ' + e.toString());
    return;
  }
  final predict = state.label;
  final image = state.image != null
      ? await cropAndResizeToContainer(state.image!, 350, 300)
      : null;
  String title =
      state.image != null ? state.image!.path.split('/').last : 'Unknown';
  if (title.length > 15) {
    title = title.substring(title.length - 15);
  }
  final accuracy = state.accuracy;
  final dateTime = DateTime.now().toString();
  final pid = state.pid;

  try {
    print('Connecting to MongoDB...');
    final db = MongoService();
    print('Connected to MongoDB.');

    final collection = db.plantCollection;
    if (image != null) {
      await collection!.insert({
        'userId': mongoUserId,
        'image': image,
        'date': dateTime,
        'predict_id': pid,
        'predict': predict,
        'title': title,
        'probability': accuracy,
      });
      imageCountUpdateNotifier.value++;
    } else {
      print('Error: Image is null.');
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          userId: userId,
        ),
      ),
    );
  } catch (e) {
    print('Error: $e');
  }
}
