import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> plant; // Accept plant data
  const DetailsPage({required this.plant, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15.0),
          ),
        ),
        backgroundColor: Color(0xFF464646),
        title: Text(plant['label'] ?? 'Plant Details',
            style: TextStyle(color: Color(0xFFFFFFFF))),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFFFFFFFF)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.image, size: 100),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Disease: ${plant['predict'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date: ${plant['date'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Status: ${plant['status'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add delete functionality here if needed
        },
        shape: CircleBorder(),
        backgroundColor: Colors.red,
        child: Icon(
          Icons.delete,
          color: Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}
