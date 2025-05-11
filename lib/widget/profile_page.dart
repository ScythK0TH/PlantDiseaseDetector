import 'package:flutter/material.dart';
import 'package:project_pdd/style.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/constant.dart';
import 'package:project_pdd/widget/recogniser.dart';
import 'package:project_pdd/main.dart';
import 'package:project_pdd/widget/storage_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userId});
  final String userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  bool _showSheet = false;
  bool _isLoading = false;
  Map<String, dynamic>? _userData;
  final ValueNotifier<double> _sheetExtent = ValueNotifier(0.7);

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final db = await mongo.Db.create(MONGO_URL);
    try {
      await db.open();
      final collection = db.collection('users');
      final user = await collection.findOne(
        mongo.where.eq('_id', mongo.ObjectId.fromHexString(widget.userId)),
      );
      if (!mounted) return;
      setState(() {
        _userData = user;
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
  Widget build(BuildContext context) {
    final double bottomNavHeight = 56.0;
    final double minExtent = 0.7;
    final double maxExtent = 1;
    final double showTitleExtent = 0.9; // When to start showing the title

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder<double>(
          valueListenable: _sheetExtent,
          builder: (context, extent, _) {
            // Title still appears at showTitleExtent, but you can adjust if needed
            double tTitle = ((extent - showTitleExtent) / (maxExtent - showTitleExtent)).clamp(0.0, 1.0);
            return AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_circle_left_rounded, color: Theme.of(context).brightness == Brightness.dark ? primaryColor : Colors.white),
              ),
              title: Transform.translate(
                offset: Offset(0, -40 * (1 - tTitle)), // Slide from above
                child: Opacity(
                  opacity: tTitle,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_userData?['email'] ?? '-'}',
                      style: mainTitleTextStyleWhite(context, fontWeight: FontWeight.bold),
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
                    color: Theme.of(context).brightness == Brightness.dark ? primaryColor : Colors.white,
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
              double t = ((extent - minExtent) / (maxExtent - minExtent)).clamp(0.0, 1.0);
              return Center(
                child: _isLoading
                    ? CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.dark ? primaryColor : Colors.white)
                    : Opacity(
                        opacity: 1 - t, // Fade out as soon as sheet starts to cover
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Text(
                                'User Profile',
                                style: mainTitleTextStyleWhite(context, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (_userData != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  'Email: ${_userData!['email'] ?? '-'}',
                                  style: descTextStyleWhite(context, fontWeight: FontWeight.normal),
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
                    return NotificationListener<DraggableScrollableNotification>(
                      onNotification: (notification) {
                        _sheetExtent.value = notification.extent;
                        return true;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                          colors: Theme.of(context).brightness != Brightness.dark
                            ? [Colors.white, Colors.white]
                            : [
                              Color.fromARGB(255, 11, 48, 54), // 2% blue
                              Colors.black,
                              ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                        ),
                        padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, bottomNavHeight + 16),
                        child: ListView(
                          controller: scrollController,
                          children: [
                            Icon(Icons.account_circle, size: 48, color: Colors.green),
                            SizedBox(height: 16),
                            Text(
                              'Welcome, ${_userData?['username'] ?? 'User'}!',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('User ID: ${widget.userId}'),
                            SizedBox(height: 16),
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
                        builder: (context) => Recogniser(userId: widget.userId),
                      ),
                    );
                    break;
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoragePage(userId: widget.userId),
                      ),
                    );
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(userId: widget.userId),
                      ),
                    );
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}