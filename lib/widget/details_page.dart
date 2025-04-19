import 'package:flutter/material.dart';
import 'package:project_pdd/style.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> plant; // Accept plant data
  const DetailsPage({required this.plant, super.key});

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
                    // Do something
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
            Text('File Name: ${plant['image'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Flexible(
              child: Container(
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
            Text('Type: ${plant['type'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Predict: ${plant['predict'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Title: ${plant['title'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Your edit logic here
        },
        child: Icon(
          Icons.edit,
          color: bgColor,
          size: 24,
        ),
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
              Navigator.pushNamed(context, '/camera');
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
