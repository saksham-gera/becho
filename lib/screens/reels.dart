import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'product.dart';

class ReelScreen extends StatefulWidget {
  const ReelScreen({Key? key}) : super(key: key);

  @override
  _ReelScreenState createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  late List<VideoPlayerController> _controllers;
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> videos = [];
  bool isLoading = false;
  int page = 1;
  int _currentPage = 0;
  String _currVideoId = 'abc';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

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

    final userId = await _storage.read(key: 'userID');
    print(userId);
    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final url = 'https://bechoserver.vercel.app/reels/$userId';
      final response = await http.get(Uri.parse(url));
      print(url);
      print(json.decode(response.body));
      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body)['data'];

        List<Map<String, dynamic>> newVideos = responseData.map((item) {
          return {
            'videoUrl': item['url'],
            'productTitle': 'Product ${item['product_id']}',
            'productId': item['product_id'],
            'productDescription': item['description'] ?? 'No description available',
            'wishlisted': item['wishlisted'],
            'in_wishlist' : item['in_wishlist'],
          };
        }).toList();

        for (var i = 0; i < newVideos.length; i++) {
          final videoData = newVideos[i];
          final controller = VideoPlayerController.networkUrl(Uri.parse(videoData['videoUrl']));

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
          videos.addAll(newVideos);
        });
      }
    } catch (e) {
      print("Error fetching reels: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> addToWishlist(String? productId) async {
    final userId = await _storage.read(key: 'userID');
    if (userId == null || productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to wishlist. Missing data.')),
      );
      return;
    }

    const url = 'https://bechoserver.vercel.app/wishlist/handle';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'id': productId}),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          videos[_currentPage]['in_wishlist'] = !videos[_currentPage]['in_wishlist'];
          if (videos[_currentPage]['in_wishlist']) {
            videos[_currentPage]['wishlisted'] += 1;
          } else {
            videos[_currentPage]['wishlisted'] -= 1;
          }
        });
        addToWishlist(videos[_currentPage]['productId']);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: videos.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == videos.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final video = videos[index];
            _currVideoId = video['productId'];
            final controller = _controllers[index];
            return Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: controller.value.isInitialized
                        ? VideoPlayer(controller)
                        : const Center(child: CircularProgressIndicator()),
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
                                builder: (context) => ProductScreen(productId: video['productId']),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  video['productTitle']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'view',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          video['productDescription']!,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        const Text(
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
                      onTap: () {
                        addToWishlist(_currVideoId);
                        setState(() {
                          video['in_wishlist'] = !video['in_wishlist'];
                          if(video['in_wishlist']) {
                            video['wishlisted'] += 1;
                          } else {
                            video['wishlisted'] -= 1;
                          }
                        });
                      },
                      child: Column(
                        children: [
                          Icon(Icons.favorite, color: video['in_wishlist'] ? Colors.red : Colors.white, size: 30),
                          const SizedBox(height: 5),
                          Text(
                            '${video['wishlisted']}',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
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