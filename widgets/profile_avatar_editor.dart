import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/uploaded_file_model.dart';
import '../providers/profile_avatar_provider.dart';
import '../utils/helpers.dart';
import 'avatar_source_sheet.dart';


class ProfileAvatarEditor extends StatelessWidget {
  const ProfileAvatarEditor({
    super.key,
    required this.imageUrl,
    required this.entityType,
    required this.onUploaded,
    this.zone = 'mainimage',
    this.radius = 65,
  });

  final String imageUrl;
  final String entityType;
  final String zone;
  final double radius;

  final Future<void> Function(UploadedFileModel uploadedFile) onUploaded;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileAvatarProvider(
        entityType: entityType,
        zone: zone,
        onUploaded: onUploaded,
      ),
      child: _ProfileAvatarEditorView(imageUrl: imageUrl, radius: radius),
    );
  }
}

class _ProfileAvatarEditorView extends StatelessWidget {
  const _ProfileAvatarEditorView({
    required this.imageUrl,
    required this.radius,
  });

  final String imageUrl;
  final double radius;

  static const Color _badgeBackground = Color(0xFFC4ECFF);
  static const Color _badgeIconColor = Color(0xFF215783);
  static const Color _placeholderBackground = Color(0xFFD6EDFF);

  Future<void> _onEditTap(BuildContext context) async {
    final provider = context.read<ProfileAvatarProvider>();
    if (provider.isUploading) return;

    final ImageSource? source = await AvatarSourceSheet.show(context);
    if (source == null) return;

    final bool saved = await provider.pickAndUpload(source);

    if (!saved) {
      final String? error = provider.error;
      if (error != null) {
        showNativeSnackBar(error, Colors.redAccent);
        provider.clearError();
      }
      return;
    }

    showNativeSnackBar('Profile photo updated', Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileAvatarProvider>();
    final bool isUploading = provider.isUploading;

    final ImageProvider? avatarImage = provider.localPreview != null
      ? FileImage(provider.localPreview!)
      : (imageUrl.trim().isEmpty ? null : NetworkImage(imageUrl));

    return Semantics(
      button: true,
      label: 'Change profile photo',
      child: GestureDetector(
        onTap: isUploading ? null : () => _onEditTap(context),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: radius,
                    backgroundColor: _placeholderBackground,
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                      ? Icon(
                          Icons.person_outline,
                          size: radius,
                          color: _badgeIconColor,
                        )
                      : null,
                  ),
                  if (isUploading)
                    Container(
                      width: radius * 2,
                      height: radius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _badgeBackground,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                isUploading ? Icons.hourglass_top_outlined : Icons.edit_outlined,
                size: 16,
                color: _badgeIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
