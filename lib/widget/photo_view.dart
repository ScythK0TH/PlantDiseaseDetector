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
      width: screenWidth * 1.8,
      height: 300,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 50,
              color: bgColor,
            ),
            const SizedBox(height: 20),
            Text(
              'Please pick a photo',
              style: descTextStyleWhite(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
