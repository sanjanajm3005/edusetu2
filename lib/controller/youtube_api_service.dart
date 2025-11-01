import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/video_model.dart';

class YouTubeApiService {
  final String apiKey;

  YouTubeApiService({required this.apiKey});

  // Updated method — supports optional videoCategoryId
  Future<List<Video>> searchVideos(String query, {String? videoCategoryId}) async {
    // If videoCategoryId is given, add it to the request
    final categoryParam = videoCategoryId != null ? "&videoCategoryId=$videoCategoryId" : "";

    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search'
      '?part=snippet'
      '&maxResults=25'
      '&q=$query'
      '&type=video'
      '$categoryParam'
      '&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>;
      return items.map((item) => Video.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch YouTube videos: ${response.reasonPhrase}');
    }
  }
}
