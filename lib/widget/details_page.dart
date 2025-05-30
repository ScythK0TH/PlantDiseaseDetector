import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_pdd/main.dart';
import 'package:project_pdd/services/database.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/ui/responsive.dart';
import 'package:project_pdd/widget/gemini.dart';
import 'package:project_pdd/ui/styles.dart';

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> plant;
  final String userId;
  const DetailsPage({required this.plant, required this.userId, super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _isUpdating = false;
  bool _isDeleted = false;
  Locale? _lastLocale;

  Future<void> deleteFunction(mongo.ObjectId plantId, String userId) async {
    try {
      print('Connecting to MongoDB...');
      final db = MongoService();

      final collection = db.plantCollection;
      print('Fetching plants for user: ${userId}...');

      try {
        final result = await collection!.remove(
            {'_id': plantId, 'userId': mongo.ObjectId.fromHexString(userId)});
        if (result['n'] > 0) {
          setState(() {
            _isDeleted = true;
          });
          imageCountUpdateNotifier.value -= 1;
          print('Plant deleted successfully.');
        } else {
          print('No plant found with the given ID and userId.');
        }
      } catch (e) {
        print('Error deleting plant: $e');
      }
    } catch (e) {
      print('Error db: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = context.locale;
    if (_lastLocale != currentLocale) {
      _lastLocale = currentLocale;
      getDetails(widget.plant, currentLocale.languageCode);
    }
  }

  Future<void> getDetails(plant, locale) async {
    String detfname = 'details_en.json';
    if (locale == 'th') {
      detfname = 'details_th.json';
    }
    await rootBundle
        .loadString('assets/my_model/details/$detfname')
        .then((String jsonString) {
      final List<dynamic> details = json.decode(jsonString);
      for (var detail in details) {
        if (detail['id'] == plant['predict_id']) {
          setState(() {
            plant['treatment'] = detail['treatment'];
            plant['prevention'] = detail['prevention'];
          });
          break; // Exit the loop once the matching detail is found
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    final userId = widget.userId;
    final isTabletOrDesktop =
        Responsive.isTablet(context) || Responsive.isDesktop(context);

    return PopScope(
      canPop: !_isUpdating,
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
                child: Row(
                  children: [
                    // Title ชิดซ้าย
                    Expanded(
                      child: Text(
                        'Image Details'.tr(),
                        style: AppTheme.largeTitle(context),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    // ปุ่มฟังก์ชันทางขวา
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.alertGradient,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: AppTheme.light,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor:
                                      AppTheme.themedBgColor(context),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(36.0),
                                  ),
                                  title: Text('Delete?'.tr(),
                                      style: AppTheme.mediumTitle(context)),
                                  content: Text(
                                      'Are you sure you want to delete this photo?'
                                          .tr(),
                                      style: AppTheme.smallContent(context)),
                                  actions: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.themedBgIconColor(
                                            context), // หรือ gradient ที่ต้องการสำหรับ Cancel
                                        borderRadius: BorderRadius.circular(36),
                                      ),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(36),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text('Cancel'.tr(),
                                            style: AppTheme.smallContent(
                                                context,
                                                color: AppTheme.themedIconColor(
                                                    context))),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.alertGradient,
                                        borderRadius: BorderRadius.circular(36),
                                      ),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(36),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12), // ปรับขนาดปุ่ม
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text('Delete'.tr(),
                                            style: AppTheme.smallContent(
                                                context,
                                                color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm != true) return;

                              setState(() => _isUpdating = true);
                              await deleteFunction(plant["_id"], userId);
                              if (!mounted) return;
                              Navigator.pop(context, _isDeleted);
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.themedBgIconColor(context),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: AppTheme.themedIconColor(context),
                              size: 24.0,
                            ),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              // Hide any currently displayed SnackBar
                              if (messenger.mounted) {
                                messenger.hideCurrentSnackBar();
                                // Wait a bit for the SnackBar to disappear
                                await Future.delayed(
                                    const Duration(milliseconds: 200));
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              centerTitle: false,
            ),
            body: Padding(
              padding: isTabletOrDesktop
                  ? const EdgeInsets.symmetric(
                      horizontal: 100.0) // Desktop: padding มากขึ้น
                  : const EdgeInsets.symmetric(horizontal: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36.0),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 96.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: isTabletOrDesktop ? 400 : 300,
                          height: isTabletOrDesktop ? 400 : 300,
                          child: plant['decodedImage'] != null
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.themedBgIconColor(context),
                                    borderRadius: BorderRadius.circular(36),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.memory(
                                    plant['decodedImage'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    alignment: Alignment.center,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.themedBgIconColor(context),
                                    borderRadius: BorderRadius.circular(36),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 50,
                                      color: AppTheme.themedIconColor(context),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          '${plant['title'] ?? 'Unknown'}',
                          style: AppTheme.mediumTitle(context),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.themedBgIconColor(context),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date
                            Row(
                              children: [
                                Text(
                                  'Date'.tr(),
                                  style: AppTheme.smallTitle(context),
                                ),
                                SizedBox(width: 8),
                                Expanded(child: Divider(thickness: 1)),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4, top: 2, bottom: 8),
                              child: Text(
                                (plant['date'] != null
                                    ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                        DateTime.tryParse(plant['date']) ??
                                            DateTime.now())
                                    : 'Unknown'),
                                style: AppTheme.smallContent(context),
                              ),
                            ),
                            // Predict
                            Row(
                              children: [
                                Text(
                                  'Predict'.tr(),
                                  style: AppTheme.smallTitle(context),
                                ),
                                SizedBox(width: 8),
                                Expanded(child: Divider(thickness: 1)),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4, top: 2, bottom: 8),
                              child: Text(
                                '${plant['predict'] ?? 'Unknown'}'.tr(),
                                style: AppTheme.smallContent(context),
                              ),
                            ),
                            // Treatment
                            Row(
                              children: [
                                Text(
                                  'Treatment'.tr(),
                                  style: AppTheme.smallTitle(context),
                                ),
                                SizedBox(width: 8),
                                Expanded(child: Divider(thickness: 1)),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4, top: 2, bottom: 8),
                              child: Text(
                                '${plant['treatment'] ?? 'Unknown'}',
                                style: AppTheme.smallContent(context),
                              ),
                            ),
                            // Prevention
                            Row(
                              children: [
                                Text(
                                  'Prevention'.tr(),
                                  style: AppTheme.smallTitle(context),
                                ),
                                SizedBox(width: 8),
                                Expanded(child: Divider(thickness: 1)),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4, top: 2, bottom: 0),
                              child: Text(
                                '${plant['prevention'] ?? 'Unknown'}',
                                style: AppTheme.smallContent(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Padding(
              padding: isTabletOrDesktop
                  ? const EdgeInsets.symmetric(horizontal: 100.0)
                  : const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isTabletOrDesktop ? 600 : double.infinity, // จำกัดความกว้างสูงสุด 600
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 56,
                        child: FloatingActionButton(
                          heroTag: 'edit_fab',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36),
                          ),
                          onPressed: () async {
                            final TextEditingController titleController =
                                TextEditingController(text: plant['title'] ?? '');
                            final newTitle = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.themedBgColor(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(36.0),
                                ),
                                title: Text('Edit Title'.tr(),
                                    style: AppTheme.mediumTitle(context)),
                                content: TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter new title'.tr(),
                                    hintStyle: AppTheme.smallContent(context),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(36), // ขอบมน 36
                                      borderSide: BorderSide(
                                          color: AppTheme.themedBgIconColor(
                                              context)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(36), // ขอบมน 36
                                      borderSide: BorderSide(
                                          color: AppTheme.themedBgIconColor(
                                              context)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(36), // ขอบมน 36
                                      borderSide: BorderSide(
                                          color: AppTheme.primaryColor),
                                    ),
                                  ),
                                ),
                                actions: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.themedBgIconColor(
                                          context), // หรือ gradient ที่ต้องการสำหรับ Cancel
                                      borderRadius: BorderRadius.circular(36),
                                    ),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'.tr(),
                                          style: AppTheme.smallContent(context)),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: AppTheme
                                          .primaryGradient, // หรือ gradient ที่ต้องการสำหรับ Cancel
                                      borderRadius: BorderRadius.circular(36),
                                    ),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                      ),
                                      onPressed: () => Navigator.pop(
                                          context, titleController.text),
                                      child: Text('Save'.tr(),
                                          style: AppTheme.smallContent(context)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (newTitle != null && newTitle.trim().isNotEmpty) {
                              if (newTitle.trim().length > 15) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppTheme.alertColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(36.0),
                                        topRight: Radius.circular(36.0),
                                      ),
                                    ),
                                    content: Text(
                                      'Title must be 15 characters or less!'.tr(),
                                      style: AppTheme.smallContent(context),
                                    ),
                                  ),
                                );
                                return; // Stop further execution
                              }
                              setState(() => _isUpdating = true);
                              try {
                                final db = MongoService();
                                final collection = db.plantCollection;
                                await collection!.update(
                                  {'_id': plant['_id']},
                                  {
                                    r'$set': {'title': newTitle.trim()}
                                  },
                                );
                                setState(() {
                                  plant['title'] = newTitle.trim();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: AppTheme.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(36.0),
                                          topRight: Radius.circular(36.0),
                                        ),
                                      ),
                                      content: Text('Title updated!'.tr(),
                                          style: AppTheme.smallContent(context))),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: AppTheme.alertColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(36.0),
                                          topRight: Radius.circular(36.0),
                                        ),
                                      ),
                                      content: Text(
                                        'Failed to update title:'.tr() + ' $e',
                                        style: AppTheme.smallContent(context),
                                      )),
                                );
                              } finally {
                                setState(() => _isUpdating = false);
                              }
                            }
                          },
                          backgroundColor: AppTheme.themedIconColor(context),
                          child: Icon(Icons.edit,
                              color: AppTheme.themedBgColor(context), size: 24),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 7,
                      child: SizedBox(
                        height: 56,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(36),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(36),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GeminiChatPage(plant: plant, userId: userId),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome,
                                      color: AppTheme.themedIconColor(context), size: 24),
                                  SizedBox(width: 8),
                                  Text('Assistance'.tr(),
                                      style: AppTheme.smallTitle(context)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isUpdating)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color:
                    const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.2),
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.themedIconColor(context)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
