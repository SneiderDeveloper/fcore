import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/uploaded_file_model.dart';
import '../services/media_service.dart';

/// Picks an avatar from the gallery/camera and uploads it to the media API.
class ProfileAvatarProvider extends ChangeNotifier {
  ProfileAvatarProvider({
    required this.entityType,
    required this.zone,
    this.onUploaded,
    MediaService? mediaService,
    ImagePicker? imagePicker,
  }) : _mediaService = mediaService ?? MediaService(),
       _imagePicker = imagePicker ?? ImagePicker();

  final String entityType;
  final String zone;

  final Future<void> Function(UploadedFileModel uploadedFile)? onUploaded;

  final MediaService _mediaService;
  final ImagePicker _imagePicker;

  File? _localPreview;
  bool _isUploading = false;
  String? _error;

  /// Local copy of the picked image, shown while the upload is in flight.
  File? get localPreview => _localPreview;
  bool get isUploading => _isUploading;
  String? get error => _error;

  /// Returns true when the picture was uploaded and saved.
  /// False when the user cancelled the picker or something failed.
  Future<bool> pickAndUpload(ImageSource source) async {
    if (_isUploading) return false;

    final XFile? picked = await _pickImage(source);
    if (picked == null) return false;

    _localPreview = File(picked.path);
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final uploadedFile = await _mediaService.uploadFileWithDetails(
        filePath: picked.path,
        entityType: entityType,
        zone: zone,
      );

      await onUploaded?.call(uploadedFile);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      // The picture was not saved: fall back to the stored image.
      _localPreview = null;
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    try {
      return await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
    } on PlatformException catch (e) {
      _error = e.code == 'camera_access_denied' || e.code == 'photo_access_denied'
        ? 'Grant access to your ${source == ImageSource.camera ? 'camera' : 'photos'} to update the picture'
        : 'The image could not be selected';
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'The image could not be selected';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
