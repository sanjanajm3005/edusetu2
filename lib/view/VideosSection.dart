import 'package:ai_edu_app/view/TopicProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../model/video_model.dart';
import '../controller/youtube_api_service.dart';
import 'ThemePrivider.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key, required String subject});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final List<Video> youtubeResults = [];
  bool _loading = false;
  late YouTubeApiService _youtubeService;
  String currentQuery = "";

  @override
  void initState() {
    super.initState();

    _youtubeService = YouTubeApiService(
      apiKey: "AIzaSyB9eidTJTU0VyErijXmdQZZ1Ec367Otg10",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoFetchForTopic();
    });
  }

  Future<void> _autoFetchForTopic() async {
    final topic = context.read<TopicProvider>().selectedTopic;
    final subject = context.read<TopicProvider>().selectedSubject;
    final query = (topic.isNotEmpty) ? "$subject $topic" : subject;
    if (query.trim().isEmpty) return;
    currentQuery = query;
    await fetchYouTubeVideos(query);
  }

  Future<void> fetchYouTubeVideos(String query) async {
    setState(() => _loading = true);
    try {
      // Add educational bias to query
      final eduQuery = "$query tutorial OR lesson OR course OR educational";

      // Fetch results using the education category (ID: 27)
      final results = await _youtubeService.searchVideos(
        eduQuery,
        videoCategoryId: "27",
      );

      // Filter out any videos that aren’t clearly educational
      final filtered = results.where((video) {
        final title = video.title.toLowerCase();
        final desc = video.description.toLowerCase();
        final channel = video.channelTitle.toLowerCase();

        return title.contains("tutorial") ||
            title.contains("lesson") ||
            title.contains("education") ||
            title.contains("course") ||
            desc.contains("tutorial") ||
            desc.contains("lesson") ||
            channel.contains("academy") ||
            channel.contains("education");
      }).toList();

      setState(() {
        youtubeResults
          ..clear()
          ..addAll(filtered);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching videos: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openYouTube(String videoId) async {
    final url = Uri.parse("https://www.youtube.com/watch?v=$videoId");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open YouTube.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subject = context.watch<TopicProvider>().selectedSubject;
    final topic = context.watch<TopicProvider>().selectedTopic;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeManager.topContainerColor,
        centerTitle: true,
        title: Text(
          "Study Videos",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              TextField(
                controller: TextEditingController(text: currentQuery),
                onSubmitted: (value) {
                  currentQuery = value;
                  fetchYouTubeVideos(value);
                },
                decoration: InputDecoration(
                  hintText:
                      "Search study videos (e.g., Algebra, Photosynthesis)...",
                  hintStyle: GoogleFonts.poppins(fontSize: 14),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : youtubeResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  size: 120,
                                  color: ThemeManager.topContainerColor,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No educational videos found.\nTry searching a different topic.",
                                  style: GoogleFonts.poppins(fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: youtubeResults.length,
                            itemBuilder: (context, index) {
                              final video = youtubeResults[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8),
                                elevation: 3,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () => _openYouTube(video.videoId),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                        ),
                                        child: Image.network(
                                          video.thumbnailUrl,
                                          width: 130,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            width: 130,
                                            height: 90,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                                Icons.broken_image),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                video.title,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                video.channelTitle,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
