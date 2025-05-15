import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_pdd/style.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/constant.dart';
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
  Widget build(BuildContext context) {
    final plant = widget.plant;
    final userId = widget.userId;

    return Stack(
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
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Center(
                    child: Text('Image Details',
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
                      onPressed: () {
                        deleteFunction(plant["_id"], userId);
                        Navigator.pop(context);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text('${plant['title'] ?? 'Unknown'}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 20),
                Flexible(
                  child: plant['image'] != null
                      ? Container(
                          height: 300,
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
                          height: 300,
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
                Text('Date: ${plant['date'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Predict: ${plant['predict'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Probability: ${(plant['probability'] * 100).toStringAsFixed(2) ?? 'Unknown'}',
                    style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final TextEditingController titleController =
                  TextEditingController(text: plant['title'] ?? '');
              final newTitle = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Edit Title'),
                  content: TextField(
                    controller: titleController,
                    decoration: InputDecoration(hintText: 'Enter new title'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, titleController.text),
                      child: Text('Save'),
                    ),
                  ],
                ),
              );
              if (newTitle != null && newTitle.trim().isNotEmpty) {
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
                  setState(() {
                    plant['title'] = newTitle.trim();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Title updated!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update title: $e')),
                  );
                } finally {
                  setState(() => _isUpdating = false);
                }
              }
            },
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
            child: Icon(Icons.edit, color: (Theme.of(context).brightness == Brightness.dark ? primaryColor : Colors.white), size: 24),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 1,
            selectedItemColor: successColor,
            unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.camera_alt,
                  size: 24.0,
                ),
                label: 'Camera',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.photo,
                  size: 24.0,
                ),
                label: 'Gallery',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  size: 24.0,
                ),
                label: 'Profile',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Recogniser(userId: userId),
                    ),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(userId: widget.userId), // Pass userId to Recogniser
                    ),
                  );
                  break;
              }
            },
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
    );
  }
}
