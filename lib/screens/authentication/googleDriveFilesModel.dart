class GoogleDriveFilesResponse {
  final bool status;
  final String message;
  final List<GoogleDriveFile> data;

  GoogleDriveFilesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GoogleDriveFilesResponse.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    final bool parsedStatus = rawStatus == true ||
        rawStatus == 1 ||
        rawStatus == 'true' ||
        rawStatus == 'success';

    return GoogleDriveFilesResponse(
      status: parsedStatus,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => GoogleDriveFile.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class GoogleDriveFile {
  final String id;
  final String fileName;
  final String mimeType;
  final String uploadedAt;
  final String webViewLink;
  final String webContentLink;
  final String? thumbnailLink;
final String? isFolder;
final String? folderId;
final String? fileId;
  GoogleDriveFile({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.uploadedAt,
    required this.webViewLink,
    required this.webContentLink,
    this.thumbnailLink,
     this.isFolder,
      this.folderId,
      this.fileId,
  });

  // bool get isFolder =>
  //     mimeType.toLowerCase().contains('folder') ||
  //     mimeType == 'application/vnd.google-apps.folder';

  factory GoogleDriveFile.fromJson(Map<String, dynamic> json) {
    return GoogleDriveFile(
      id: json['file_id'] ?? json['id'] ?? '',
      fileName: json['file_name'] ?? json['name'] ?? '',
      mimeType: json['mimeType'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
      webViewLink: json['webViewLink'] ?? '',
      webContentLink: json['webContentLink'] ?? '',
      thumbnailLink: json['thumbnailLink'],
        isFolder: json['is_folder'],
          folderId: json['folder_id'],
            fileId: json['file_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_id': id,
      'file_name': fileName,
      'mimeType': mimeType,
      'uploaded_at': uploadedAt,
      'webViewLink': webViewLink,
      'webContentLink': webContentLink,
      'thumbnailLink': thumbnailLink,
      'is_folder': isFolder,
      'folder_id': folderId,
      'file_id': fileId,
    };
  }
}
