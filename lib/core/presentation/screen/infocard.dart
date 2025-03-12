import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// InfoCard (StatelessWidget)
/// Displays general country info and, if a YouTube video is available,
/// shows a "Watch Video" button to open a modal bottom sheet.
class InfoCard extends StatelessWidget {
  /// Data map containing various fields, including 'youtubeVideoId'
  final Map<String, dynamic> data;

  const InfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Retrieve the YouTube video ID from the data map
    final youtubeVideoId = data['youtubeVideoId'] as String?;

    return SizedBox(
      width: MediaQuery.of(context).size.width, // Full width
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                data['title'] ?? 'No Title Available',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Descriptions
            Text(
              data['description1'] ?? 'No description available.',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Text(
              data['description2'] ?? 'No description available.',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Text(
              data['description3'] ?? 'No description available.',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Text(
              data['description4'] ?? 'No description available.',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            // Show "Watch Video" button if a valid YouTube video ID is provided
            if (youtubeVideoId != null && youtubeVideoId.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text("Video Ansehen"),
                  onPressed: () {
                    // Show the bottom sheet with the YouTube IFrame player
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) {
                        return YouTubeBottomSheet(
                          youtubeVideoId: youtubeVideoId,
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// YouTubeBottomSheet (StatefulWidget)
/// Displays a YouTube IFrame player in a bottom sheet.
class YouTubeBottomSheet extends StatefulWidget {
  final String youtubeVideoId;

  const YouTubeBottomSheet({super.key, required this.youtubeVideoId});

  @override
  State<YouTubeBottomSheet> createState() => _YouTubeBottomSheetState();
}

class _YouTubeBottomSheetState extends State<YouTubeBottomSheet> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.youtubeVideoId,
      autoPlay: false,
      params: YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  @override
  void dispose() {
    // It's recommended to close or dispose the controller
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This is the bottom sheet layout, similar to before
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Video Ansehen",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // The YouTube IFrame player widget
          Expanded(
            child: YoutubePlayer(
              controller: _controller,
            ),
          ),

          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Schließen"),
          ),
        ],
      ),
    );
  }
}