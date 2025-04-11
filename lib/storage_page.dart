import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'constant.dart';
import 'details_page.dart';

class StoragePage extends StatefulWidget {
  final String userId; // Pass the logged-in user's _id
  const StoragePage({required this.userId, super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  List<Map<String, dynamic>> _plants = []; // Store plant documents
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchPlants(); // Fetch plants when the page loads
  }

  Future<void> _fetchPlants() async {
    try {
      print('Connecting to MongoDB...');
      final db = await mongo.Db.create(MONGO_URL);
      await db.open();
      print('Connected to MongoDB.');

      final collection = db.collection('plants');
      print('Fetching plants for user: ${widget.userId}...');

      // Ensure userId is a valid ObjectId
      final query = widget.userId is mongo.ObjectId
          ? {'userid': widget.userId}
          : {
              'userid': mongo.ObjectId.parse(widget.userId
                  .replaceAll(RegExp(r'^ObjectId\("(.*)"\)$'), r'\1'))
            };

      print('Query: $query');

      final plants = await collection.find(query).toList();
      print('Fetched plants: $plants');

      setState(() {
        _plants = plants; // Update the state with fetched plants
      });

      await db.close();
      print('MongoDB connection closed.');
    } catch (e) {
      print('Error fetching plants: $e');
    }
  }

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
      body: _plants.isEmpty
          ? Center(child: Text('No plants found.'))
          : ListView(
              children: _plants.map((plant) {
                return ListTile(
                  title: Text(plant['label'] ?? 'Unknown Plant'),
                  subtitle: Text(plant['predict'] ?? 'Unknown Prediction'),
                  trailing: Icon(Icons.image),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(plant: plant),
                      ),
                    );
                  },
                );
              }).toList(),
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
