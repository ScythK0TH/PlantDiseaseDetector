import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/services/database.dart';
import 'package:project_pdd/widget/storage_page.dart';
import 'package:project_pdd/widget/profile_page.dart';
import 'package:project_pdd/widget/recogniser.dart';

import 'ui/styles.dart';

class HomePage extends StatefulWidget {
  final String userId;
  final int initialIndex;
  const HomePage({required this.userId, this.initialIndex = 1, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  String? username;
  String? email;
  int galleryCount = 0;
  double totalSize = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final db = MongoService();
      final userCollection = db.userCollection;
      final galleryCollection = db.plantCollection;

      // Fetch user data
      final user = await userCollection!.findOne(
        mongo.where.eq('_id', mongo.ObjectId.fromHexString(widget.userId)),
      );

      // Fetch gallery count
      final gallery = await galleryCollection!
          .find(
            mongo.where
                .eq('userId', mongo.ObjectId.fromHexString(widget.userId)),
          )
          .toList();

      final totalSize = await _calculateTotalSize();

      if (mounted) {
        setState(() {
          username = user?['username'];
          email = user?['email'];
          galleryCount = gallery.length;
          this.totalSize = totalSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateGalleryCount(int newCount) {
    setState(() {
      galleryCount = newCount;
    });
  }

  //ทำไว้เพื่อเวลาลบรูปจะเรียกฟังก์ชันนี้แทนฟังก์ชันข้างบน
  Future<double> _calculateTotalSize() async {
    try {
      final db = MongoService();
      final galleryCollection = db.plantCollection;

      final gallery = await galleryCollection!
          .find(
            mongo.where
                .eq('userId', mongo.ObjectId.fromHexString(widget.userId)),
          )
          .toList();

      double totalSize = 0;
      for (var plant in gallery) {
        final bsonSize = plant.toString().length;
        final documentSize = bsonSize / (1024 * 1024);
        totalSize += documentSize;

        print(
            'Document ${plant['title']}: ${documentSize.toStringAsFixed(2)} MB');
      }
      return totalSize;
    } catch (e) {
      print('Error calculating total size: $e');
      return 0.0;
    }
  }

  Future<void> _updateTotalSize() async {
    final newSize = await _calculateTotalSize();
    setState(() {
      totalSize = newSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            AppTheme.isDarkMode(context) ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            AppTheme.isDarkMode(context) ? Brightness.light : Brightness.dark,
      ),
    );

    final List<Widget> pages = [
      Recogniser(
        userId: widget.userId,
        onClose: () {
          setState(() => _selectedIndex = 1);
        },
      ),
      StoragePage(
        userId: widget.userId,
        username: username,
        totalSize: totalSize,
        onUpdateTotalSize: _updateTotalSize,
      ),
      ProfilePage(
        userId: widget.userId,
        username: username,
        email: email,
        totalSize: totalSize,
        galleryCount: galleryCount,
        onGalleryUpdate: _updateGalleryCount,
        onUsernameUpdate: (String newUsername) {
          setState(() {
            username = newUsername;
          });
        },
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            top: true,
            left: true,
            right: true,
            bottom: true,
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
          if (_selectedIndex != 0)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                minimum: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                top: false,
                left: false,
                right: false,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                    ),
                    decoration: BoxDecoration(
                      gradient:
                          _selectedIndex == 2 ? null : AppTheme.primaryGradient,
                    ),
                    child: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      currentIndex: _selectedIndex,
                      onTap: (index) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        setState(() => _selectedIndex = index);
                      },
                      selectedItemColor: AppTheme.selectedIconColor(context),
                      unselectedItemColor: AppTheme.themedIconColor(context),
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.camera_alt, size: 28.0),
                          label: '',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.photo, size: 28.0),
                          label: '',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person, size: 28.0),
                          label: '',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
