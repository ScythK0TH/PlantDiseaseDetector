import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_pdd/style.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/constant.dart';
import 'package:project_pdd/widget/recogniser.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> plant; // Accept plant data
  final String userId; // Accept userId
  const DetailsPage({required this.plant, required this.userId, super.key});

  Future<void> deleteFunction(mongo.ObjectId plantId, String userId) async {
    // Implement your delete logic here
    try {
      print('Connecting to MongoDB...');
      final db = await mongo.Db.create(MONGO_URL);
      await db.open();
      print('Connected to MongoDB.');

      final collection = db.collection('plants');
      print('Fetching plants for user: ${userId}...');

      try {
        // Attempt to delete the plant with the given ID and userId
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                    color: primaryColor,
                    size: 24.0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Center(
                child: Text('Image Details',
                    style: subTitleTextStyleDark(fontWeight: FontWeight.bold)),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: primaryColor,
                    size: 24.0,
                  ),
                  onPressed: () {
                    deleteFunction(plant["_id"], userId); // Call delete function with plant ID
                    Navigator.pop(context); // Navigate back after deletion
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
              child: plant['image'] != null // Check if image is not null
                  ? Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.memory(
                        base64Decode(plant['image']),
                        fit: BoxFit.cover,
                        width: double.infinity,   // Make sure it fills horizontally
                        height: double.infinity,  // Make sure it fills vertically
                        alignment: Alignment.center,
                      ),
                    )
                  : Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(36), // ทำให้ขอบมน
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: bgColor,
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
            Text('Accuracy: ${(plant['accuracy']*100).toStringAsFixed(2) ?? 'Unknown'}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Your edit logic here
        },
        child: Icon(Icons.edit, color: bgColor, size: 24,),
        backgroundColor: primaryColor, // You can change the color
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: successColor,
        unselectedItemColor: primaryColor,
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
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              size: 24.0,
            ),
            label: 'Setting',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Recogniser(userId: userId), // Pass userId to Recogniser
                  ),
                );
              break;
            case 1:
              // Already on Gallery, do nothing or reload if needed
              break;
            case 2:
              // Add route to profile page if available
              break;
            case 3:
              // Add route to setting page if available
              break;
          }
        },
      ),
    );
  }
}
