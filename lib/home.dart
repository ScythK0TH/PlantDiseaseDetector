import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      ), // พิเศษสำหรับ Recogniser ที่ไม่ต้องการ BottomNavigationBar
      StoragePage(userId: widget.userId),
      ProfilePage(userId: widget.userId),
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
