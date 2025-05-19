import 'dart:convert';
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/constant.dart';
import 'package:project_pdd/style.dart';
import 'package:project_pdd/widget/first_page.dart';
import 'package:project_pdd/widget/profile_page.dart';
import 'package:project_pdd/widget/recogniser.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      final db = await mongo.Db.create(MONGO_URL);
      await db.open();
      final collection = db.collection('plants');
      final query = {'userId': mongo.ObjectId.fromHexString(widget.userId)};
      final plants = await collection.find(query).toList();
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
      await db.close();
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
    // Filter and sort plants based on selectedButton
    List<Map<String, dynamic>> displayPlants;
    if (selectedButton == 'Latest') {
      displayPlants = List<Map<String, dynamic>>.from(_plants)
        ..sort((a, b) {
          final aTime = a['date'] is DateTime
              ? a['date']
              : DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(1970);
          final bTime = b['date'] is DateTime
              ? b['date']
              : DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(1970);
          return bTime.compareTo(aTime); // Descending
        });
      if (displayPlants.length > 4) {
        displayPlants = displayPlants.take(4).toList();
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
              title: Text('Exit').tr(),
              content: Text('Are you sure you want to logout?').tr(),
              backgroundColor: Theme.of(context).brightness == Brightness.dark ? primaryColor : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36.0),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel').tr(),
                ),
                TextButton(
                  onPressed: () {
                    clearLoginState();
                    SystemNavigator.pop();
                  },
                  child: Text('Logout').tr(),
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
          automaticallyImplyLeading: false,
          systemOverlayStyle: Theme.of(context).brightness == Brightness.dark 
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
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
                        hintText: 'Search plants...'.tr(),
                        border: InputBorder.none,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  )
                else
                  Text(
                    'Gallery'.tr(),
                    style: subTitleTextStyleDark(context, fontWeight: FontWeight.bold),
                  ),
                Spacer(),
                if (_isSearching)
                  IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor, size: 24.0),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                        _plants = List<Map<String, dynamic>>.from(_allPlants); // Reset to all plants
                      });
                    },
                  )
                else
                  IconButton(
                    icon: Icon(Icons.search, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor, size: 24.0),
                    onPressed: () {
                      setState(() => _isSearching = true);
                    },
                  ),
                IconButton(
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                    size: 24.0,
                  ),
                  onPressed: () {
                    themeModeNotifier.value = ThemeMode.light;
                    //Exit the app
                    SystemNavigator.pop();
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
                ? Center(child: Text('No plants found.').tr())
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(36.0)),
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() => selectedButton = 'Latest');
                                },
                                child: Text(
                                  'Latest'.tr(),
                                  style: selectedButton == 'Latest'
                                      ? successTextStyle(fontWeight: FontWeight.bold)
                                      : descTextStyleDark(context, fontWeight: FontWeight.normal),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() => selectedButton = 'All');
                                },
                                child: Text(
                                  'All'.tr(),
                                  style: selectedButton == 'All'
                                      ? successTextStyle(fontWeight: FontWeight.bold)
                                      : descTextStyleDark(context, fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: displayPlants.length,
                            itemBuilder: (context, index) {
                              final plant = displayPlants[index];
                              return GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsPage(plant: plant, userId: widget.userId),
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
                                      if (plant['decodedImage'] == null)
                                        Container(
                                          width: double.infinity,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                                            borderRadius: BorderRadius.circular(36.0),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.image,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          width: double.infinity,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                                            borderRadius: BorderRadius.circular(36.0),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Image.memory(
                                            plant['decodedImage'],
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
                                      Text(
                                        plant['title'] ?? 'Unknown Plant'.tr(),
                                        style: descTextStyleDark(context, fontWeight: FontWeight.normal),
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
      ),
    );
  }
}
