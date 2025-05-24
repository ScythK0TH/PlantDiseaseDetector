import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:project_pdd/style.dart';
import 'package:project_pdd/widget/storage_page.dart';
import 'package:project_pdd/widget/profile_page.dart';
import 'package:project_pdd/widget/recogniser.dart';

class HomePage extends StatefulWidget {
  final String userId;
  final int initialIndex;
  const HomePage({required this.userId, this.initialIndex = 1, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;

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
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
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
              label: 'Camera'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.photo,
                size: 24.0,
              ),
              label: 'Gallery'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 24.0,
              ),
              label: 'Profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}