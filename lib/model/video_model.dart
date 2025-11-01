// lib/model/video_model.dart
class Video {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String description;

  Video({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.description,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    // The search.list item's structure: item['id']['videoId'], item['snippet']
    final snippet = json['snippet'] ?? {};
    return Video(
      videoId: json['id']?['videoId'] ?? '',
      title: snippet['title'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
      thumbnailUrl: (snippet['thumbnails']?['medium']?['url']) ??
          (snippet['thumbnails']?['default']?['url']) ??
          '',
      description: snippet['description'] ?? '',
    );
  }
}
