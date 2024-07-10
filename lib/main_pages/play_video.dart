import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayVideo extends StatefulWidget {
  final String videoTitle;
  final String username;
  final String daysAgo;
  final String category;
  final String videoUrl;

  const PlayVideo({
    super.key,
    required this.videoTitle,
    required this.username,
    required this.daysAgo,
    required this.category,
    required this.videoUrl,
  });

  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    print(Uri.parse(widget.videoUrl));
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppName'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Video area
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    color: Colors.black,
                      width: 300,
                      height: 500,
                      child: VideoPlayer(_controller),
                  );
                } else {
                  return Container(
                    color: Colors.black,
                    width: 300,
                    height: 500,
                    child: const Center(child: CircularProgressIndicator(color: Colors.white,)
                    )
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Video details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.videoTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("100K views"),
                      Text(widget.daysAgo),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text("Category: ${widget.category}"),
                ],
              ),
            ),
            const Divider(thickness: 1),

            // User info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.person), // Replace with your asset path
                  ),
                  const SizedBox(width: 10),
                  Text(widget.username),
                ],
              ),
            ),
            const Divider(thickness: 1),

            // Comments section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Comments",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  // List view for comments (not implemented in this example)
                  Text("Implement comment list here"),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Leave a comment",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
