import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:project_pdd/ui/responsive.dart';
import 'package:project_pdd/ui/styles.dart';

class PhotoViewScreen extends StatelessWidget {
  final File? file;
  const PhotoViewScreen({super.key, this.file});

  @override
  Widget build(BuildContext context) {
    final isSmallMobile = Responsive.isSmallMobile(context);
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: isSmallMobile || isMobile ? double.infinity : 500,
      height: isSmallMobile || isMobile ? 400 : 500,
      decoration: BoxDecoration(
        color: AppTheme.themedBgIconColor(context),
        borderRadius: BorderRadius.circular(36),
      ),
      clipBehavior: Clip.antiAlias,
      child: (file == null)
          ? _buildEmptyView(context)
          : Image.file(file!, fit: BoxFit.cover),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
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
              color: AppTheme.themedIconColor(context),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Please pick a photo'.tr(),
              style: AppTheme.mediumTitle(context),
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
