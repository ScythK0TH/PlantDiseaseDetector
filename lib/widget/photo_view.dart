import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_pdd/style.dart';

class PhotoViewScreen extends StatelessWidget {
  final File? file;
  const PhotoViewScreen({super.key, this.file});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.6,
      height: screenHeight * 0.35,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(36),
      ),
      clipBehavior: Clip.antiAlias, 
      child: (file == null)
          ? _buildEmptyView()
          : Image.file(file!, fit: BoxFit.cover),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Text(
        'Please pick a photo',
        style: subTitleTextStyleWhite(fontWeight: FontWeight.bold),
      ),
    );
  }
}
