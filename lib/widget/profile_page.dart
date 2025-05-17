import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_pdd/style.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/constant.dart';
import 'package:project_pdd/widget/first_page.dart';
import 'package:project_pdd/widget/recogniser.dart';
import 'package:project_pdd/main.dart';
import 'package:project_pdd/widget/storage_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userId});
  final String userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _showSheet = false;
  bool _isLoading = false;
  bool _isUpdating = false;
  Map<String, dynamic>? _userData;
  final ValueNotifier<double> _sheetExtent = ValueNotifier(0.7);
  int? galleryCount;

  Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final db = await mongo.Db.create(MONGO_URL);
    try {
      await db.open();
      final collection = db.collection('users');
      final galleryCollection = db.collection('plants');
      final user = await collection.findOne(
        mongo.where.eq('_id', mongo.ObjectId.fromHexString(widget.userId)),
      );
      final gallery = await galleryCollection
          .find(
            mongo.where
                .eq('userId', mongo.ObjectId.fromHexString(widget.userId)),
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _userData = user;
        galleryCount = gallery.length;
      });
      await db.close();
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData().then((_) {
        if (mounted) {
          setState(() {
            _showSheet = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _sheetExtent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomNavHeight = 56.0;
    final double minExtent = 0.7;
    final double maxExtent = 1;
    final double showTitleExtent = 0.9; // When to start showing the title

    return Scaffold(
      backgroundColor: _isLoading
          ? Theme.of(context).brightness == Brightness.dark
              ? primaryColor
              : Colors.white
          : Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder<double>(
          valueListenable: _sheetExtent,
          builder: (context, extent, _) {
            // Title still appears at showTitleExtent, but you can adjust if needed
            double tTitle =
                ((extent - showTitleExtent) / (maxExtent - showTitleExtent))
                    .clamp(0.0, 1.0);
            return AppBar(
              backgroundColor: Colors.transparent,
              systemOverlayStyle: themeModeNotifier.value == ThemeMode.dark
                  ? SystemUiOverlayStyle.dark
                  : SystemUiOverlayStyle.light,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_circle_left_rounded,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? primaryColor
                        : Colors.white),
              ),
              title: Transform.translate(
                offset: Offset(0, -40 * (1 - tTitle)), // Slide from above
                child: Opacity(
                  opacity: tTitle,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_userData?['username'] ?? '-'}',
                      style: mainTitleTextStyleWhite(context,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? primaryColor
                        : Colors.white,
                  ),
                  onPressed: () {
                    // Toggle theme
                    themeModeNotifier.value =
                        Theme.of(context).brightness == Brightness.dark
                            ? ThemeMode.light
                            : ThemeMode.dark;
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Stack(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _sheetExtent,
            builder: (context, extent, _) {
              // Fade out as soon as sheet starts moving up
              double t = ((extent - minExtent) / (maxExtent - minExtent))
                  .clamp(0.0, 1.0);
              return Center(
                child: _isLoading
                    ? Container(
                      margin: EdgeInsets.only(bottom: bottomNavHeight + 24),
                      child: CircularProgressIndicator(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : primaryColor),
                    )
                    : _userData == null
                        ? Text(
                            'User not found.'.tr(),
                            style: descTextStyleWhite(context,
                                fontWeight: FontWeight.normal),
                          )
                        : Opacity(
                            opacity: 1 -
                                t, // Fade out as soon as sheet starts to cover
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: Text(
                                    'User Profile'.tr(),
                                    style: mainTitleTextStyleWhite(context,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    'Email: ${_userData!['email'] ?? '-'}',
                                    style: descTextStyleWhite(context,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ],
                            ),
                          ),
              );
            },
          ),
          if (_showSheet && !_isLoading)
            IgnorePointer(
              ignoring: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: DraggableScrollableSheet(
                  initialChildSize: minExtent,
                  minChildSize: minExtent,
                  maxChildSize: maxExtent,
                  builder: (context, scrollController) {
                    return NotificationListener<
                        DraggableScrollableNotification>(
                      onNotification: (notification) {
                        _sheetExtent.value = notification.extent;
                        return true;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: Theme.of(context).brightness !=
                                    Brightness.dark
                                ? [Colors.white, Colors.white]
                                : [
                                    Color.fromARGB(255, 11, 48, 54), // 2% blue
                                    Colors.black,
                                  ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(36)),
                        ),
                        padding: EdgeInsets.fromLTRB(
                            24.0, 24.0, 24.0, bottomNavHeight + 16),
                        child: ListView(
                          controller: scrollController,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      onPressed: () async {
                                        final TextEditingController unameController =
                                              TextEditingController(text: _userData!['username'] ?? '');
                                        final newTitle = await showDialog<String>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                                                ? primaryColor
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(36.0),
                                            ),
                                            title: Text('Edit Your Name'.tr()),
                                            content: TextField(
                                              controller: unameController,
                                              decoration: InputDecoration(hintText: 'Enter new name'.tr()),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text('Cancel'.tr()),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, unameController.text),
                                                child: Text('Save'.tr()),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (newTitle != null && newTitle.trim().isNotEmpty) {
                                          if (newTitle.trim().length > 20) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(12.0),
                                                    topRight: Radius.circular(12.0),
                                                  ),
                                                ),
                                                behavior: SnackBarBehavior.floating,
                                                margin: EdgeInsets.only(
                                                  bottom: bottomNavHeight, // 56 (nav height) + 16 spacing
                                                ),
                                                content: Text('Name must be 20 characters or less!'.tr()),
                                              ),
                                            );
                                            return; // Stop further execution
                                          }
                                          setState(() => _isUpdating = true);
                                          try {
                                            final db = await mongo.Db.create(MONGO_URL);
                                            await db.open();
                                            final collection = db.collection('users');
                                            await collection.update(
                                              {'_id': _userData!['_id']},
                                              {r'$set': {'username': newTitle.trim()}},
                                            );
                                            await db.close();
                                            setState(() {
                                              _userData!['username'] = newTitle.trim();
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(12.0),
                                                    topRight: Radius.circular(12.0),
                                                  ),
                                                ),
                                                behavior: SnackBarBehavior.floating,
                                                margin: EdgeInsets.only(
                                                  bottom: bottomNavHeight, // 56 (nav height) + 16 spacing
                                                ),
                                                content: Text('Name updated!'.tr())
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(12.0),
                                                    topRight: Radius.circular(12.0),
                                                  ),
                                                ),
                                                behavior: SnackBarBehavior.floating,
                                                margin: EdgeInsets.only(
                                                  bottom: bottomNavHeight, // 56 (nav height) + 16 spacing
                                                ),
                                                content: Text('Failed to update name:'.tr() + ' $e')
                                              ),
                                            );
                                          } finally {
                                            setState(() => _isUpdating = false);
                                          }
                                        }
                                      },
                                      icon: Icon(Icons.edit, size: 24, color: Colors.green),
                                    )
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Icon(Icons.account_circle, size: 48, color: Colors.green),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(onPressed: () {
                                      themeModeNotifier.value = ThemeMode.light;
                                      clearLoginState().then((_) {
                                        // Clear the userId from SharedPreferences
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (context) => FirstPageScreen()),
                                          (route) => false, // Remove all previous routes
                                        );
                                      });
                                    }, icon: Icon(Icons.logout, size: 24, color: Colors.red),)
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                'Welcome,'.tr() + ' ${_userData?['username'] ?? 'User'}!',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Divider(),
                            Container(
                              padding: EdgeInsets.all(24),
                              margin: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[200]
                                    : primaryColor,
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Your Gallery'.tr(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? primaryColor
                                                  : Colors.white),
                                        ),
                                        SizedBox(height: 8),
                                        Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: '${galleryCount ?? 0} ',
                                                style: TextStyle(
                                                    fontSize: 56,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: 'images'.tr(),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                      .brightness ==
                                                  Brightness.dark
                                              ? primaryColor
                                              : Colors.white
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(24),
                              margin: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[200]
                                    : primaryColor,
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Your Gallery'.tr(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? primaryColor
                                                  : Colors.white),
                                        ),
                                        SizedBox(height: 8),
                                        Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: '${galleryCount ?? 0} ',
                                                style: TextStyle(
                                                    fontSize: 56,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: 'images'.tr(),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                      .brightness ==
                                                  Brightness.dark
                                              ? primaryColor
                                              : Colors.white
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          // BottomNavigationBar as top-most widget
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 2,
              selectedItemColor: successColor,
              unselectedItemColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : primaryColor,
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
              onTap: (index) {
                switch (index) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Recogniser(userId: widget.userId),
                      ),
                    );
                    break;
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StoragePage(userId: widget.userId),
                      ),
                    );
                    break;
                }
              },
            ),
          ),
          if (_isUpdating)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.2),
              child: Center(
            child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.dark ? primaryColor : Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
