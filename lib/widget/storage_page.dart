import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/constant.dart';
import 'package:project_pdd/style.dart';
import 'package:project_pdd/widget/first_page.dart';
import 'package:project_pdd/widget/profile_page.dart';
import 'package:project_pdd/widget/recogniser.dart';
import 'details_page.dart';
import 'package:project_pdd/main.dart'; 

class StoragePage extends StatefulWidget {
  final String userId; // Pass the logged-in user's _id
  const StoragePage({required this.userId, super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> with RouteAware {
  List<Map<String, dynamic>> _plants = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPlants('');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _fetchPlants(_searchText);
  }

  Future<void> _fetchPlants(String search) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final db = await mongo.Db.create(MONGO_URL);
      await db.open();
      final collection = db.collection('plants');
      final query = {'userId': mongo.ObjectId.fromHexString(widget.userId)};
      final plants = await collection.find(query).toList();

      if (search.isNotEmpty) {
        _plants = plants.where((plant) {
          final title = plant['title']?.toString().toLowerCase() ?? '';
          return title.contains(search.toLowerCase());
        }).toList();
      } else {
        _plants = plants;
      }

      if (!mounted) return;
      setState(() {
        _plants = _plants;
      });

      await db.close();
    } catch (e) {
      print('Error fetching plants: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
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
              if (_isSearching)
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search plants...',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                      _fetchPlants(_searchText);
                    },
                  ),
                )
              else
                Text(
                  'Gallery',
                  style: subTitleTextStyleDark(context, fontWeight: FontWeight.bold),
                ),
              Spacer(),
              if (_isSearching)
                IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor, size: 24.0),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchText = '';
                      _searchController.clear();
                    });
                    _fetchPlants('');
                  },
                )
              else
                IconButton(
                  icon: Icon(Icons.search, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor, size: 24.0),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                  size: 24.0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FirstPageScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor))
          : _plants.isEmpty
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
                                    : descTextStyleDark(context,
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
                                    : descTextStyleDark(context,
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
                                    builder: (context) => DetailsPage(plant: plant, userId: widget.userId), // Pass userId to DetailsPage
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
                                    if (plant['image'] == null) // ตรวจสอบว่ามีภาพหรือไม่
                                      Container(
                                        width: double.infinity,
                                        height: 150.0,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor, // สีพื้นหลังที่แทนภาพ
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
                                      )
                                    else
                                        Container(
                                        width: double.infinity,
                                        height: 150.0,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor, // สีพื้นหลังที่แทนภาพ
                                          borderRadius:
                                            BorderRadius.circular(36.0), // ขอบมน
                                        ),
                                        clipBehavior: Clip.antiAlias, // Ensure child respects borderRadius
                                        child: Image.memory(
                                          base64Decode(plant['image']),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 150.0,
                                          errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          );
                                          },
                                        ),
                                        ),
                                    SizedBox(height: 8.0),
                                    // แสดงชื่อของ plant
                                    Text(
                                      plant['title'] ?? 'Unknown Plant',
                                      style: descTextStyleDark(context,
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
                    builder: (context) => Recogniser(userId: widget.userId), // Pass userId to Recogniser
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
    );
  }
}
