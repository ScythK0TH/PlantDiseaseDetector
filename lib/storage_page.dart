import 'package:flutter/material.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});
  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  String? _selectedCategory;

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
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFFFFFFF),
            )),
        title: Text(
          'Storage',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Color(0xFFFFFFFF)),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Row(
              children: [
                SizedBox(width: 8.0),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: <String>['ทั้งหมด', 'สุขภาพดี', 'เป็นโรค']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  hint: Text('ทั้งหมด'),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Plant01'),
            subtitle: Text('Healthy'),
            trailing: Icon(Icons.image),
            onTap: () {
              Navigator.pushNamed(context, '/details',
                  arguments: {'title': 'Plant01', 'subtitle': 'healthy'});
            },
          ),
          ListTile(
            title: Text('Plant02'),
            subtitle: Text('Healthy'),
            trailing: Icon(Icons.image),
            onTap: () {
              Navigator.pushNamed(context, '/details',
                  arguments: {'title': 'Plant02', 'subtitle': 'healthy'});
            },
          ),
          ListTile(
            title: Text('Plant03'),
            subtitle: Text('Powdery mildew'),
            trailing: Icon(Icons.image),
            onTap: () {
              Navigator.pushNamed(context, '/details', arguments: {
                'title': 'Plant03',
                'subtitle': 'Powdery mildew'
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/camera');
        },
        shape: CircleBorder(),
        backgroundColor: Color(0xFF00BA18),
        child: Icon(Icons.add, color: Color(0xFFFFFFFF)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
        child: BottomAppBar(
          color: Color(0xFF464646),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.sort, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
