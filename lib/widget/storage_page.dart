import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/constant.dart';
import 'package:project_pdd/style.dart';
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
    String selectedButton = 'Latest';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                'Gallery',
                style: subTitleTextStyleDark(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: primaryColor,
                  size: 24.0,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: primaryColor,
                  size: 24.0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: _plants.isEmpty
          ? Center(child: Text('No plants found.'))
          : Container(
              width: double.infinity, // ยืดความกว้างให้เต็มที่
              height: double.infinity, // ยืดความสูงให้เต็มที่
              padding: EdgeInsets.symmetric(
                  horizontal: 24.0), // เพิ่ม padding รอบๆ ListView
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(36.0)), // ขอบมน
                color: Colors.transparent,
              ),
              child: Column(
                children: [
                  // ปุ่ม TextButton สำหรับ All และ Latest
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // ปุ่ม All
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedButton =
                                  'Latest'; // เปลี่ยนสถานะเมื่อกดปุ่ม All
                            });
                          },
                          child: Text(
                            'Latest',
                            style: selectedButton == 'Latest'
                                ? successTextStyle(fontWeight: FontWeight.bold)
                                : descTextStyleDark(
                                    fontWeight: FontWeight.normal),
                          ),
                        ),
                        // ปุ่ม Latest
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedButton =
                                  'All'; // เปลี่ยนสถานะเมื่อกดปุ่ม Latest
                            });
                          },
                          child: Text(
                            'All',
                            style: selectedButton == 'All'
                                ? successTextStyle(fontWeight: FontWeight.bold)
                                : descTextStyleDark(
                                    fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // GridView สำหรับแสดงข้อมูล
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // จำนวนคอลัมน์ในแต่ละแถว
                        crossAxisSpacing: 8.0, // ช่องว่างระหว่างคอลัมน์
                        mainAxisSpacing: 8.0, // ช่องว่างระหว่างแถว
                        childAspectRatio:
                            0.8, // ปรับอัตราส่วนของลูกในกริด (ความสูง/ความกว้าง)
                      ),
                      itemCount: _plants.length,
                      itemBuilder: (context, index) {
                        var plant = _plants[index];
                        return GestureDetector(
                          onTap: () {
                            // เมื่อกดที่ไอเทม จะไปยังหน้า DetailsPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsPage(plant: plant),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(36.0), // ขอบมน
                              color: Colors.transparent, // ใช้สีพื้นหลังแทนภาพ
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // แสดงพื้นหลังสีแทนภาพ
                                Container(
                                  width: double.infinity,
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    color: primaryColor, // สีพื้นหลังที่แทนภาพ
                                    borderRadius:
                                        BorderRadius.circular(36.0), // ขอบมน
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.image, // ไอคอนแทนภาพ
                                      size: 50,
                                      color: Colors.white, // สีของไอคอน
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                // แสดงชื่อของ plant
                                Text(
                                  plant['image'] ?? 'Unknown Plant',
                                  style: descTextStyleDark(
                                      fontWeight: FontWeight.normal),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4.0),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
