import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'product.dart';
class ReelScreen extends StatefulWidget {
  final int categoryID;
  final VoidCallback onBack;

  const ReelScreen({Key? key, required this.categoryID, required this.onBack})
      : super(key: key);

  @override
  _ReelScreenState createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    )..initialize().then((_) {
      _controller.setLooping(true);
      _controller.play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: _controller.value.isInitialized
                    ? VideoPlayer(_controller)
                    : Center(child: CircularProgressIndicator()),
              ),
              Positioned(
                top: 20,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: widget.onBack,
                ),
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
                            builder: (context) => ProductScreen(productId: "1"),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'Category ${widget.categoryID}',
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
                      'We all know how important it is to exercise, especially...',
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
        ),
      ),
    );
  }
}