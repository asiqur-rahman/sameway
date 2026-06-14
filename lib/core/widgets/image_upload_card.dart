import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';

enum _ImagePickAction { camera, gallery, remove }

class ImageUploadCard extends StatefulWidget {
  const ImageUploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = '📷',
    this.onImageChanged,
  });

  final String title;
  final String subtitle;
  final String icon;
  final ValueChanged<XFile?>? onImageChanged;

  @override
  State<ImageUploadCard> createState() => _ImageUploadCardState();
}

class _ImageUploadCardState extends State<ImageUploadCard> {
  final _picker = ImagePicker();
  XFile? _image;

  Future<void> _showSourceSheet() async {
    final action = await showModalBottomSheet<_ImagePickAction>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Add photo',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: Text('Take photo', style: GoogleFonts.inter(fontSize: 15)),
                onTap: () => Navigator.pop(context, _ImagePickAction.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('Choose from gallery', style: GoogleFonts.inter(fontSize: 15)),
                onTap: () => Navigator.pop(context, _ImagePickAction.gallery),
              ),
              if (_image != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: Text('Remove photo', style: GoogleFonts.inter(fontSize: 15)),
                  onTap: () => Navigator.pop(context, _ImagePickAction.remove),
                ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == _ImagePickAction.remove) {
      setState(() => _image = null);
      widget.onImageChanged?.call(null);
      return;
    }

    final source = action == _ImagePickAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (!mounted || picked == null) return;
      setState(() => _image = picked);
      widget.onImageChanged?.call(picked);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Could not open camera. Check permissions or try gallery.'
                : 'Could not open gallery.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSourceSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _image != null ? AppColors.primary : AppColors.border,
            width: _image != null ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FutureBuilder<Uint8List>(
                  future: _image!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        width: 96,
                        height: 96,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    return Image.memory(
                      snapshot.data!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Text('📷', style: TextStyle(fontSize: 32)),
                    );
                  },
                ),
              )
            else
              Text(widget.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            Text(
              _image != null ? 'Change Photo' : widget.title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
