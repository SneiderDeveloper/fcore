/// File returned by `/media/v1/files/upload-with-details`.
class UploadedFileModel {
  const UploadedFileModel({this.id, this.publicUrl});

  /// Id to save on the entity that owns the file.
  final dynamic id;
  final String? publicUrl;

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) {
    return UploadedFileModel(
      id: json['id'],
      publicUrl: json['publicUrl'],
    );
  }

  /// Builds the model from the upload response, wrapped in `data` as usual.
  static UploadedFileModel? fromResponse(dynamic response) {
    if (response is! Map) return null;

    final data = response['data'] ?? response;
    if (data is! Map) return null;

    return UploadedFileModel.fromJson(Map<String, dynamic>.from(data));
  }
}
