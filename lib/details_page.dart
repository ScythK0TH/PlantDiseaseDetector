import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String title = args['title']!;
    final String subtitle = args['subtitle']!;

    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15.0),
          ),
        ),
        backgroundColor: Color(0xFF464646),
        title: Text(title, style: TextStyle(color: Color(0xFFFFFFFF))),
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
            Text('Disease: $subtitle', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date: dd/mm/yyyy hh:mm:ss', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Note: something lorem yipsum',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
