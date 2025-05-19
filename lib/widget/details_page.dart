import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_pdd/home.dart';
import 'package:project_pdd/style.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/constant.dart';
import 'package:project_pdd/widget/gemini.dart';
import 'package:project_pdd/widget/profile_page.dart';
import 'package:project_pdd/widget/recogniser.dart';

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> plant;
  final String userId;
  const DetailsPage({required this.plant, required this.userId, super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _isUpdating = false;
  bool _updatedTitle = false;
  Locale? _lastLocale;

  Future<void> deleteFunction(mongo.ObjectId plantId, String userId) async {
    try {
      print('Connecting to MongoDB...');
      final db = await mongo.Db.create(MONGO_URL);
      await db.open();
      print('Connected to MongoDB.');

      final collection = db.collection('plants');
      print('Fetching plants for user: ${userId}...');

      try {
        final result = await collection.remove({
          '_id': plantId,
          'userId': mongo.ObjectId.fromHexString(userId)
        });
        if (result['n'] > 0) {
          print('Plant deleted successfully.');
        } else {
          print('No plant found with the given ID and userId.');
        }
      } catch (e) {
        print('Error deleting plant: $e');
      }

      await db.close();
      print('MongoDB connection closed.');
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
    await rootBundle.loadString('assets/my_model/details/$detfname').then((String jsonString) {
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
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    final userId = widget.userId;

    return PopScope(
      canPop: !_isUpdating,
      child: Stack(
        children: [
          Scaffold(
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
                  child: Stack(alignment: Alignment.center, children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_circle_left_rounded,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                          size: 24.0,
                        ),
                        onPressed: () {
                          Navigator.pop(context, _updatedTitle);
                        },
                      ),
                    ),
                    Center(
                      child: Text('Image Details'.tr(),
                          style: subTitleTextStyleDark(context, fontWeight: FontWeight.bold)),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? primaryColor
                                                    : Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(36.0),
                                                ),
                              title: Text('Delete?'.tr()),
                              content: Text('Are you sure you want to delete this photo?'.tr()),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel'.tr()),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Delete'.tr()),
                                ),
                              ],
                            ),
                          );
                          if (confirm != true) return;
      
                          setState(() => _isUpdating = true);
                          await deleteFunction(plant["_id"], userId);
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(userId: userId),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                ),
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: Text('${plant['title'] ?? 'Unknown'}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: plant['image'] != null
                          ? Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                                borderRadius: BorderRadius.circular(36),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.memory(
                                base64Decode(plant['image']),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(height: 20),
                    Text('Date'.tr() + ': ${plant['date'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text('Predict'.tr() + ': ' + '${plant['predict'] ?? 'Unknown'}'.tr(),
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text('Treatment'.tr() + ': ${(plant['treatment']) ?? 'Unknown'}',
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text('Prevention'.tr() + ': ${(plant['prevention']) ?? 'Unknown'}',
                        style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton.extended(
                      heroTag: 'assistance_fab',
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                      foregroundColor: Theme.of(context).brightness == Brightness.dark ? primaryColor : Colors.white,
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Assistance').tr(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GeminiChatPage(plant: plant, userId: userId),
                          ),
                        );
                      },
                    ),
                  FloatingActionButton(
                    heroTag: 'edit_fab',
                    onPressed: () async {
                      final TextEditingController titleController =
                          TextEditingController(text: plant['title'] ?? '');
                      final newTitle = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? primaryColor
                            : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36.0),
                          ),
                          title: Text('Edit Title'.tr()),
                          content: TextField(
                            controller: titleController,
                            decoration: InputDecoration(hintText: 'Enter new title'.tr()),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'.tr()),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, titleController.text),
                              child: Text('Save'.tr()),
                            ),
                          ],
                        ),
                      );
                      if (newTitle != null && newTitle.trim().isNotEmpty) {
                        if (newTitle.trim().length > 15) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(12.0),
                                ),
                              ),
                              content: Text('Title must be 15 characters or less!'.tr()),
                            ),
                          );
                          return; // Stop further execution
                        }
                        setState(() => _isUpdating = true);
                        try {
                          final db = await mongo.Db.create(MONGO_URL);
                          await db.open();
                          final collection = db.collection('plants');
                          await collection.update(
                            {'_id': plant['_id']},
                            {r'$set': {'title': newTitle.trim()}},
                          );
                          await db.close();
                          _updatedTitle = true;
                          setState(() {
                            plant['title'] = newTitle.trim();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(12.0),
                                ),
                              ),
                              content: Text('Title updated!'.tr())
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(12.0),
                                ),
                              ),
                              content: Text('Failed to update title:'.tr() + ' $e')
                            ),
                          );
                        } finally {
                          setState(() => _isUpdating = false);
                        }
                      }
                    },
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                    child: Icon(Icons.edit, color: (Theme.of(context).brightness == Brightness.dark ? primaryColor : Colors.white), size: 24),
                  ),
                ],
              ),
            ),
          ),
          if (_isUpdating)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.2),
                child: Center(
            child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
