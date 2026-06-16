import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/widgets/sameway_banner.dart';

enum _ImagePickAction { camera, gallery, remove }

/// Profile photo row — wireframe v2 horizontal layout.
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
                  color: AppColors.textPrimary,
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
      SamewayBanner.showError(
        context,
        source == ImageSource.camera
            ? 'Could not open camera. Check permissions or try gallery.'
            : 'Could not open gallery.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showSourceSheet,
          child: _image != null
              ? Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FutureBuilder<Uint8List>(
                    future: _image!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Text(widget.icon, style: const TextStyle(fontSize: 30)),
                        ),
                      );
                    },
                  ),
                )
              : SizedBox(
                  width: 80,
                  height: 80,
                  child: _DashedAvatarPlaceholder(icon: widget.icon),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _image != null ? 'Change Photo' : widget.title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _showSourceSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Text(
                    'Choose Photo',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedAvatarPlaceholder extends StatelessWidget {
  const _DashedAvatarPlaceholder({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(),
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 30))),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = AppColors.surfaceMuted,
    );

    final paint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dash = 5.0;
    const gap = 4.0;
    final circumference = 2 * 3.14159265 * radius;
    var distance = 0.0;
    var drawing = true;

    while (distance < circumference) {
      final segment = drawing ? dash : gap;
      if (drawing) {
        final startAngle = (distance / radius) - (3.14159265 / 2);
        final sweep = segment / radius;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweep,
          false,
          paint,
        );
      }
      distance += segment;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
