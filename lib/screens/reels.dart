import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'product.dart';

class ReelScreen extends StatefulWidget {
  const ReelScreen({Key? key}) : super(key: key);

  @override
  _ReelScreenState createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  late List<VideoPlayerController> _controllers;
  PageController _pageController = PageController();
  List<Map<String, String>> videos = [];
  bool isLoading = false;
  int page = 1;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _pageController.addListener(_onPageChanged);
    _fetchData();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    int newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPage) {
      _currentPage = newPage;
      _updatePlayback();
    }
  }

  void _updatePlayback() {
    for (int i = 0; i < _controllers.length; i++) {
      if (i == _currentPage) {
        if (_controllers[i].value.isInitialized) {
          _controllers[i].play();
        }
      } else {
        if (_controllers[i].value.isInitialized) {
          _controllers[i].pause();
        }
      }
    }
  }

  Future<void> _fetchData() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2));

    List<Map<String, String>> newVideos = List.generate(10, (index) {
      return {
        'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'productTitle': 'Product ${page * 10 + index}',
        'productId': '${page * 10 + index}',
        'productDescription': 'Description of product ${page * 10 + index}',
      };
    });

    for (var i = 0; i < newVideos.length; i++) {
      final videoData = newVideos[i];
      final controller = VideoPlayerController.network(videoData['videoUrl']!);

      await controller.initialize();
      controller.setLooping(true);

      if (i + (_controllers.length) == _currentPage) {
        controller.play();
      } else {
        controller.pause();
      }

      _controllers.add(controller);
    }

    setState(() {
      page++;
      videos.addAll(newVideos);
      isLoading = false;
    });
  }

  void addToWishlist() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added to Wishlist!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: addToWishlist,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: videos.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == videos.length) {
              return Center(child: CircularProgressIndicator());
            }

            final video = videos[index];
            final controller = _controllers[index];

            return Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: controller.value.isInitialized
                        ? VideoPlayer(controller)
                        : Center(child: CircularProgressIndicator()),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductScreen(productId: video['productId']!),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                video['productTitle']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'view',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          video['productDescription']!,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '🎵 Pump Up the Jam - Original Audio',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 150,
                    child: GestureDetector(
                      onTap: addToWishlist,
                      child: Column(
                        children: [
                          Icon(Icons.favorite, color: Colors.white, size: 30),
                          SizedBox(height: 5),
                          Text(
                            '1.2K',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}