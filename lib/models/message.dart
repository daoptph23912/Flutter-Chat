class Message {
  final String id;
  final String content;
  final List<FileData> files;
  final List<ImageData> images;
  final int isSend;
  final DateTime createdAt;
  final int messageType;

  Message({
    required this.id,
    required this.content,
    required this.files,
    required this.images,
    required this.isSend,
    required this.createdAt,
    required this.messageType,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Xử lý danh sách các file
    List<FileData> files = [];
    if (json.containsKey('Files')) {
      files = (json['Files'] as List<dynamic>).map((fileJson) {
        return FileData.fromJson(fileJson);
      }).toList();
    }

    // Xử lý danh sách các ảnh
    List<ImageData> images = [];
    if (json.containsKey('Images')) {
      images = (json['Images'] as List<dynamic>).map((imageJson) {
        return ImageData.fromJson(imageJson);
      }).toList();
    }

    return Message(
      id: json['id'],
      content: json['Content'] ?? '',
      files: files,
      images: images,
      isSend: json['isSend'],
      createdAt: DateTime.parse(json['CreatedAt'] ?? ''),
      messageType: json['MessageType'] ?? 0,
    );
  }
}

class FileData {
  final String urlFile;
  final String fileName;
  final String id;

  FileData({
    required this.urlFile,
    required this.fileName,
    required this.id,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      urlFile: json['urlFile'] ?? '',
      fileName: json['FileName'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}

class ImageData {
  final String urlImage;
  final String fileName;
  final String id;

  ImageData({
    required this.urlImage,
    required this.fileName,
    required this.id,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      urlImage: json['urlImage'] ?? '',
      fileName: json['FileName'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}
