import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/uploaded_file_model.dart';
import 'base_api_service.dart';

class MediaService extends BaseApiService {
  static final MediaService _instance = MediaService._internal();

  factory MediaService() => _instance;

  MediaService._internal();

  static const String _uploadWithDetailsRoute = '/media/v1/files/upload-with-details';

  Future<UploadedFileModel> uploadFileWithDetails({
    required String filePath,
    required String entityType,
    required String zone,
  }) async {
    final File file = File(filePath);
    if (!await file.exists()) {
      throw Exception('The selected file no longer exists');
    }

    final formData = FormData.fromMap({
      'entityType': entityType,
      'zone': zone,
      'file': await MultipartFile.fromFile(filePath),
    });

    try {
      final response = await postMultipart(_uploadWithDetailsRoute, formData);

      final uploadedFile = UploadedFileModel.fromResponse(response);
      if (uploadedFile == null) {
        throw Exception('The server did not return the uploaded file');
      }

      return uploadedFile;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }
}
