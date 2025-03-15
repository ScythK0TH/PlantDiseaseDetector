import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isFlashOn = false;

  void toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });

    // TODO ใส่ฟังก์ชันสำหรับปิด-เปิด Flash
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(15.0),
        )),
        backgroundColor: Color(0xFF464646),
        leading: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_back,
              color: Color(0xFFFFFFFF),
            )),
        title: Text(
          'DISEASE DETECTOR',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              toggleFlash();
            },
            icon: Icon(
                _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: Color(0xFFFFFFFF)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: Center(
              child: Container(
                width: screenWidth * 1.0,
                height: screenHeight * 1.0,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 48, 56, 102),
                    borderRadius: BorderRadius.circular(15.0)),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.crop_free_outlined,
                        size: 400,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ))
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        child: BottomAppBar(
          height: screenHeight * 0.12,
          color: Color(0xFF464646),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.cameraswitch,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.circle_outlined,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                  Positioned(
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.circle_rounded, // ไอคอนที่ซ้อนทับ
                        color: Colors.white,
                        size: 54,
                      ),
                    ),
                  ),
                  Positioned(
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.eco, // ไอคอนที่ซ้อนทับ
                        color: Color(0xFF27AC3C),
                        size: 45,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.photo_outlined,
                    color: Colors.white,
                    size: 50,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
