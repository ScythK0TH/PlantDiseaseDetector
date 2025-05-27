import 'package:flutter/material.dart';
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
  // เชื่อม MongoDB รับ UserId, Username และค่าเกี่ยวกับ UsedStorage

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Recogniser(userId: widget.userId),
      StoragePage(userId: widget.userId),
      ProfilePage(userId: widget.userId),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          // BottomNavigationBar overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(36),
              ),
              clipBehavior: Clip.antiAlias,
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                },
                selectedItemColor: AppTheme.selectedIconColor(context),
                unselectedItemColor: AppTheme.themedIconColor(context),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.camera_alt, size: 36.0),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.photo, size: 36.0),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person, size: 36.0),
                    label: '',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
