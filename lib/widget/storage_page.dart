import 'dart:convert';
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_pdd/ui/responsive.dart';
import 'details_page.dart';
import 'package:project_pdd/main.dart';
import 'package:project_pdd/ui/styles.dart';

class StoragePage extends StatefulWidget {
  final String userId; // Pass the logged-in user's _id
  const StoragePage({required this.userId, super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> with RouteAware {
  List<Map<String, dynamic>> _plants = [];
  List<Map<String, dynamic>> _allPlants = [];
  bool _isLoading = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String selectedButton = 'Latest';

  @override
  void initState() {
    super.initState();
    _fetchAllPlants();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    // Called when this route is popped to and the previous route is visible.
    setState(() {});
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<void> _fetchAllPlants() async {
    setState(() => _isLoading = true);
    try {
      final db = MongoService();
      final collection = db.plantCollection;
      final query = {'userId': mongo.ObjectId.fromHexString(widget.userId)};
      final plants = await collection!.find(query).toList();
      if (!mounted) return;
      // Optionally decode images for each plant if needed
      for (var plant in plants) {
        if (plant['image'] != null) {
          try {
            plant['decodedImage'] = base64Decode(plant['image']);
          } catch (e) {
            plant['decodedImage'] = null;
          }
        } else {
          plant['decodedImage'] = null;
        }
      }
      setState(() {
        _allPlants = plants;
        _plants = plants;
      });
      imageCountUpdateNotifier.value = _plants.length;
    } catch (e) {
      print('Error fetching plants: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    final search = value.trim().toLowerCase();
    setState(() {
      _plants = search.isEmpty
          ? List<Map<String, dynamic>>.from(_allPlants)
          : _allPlants.where((plant) {
              final title = plant['title']?.toString().toLowerCase() ?? '';
              return title.contains(search);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดค่าตัวแปร responsive ก่อน
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    int crossAxisCount;
    double crossAxisSpacing;
    double mainAxisSpacing;
    double childAspectRatio;

    if (Responsive.isSmallMobile(context)) {
      crossAxisCount = 2;
      crossAxisSpacing = screenWidth * 0.03;
      mainAxisSpacing = screenHeight * 0.02;
      childAspectRatio = 0.9;
    } else if (Responsive.isMobile(context)) {
      crossAxisCount = 2;
      crossAxisSpacing = screenWidth * 0.02;
      mainAxisSpacing = screenHeight * 0.015;
      childAspectRatio = 0.95;
    } else if (Responsive.isTablet(context)) {
      crossAxisCount = 4;
      crossAxisSpacing = screenWidth * 0.02;
      mainAxisSpacing = screenHeight * 0.025;
      childAspectRatio = 0.9;
    } else {
      crossAxisCount = 4;
      crossAxisSpacing = screenWidth * 0.015;
      mainAxisSpacing = screenHeight * 0.02;
      childAspectRatio = 0.8;
    }

    // Filter and sort plants based on selectedButton
    List<Map<String, dynamic>> displayPlants;
    if (selectedButton == 'Latest') {
      displayPlants = List<Map<String, dynamic>>.from(_plants)
        ..sort((a, b) {
          final aTime = a['date'] is DateTime
              ? a['date']
              : DateTime.tryParse(a['date']?.toString() ?? '') ??
                  DateTime(1970);
          final bTime = b['date'] is DateTime
              ? b['date']
              : DateTime.tryParse(b['date']?.toString() ?? '') ??
                  DateTime(1970);
          return bTime.compareTo(aTime); // Descending
        });

      // กำหนดจำนวนภาพล่าสุดตาม crossAxisCount
      int latestCount;
      if (crossAxisCount == 2) {
        latestCount = 4;
      } else if (crossAxisCount == 4) {
        latestCount = 8;
      } else {
        latestCount = 4; // fallback
      }
      if (displayPlants.length > latestCount) {
        displayPlants = displayPlants.take(latestCount).toList();
      }
    } else {
      displayPlants = _plants;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Exit', style: AppTheme.mediumTitle(context)).tr(),
              content: Text('Are you sure you want to logout?',
                      style: AppTheme.smallContent(context))
                  .tr(),
              backgroundColor: AppTheme.themedBgColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36.0),
              ),
              actions: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.themedBgIconColor(context), // หรือ gradient ที่ต้องการสำหรับ Cancel
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style:
                          AppTheme.smallContent(context, color: AppTheme.themedIconColor(context)),
                    ).tr(),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.alertGradient,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12), // ปรับขนาดปุ่ม
                    ),
                    onPressed: () {
                      clearLoginState();
                      SystemNavigator.pop();
                    },
                    child: Text(
                      'Logout',
                      style:
                          AppTheme.smallContent(context, color: Colors.white),
                    ).tr(),
                  ),
                ),
              ],
            ),
          );
          if (shouldExit == true) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _isSearching
                          ? Container(
                              decoration: BoxDecoration(
                                color: AppTheme.themedBgIconColor(context),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0.0), // ลด padding
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Search plants...'.tr(),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.close,
                                              color: AppTheme.themedIconColor(
                                                  context)),
                                          onPressed: () {
                                            setState(() {
                                              _searchController.clear();
                                              _plants = List<
                                                      Map<String,
                                                          dynamic>>.from(
                                                  _allPlants);
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                onChanged: (value) {
                                  _onSearchChanged(value);
                                  setState(() {});
                                },
                                style: TextStyle(
                                  color: AppTheme.themedIconColor(context),
                                ),
                              ),
                            )
                          : Text(
                              'Gallery'.tr(),
                              style: AppTheme.largeTitle(context),
                              textAlign: TextAlign.left,
                            ),
                    ),
                  ),
                  if (_isSearching)
                    SizedBox(
                      width: 8.0,
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSearching)
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.themedBgIconColor(context),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back,
                                color: AppTheme.themedIconColor(context),
                                size: 24.0),
                            onPressed: () {
                              setState(() {
                                _isSearching = false;
                                _searchController.clear();
                                _plants =
                                    List<Map<String, dynamic>>.from(_allPlants);
                              });
                            },
                            splashRadius: 36.0,
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.themedBgIconColor(context),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.search,
                                color: AppTheme.themedIconColor(context),
                                size: 24.0),
                            onPressed: () {
                              setState(() => _isSearching = true);
                            },
                            splashRadius: 36.0,
                          ),
                        ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.themedBgIconColor(context),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.exit_to_app,
                            color: AppTheme.themedIconColor(context),
                            size: 24.0,
                          ),
                          onPressed: () {
                            themeModeNotifier.value = ThemeMode.light;
                            SystemNavigator.pop();
                          },
                          splashRadius: 36.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            centerTitle: false,
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.themedIconColor(context)))
              : _plants.isEmpty
                  ? Center(child: Text('No plants found.', style: AppTheme.mediumContent(context)).tr())
                  : _buildPlantGridView(
                      context,
                      displayPlants,
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: childAspectRatio,
                    )),
    );
  }

  Widget _buildPlantGridView(
    BuildContext context,
    List<Map<String, dynamic>> displayPlants, {
    required int crossAxisCount,
    required double crossAxisSpacing,
    required double mainAxisSpacing,
    required double childAspectRatio,
  }) {
    final isSmallMobile = Responsive.isSmallMobile(context);
    final isMobile = Responsive.isMobile(context);
    final isTabletOrDesktop =
        Responsive.isTablet(context) || Responsive.isDesktop(context);

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

    return Padding(
      padding: isTabletOrDesktop
          ? const EdgeInsets.symmetric(
              horizontal: 100.0) // Desktop: padding มากขึ้น
          : const EdgeInsets.symmetric(
              horizontal: 20.0), // Mobile/Tablet: padding ปกติ
      child: Column(
        children: [
          SizedBox(
            height: 8.0,
          ),
          if (selectedButton == 'Latest' && !_isSearching)
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: isSmallMobile
                    ? 120.00
                    : 240.00, // Set a default minHeight value
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.secondaryGradient,
                borderRadius: BorderRadius.circular(36.0),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: isMobile || isSmallMobile
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,'.tr(),
                        style: AppTheme.mediumContent(context),
                      ),
                      Text(
                        //MongoDB แก้ไขตรงนี้ สำหรับแสดงชื่อ User
                        'OscarPattyThun',
                        style: AppTheme.largeTitle(context),
                      ),
                      SizedBox(height: 8.0),
                      if (isMobile || isSmallMobile)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // เพื่มในอนาคต เรื่องการตรวจสอบ Internet สำหรับ Cloud Storage
                            Text(
                              'Cloud Storage',
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // เพื่มในอนาคต เรื่องการตรวจสอบ Internet สำหรับ Cloud Storage
                            Text(
                              'Cloud Storage',
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
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: selectedButton == 'Latest'
                        ? AppTheme.primaryGradient
                        : null,
                    color: selectedButton == 'Latest'
                        ? null
                        : AppTheme.darkInverse,
                    borderRadius: BorderRadius.circular(36.0),
                  ),
                  child: TextButton(
                    onPressed: () => setState(() => selectedButton = 'Latest'),
                    child: Text(
                      'Latest'.tr(),
                      style: selectedButton == 'Latest'
                          ? AppTheme.smallTitle(context)
                          : AppTheme.smallTitle(context, color: AppTheme.dark),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 8.0,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: selectedButton == 'All'
                        ? AppTheme.primaryGradient
                        : null,
                    color:
                        selectedButton == 'All' ? null : AppTheme.darkInverse,
                    borderRadius: BorderRadius.circular(36.0),
                  ),
                  child: TextButton(
                    onPressed: () => setState(() => selectedButton = 'All'),
                    child: Text(
                      'All'.tr(),
                      style: selectedButton == 'All'
                          ? AppTheme.smallTitle(context)
                          : AppTheme.smallTitle(context, color: AppTheme.dark),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: _buildGrid(
              context,
              displayPlants,
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGrid(
      BuildContext context, List<Map<String, dynamic>> displayPlants,
      {required int crossAxisCount,
      required double crossAxisSpacing,
      required double mainAxisSpacing,
      required double childAspectRatio}) {
    return GridView.builder(
      shrinkWrap: false,
      padding: const EdgeInsets.only(bottom: 90),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: displayPlants.length,
      itemBuilder: (context, index) {
        final plant = displayPlants[index];
        return _buildPlantItems(context, plant);
      },
    );
  }

  Widget _buildPlantItems(BuildContext context, Map<String, dynamic> plant) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailsPage(plant: plant, userId: widget.userId),
          ),
        );
        if (result == true) {
          setState(() {
            final plantId = plant['_id'];
            _plants.removeWhere((p) => p['_id'] == plantId);
            _allPlants.removeWhere((p) => p['_id'] == plantId);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36.0),
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildPlantImages(context, plant),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: (Responsive.isSmallMobile(context) ||
                      Responsive.isMobile(context) ||
                      Responsive.isTablet(context))
                  ? Text(
                      plant['title'] ?? 'Unknown Plant'.tr(),
                      style: AppTheme.smallContent(context),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: true,
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        plant['title'] ?? 'Unknown Plant'.tr(),
                        style: AppTheme.smallContent(context),
                        textAlign: TextAlign.start,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantImages(BuildContext context, Map<String, dynamic> plant) {
    final screenWidth = MediaQuery.of(context).size.width;

    late final double iconSize;
    late final double imageSize;
    if (Responsive.isSmallMobile(context)) {
      iconSize = screenWidth * 0.3;
      imageSize = screenWidth * 0.9;
    } else if (Responsive.isMobile(context)) {
      iconSize = screenWidth * 0.22;
      imageSize = screenWidth * 0.9;
    } else if (Responsive.isTablet(context)) {
      iconSize = screenWidth * 0.18;
      imageSize = screenWidth * 0.7;
    } else {
      iconSize = screenWidth * 0.15;
      imageSize = screenWidth * 0.7;
    }

    final bgColor = AppTheme.themedIconColor(context);
    final borderRadius = BorderRadius.circular(36.0);

    Widget imageWidget;
    if (plant['decodedImage'] == null) {
      imageWidget = Center(
        child: Icon(
          Icons.image,
          size: iconSize,
          color: AppTheme.themedIconColor(context),
        ),
      );
    } else {
      imageWidget = Image.memory(
        plant['decodedImage'],
        fit: BoxFit.cover,
        width: imageSize, // กำหนดขนาดภาพ
        height: imageSize, // กำหนดขนาดภาพ
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.error,
            color: AppTheme.alertColor,
          );
        },
      );
    }

    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageWidget,
    );
  }
}
