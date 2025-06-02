import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_pdd/services/database.dart';
import 'package:project_pdd/style.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/ui/responsive.dart';
import 'package:project_pdd/ui/styles.dart';
import 'package:project_pdd/widget/first_page.dart';
import 'package:project_pdd/main.dart';
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
    final db = MongoService();
    try {
      final collection = db.userCollection;
      final galleryCollection = db.plantCollection;
      final user = await collection!.findOne(
        mongo.where.eq('_id', mongo.ObjectId.fromHexString(widget.userId)),
      );
      final gallery = await galleryCollection!
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
    imageCountUpdateNotifier.addListener(_updateGalleryCount);
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

  void _updateGalleryCount() {
    final newCount = imageCountUpdateNotifier.value;
    if (galleryCount == null || galleryCount != newCount) {
      setState(() {
        galleryCount = newCount;
      });
    }
  }

  @override
  void dispose() {
    // Add this line to remove listener when widget disposes
    imageCountUpdateNotifier.removeListener(_updateGalleryCount);
    _sheetExtent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomNavHeight = 56.0;
    final double minExtent = 0.7;
    final double maxExtent = 1;
    final double showTitleExtent = 0.9; // When to start showing the title

    final isSmallMobile = Responsive.isSmallMobile(context);
    final isMobile = Responsive.isMobile(context);

    //Mock up storage Value
    //MongoDB แก้ไขตรงนี้
    final double usedStorage = 120;
    final double totalStorage = 1024;
    final String storageText =
        '${usedStorage.toStringAsFixed(2)} / ${totalStorage.toStringAsFixed(2)} MB';

    //Storage detail
    final storageInfoWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          storageText,
          style: AppTheme.smallTitle(context),
          softWrap: true,
          overflow: TextOverflow.visible,
          maxLines: null,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          width: 120,
          child: Container(
            height: 18,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: AppTheme.themedIconColor(context),
                width: 2, // ความหนาขอบ
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: LinearProgressIndicator(
                  value: usedStorage / totalStorage,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.themedIconColor(context)),
                  minHeight: 18),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppTheme.themedBgColor(context),
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
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: AppTheme.isDarkMode(context)
                    ? Brightness.light
                    : Brightness.dark,
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Transform.translate(
                        offset:
                            Offset(0, -40 * (1 - tTitle)), // Slide from above
                        child: Opacity(
                          opacity: tTitle,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${_userData?['username'] ?? '-'}',
                              style: AppTheme.largeTitle(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.themedBgIconColor(context),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: IconButton(
                            icon: Icon(
                                AppTheme.isDarkMode(context)
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: AppTheme.themedIconColor(context)),
                            onPressed: () {
                              final isDark = Theme.of(context).brightness ==
                                  Brightness.dark;
                              final newMode =
                                  isDark ? ThemeMode.light : ThemeMode.dark;
                              themeModeNotifier.value = newMode;
                              saveThemeMode(
                                  newMode); // <-- save to SharedPreferences
                            },
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.themedBgIconColor(context),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: IconButton(
                            onPressed: () async {
                              final TextEditingController unameController =
                                  TextEditingController(
                                      text: _userData!['username'] ?? '');
                              final newTitle = await showDialog<String>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor:
                                      AppTheme.themedBgColor(context),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(36.0),
                                  ),
                                  title: Text(
                                    'Edit Your Name'.tr(),
                                    style: AppTheme.mediumContent(context),
                                  ),
                                  content: TextField(
                                    controller: unameController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter new name'.tr(),
                                      hintStyle: AppTheme.smallContent(context),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            36), // ขอบมน 36
                                        borderSide: BorderSide(
                                            color: AppTheme.themedBgIconColor(
                                                context)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            36), // ขอบมน 36
                                        borderSide: BorderSide(
                                            color: AppTheme.themedBgIconColor(
                                                context)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            36), // ขอบมน 36
                                        borderSide: BorderSide(
                                            color: AppTheme.primaryColor),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.themedBgIconColor(
                                            context), // หรือ gradient ที่ต้องการสำหรับ Cancel
                                        borderRadius: BorderRadius.circular(36),
                                      ),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(36),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Cancel'.tr(),
                                          style: AppTheme.smallContent(context),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: AppTheme
                                            .primaryGradient, // หรือ gradient ที่ต้องการสำหรับ Cancel
                                        borderRadius: BorderRadius.circular(36),
                                      ),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(36),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                        ),
                                        onPressed: () => Navigator.pop(
                                            context, unameController.text),
                                        child: Text('Save'.tr(),
                                            style:
                                                AppTheme.smallContent(context)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (newTitle != null &&
                                  newTitle.trim().isNotEmpty) {
                                if (newTitle.trim().length > 20) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppTheme.alertColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(36.0),
                                          topRight: Radius.circular(36.0),
                                        ),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                        bottom:
                                            bottomNavHeight, // 56 (nav height) + 16 spacing
                                      ),
                                      content: Text(
                                          'Name must be 20 characters or less!'
                                              .tr(),
                                          style:
                                              AppTheme.smallContent(context)),
                                    ),
                                  );
                                  return; // Stop further execution
                                }
                                setState(() => _isUpdating = true);
                                try {
                                  final db = MongoService();
                                  final collection = db.userCollection;
                                  await collection!.update(
                                    {'_id': _userData!['_id']},
                                    {
                                      r'$set': {'username': newTitle.trim()}
                                    },
                                  );
                                  setState(() {
                                    _userData!['username'] = newTitle.trim();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        backgroundColor: AppTheme.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(36.0),
                                            topRight: Radius.circular(36.0),
                                          ),
                                        ),
                                        content: Text('Name updated!'.tr(),
                                            style: AppTheme.smallContent(
                                                context))),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        backgroundColor: AppTheme.alertColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(36.0),
                                            topRight: Radius.circular(36.0),
                                          ),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.only(
                                          bottom:
                                              bottomNavHeight, // 56 (nav height) + 16 spacing
                                        ),
                                        content: Text(
                                            'Failed to update name:'.tr() +
                                                ' $e')),
                                  );
                                } finally {
                                  setState(() => _isUpdating = false);
                                }
                              }
                            },
                            icon: Icon(Icons.edit,
                                size: 24,
                                color: AppTheme.themedIconColor(context)),
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.alertGradient,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: IconButton(
                            onPressed: () {
                              themeModeNotifier.value = ThemeMode.light;
                              saveThemeMode(ThemeMode.light);
                              clearLoginState().then((_) {
                                // Clear the userId from SharedPreferences
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FirstPageScreen()),
                                  (route) =>
                                      false, // Remove all previous routes
                                );
                              });
                            },
                            icon: Icon(Icons.logout,
                                size: 24, color: AppTheme.light),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
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
                    ? CircularProgressIndicator(
                        color: AppTheme.themedIconColor(context))
                    : _userData == null
                        ? Text(
                            'User not found.'.tr(),
                            style: AppTheme.mediumContent(context),
                          )
                        : Opacity(
                            opacity: 1 -
                                t, // Fade out as soon as sheet starts to cover
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 56.0),
                                  child: Text(
                                    'User Profile'.tr(),
                                    style: AppTheme.largeTitle(context),
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
                          gradient: AppTheme.primaryGradient,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(36)),
                        ),
                        padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
                        child: ListView(
                          controller: scrollController,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_circle,
                                  size: 48,
                                  color: AppTheme.themedIconColor(context),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Welcome,'.tr() +
                                              ' ${_userData?['username'] ?? 'User'}!',
                                          style: AppTheme.mediumTitle(context)),
                                      Text(
                                        'Email: ${_userData?['email'] ?? '-'}',
                                        style: AppTheme.mediumTitle(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: AppTheme.themedIconColor(context),
                            ),
                            Container(
                              padding: EdgeInsets.all(24.0),
                              margin: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                color: AppTheme.dark.withValues(alpha: (0.15)),
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text('Your Gallery'.tr(),
                                            style:
                                                AppTheme.mediumTitle(context)),
                                        SizedBox(height: 8.0),
                                        Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: '${galleryCount ?? 0} ',
                                                style:
                                                    AppTheme.largeTitle(context)
                                                        .copyWith(
                                                            fontSize: 56.0),
                                              ),
                                              TextSpan(
                                                text: 'images'.tr(),
                                                style: AppTheme.smallTitle(
                                                    context),
                                              ),
                                            ],
                                          ),
                                          style: TextStyle(
                                              color: AppTheme.themedBgColor(
                                                  context)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.dark.withValues(alpha: (0.15)),
                                borderRadius: BorderRadius.circular(36.0),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0, vertical: 16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        isMobile || isSmallMobile
                                            ? CrossAxisAlignment.center
                                            : CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 8.0),
                                      if (isMobile || isSmallMobile)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Cloud Storage'.tr(),
                                              style: AppTheme.mediumTitle(
                                                context,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 8),
                                            storageInfoWidget,
                                          ],
                                        )
                                      else
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // เพื่มในอนาคต เรื่องการตรวจสอบ Internet สำหรับ Cloud Storage
                                            Text(
                                              'Cloud Storage'.tr(),
                                              style: AppTheme.mediumTitle(
                                                context,
                                              ),
                                            ),
                                            Spacer(),
                                            storageInfoWidget,
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              color: AppTheme.themedIconColor(context),
                            ),
                            Container(
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[200]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await context
                                            .setLocale(Locale('en', 'US'));
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 24),
                                        decoration: BoxDecoration(
                                          color: context.locale.languageCode ==
                                                  'en'
                                              ? Colors.green
                                              : Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[200]
                                                  : primaryColor,
                                          borderRadius: BorderRadius.horizontal(
                                              left: Radius.circular(24)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'EN',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  context.locale.languageCode ==
                                                          'en'
                                                      ? Colors.white
                                                      : Colors.green,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await context
                                            .setLocale(Locale('th', 'TH'));
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 24),
                                        decoration: BoxDecoration(
                                          color: context.locale.languageCode ==
                                                  'th'
                                              ? Colors.green
                                              : Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[200]
                                                  : primaryColor,
                                          borderRadius: BorderRadius.horizontal(
                                              right: Radius.circular(24)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'TH',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  context.locale.languageCode ==
                                                          'th'
                                                      ? Colors.white
                                                      : Colors.green,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ),
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
          if (_isUpdating)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color:
                    const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.2),
                child: Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? primaryColor
                          : Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
