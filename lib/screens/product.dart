import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  final String imageUrl =
      'https://via.placeholder.com/150'; // Replace this with your reference image URL.
  final String productId;

  ProductScreen({required this.productId});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String? selectedStorageOption;
  String? selectedColorOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back and Favorite Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.favorite_border),
                            onPressed: () {},
                          ),
                        ],
                      ),

                      // Product Image
                      Center(
                        child: Image.network(
                          widget.imageUrl,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 250,
                            height: 250,
                            color: Colors.grey.shade200,
                            child: Icon(Icons.broken_image,
                                size: 50, color: Colors.grey),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Product Title and On Sale Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Xbox Series X',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              'On sale',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Ratings and Reviews
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text('4.8'),
                          SizedBox(width: 16),
                          Icon(Icons.thumb_up, color: Colors.green, size: 20),
                          SizedBox(width: 4),
                          Text('94%'),
                          SizedBox(width: 8),
                          Text('(117 reviews)',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Product Description
                      Text(
                        'The Microsoft Xbox Series X gaming console is capable of impressing with minimal boot times and mesmerizing visual effects when playing games at up to 120 frames per second.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),

                      SizedBox(height: 16),

                      // Storage Options
                      Text(
                        'Storage Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildOptions('storage', ['1 TB', '825 GB', '512 GB']),

                      SizedBox(height: 16),

                      // Color Options
                      Text(
                        'Color Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildOptions('color', ['Black', 'White', 'Blue']),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Section with Price and Buttons
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$650.00',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        '\$570.00',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Handle Buy action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                        ),
                        child: Text(
                          'Buy',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Handle Sell action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                        ),
                        child: Text(
                          'Sell',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(String type, List<String> options) {
    return Wrap(
      spacing: 12.0,
      children: options.map((option) {
        bool isSelected = (type == 'storage' && selectedStorageOption == option) ||
            (type == 'color' && selectedColorOption == option);

        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (type == 'storage') {
                selectedStorageOption = selected ? option : null;
              } else if (type == 'color') {
                selectedColorOption = selected ? option : null;
              }
            });
          },
        );
      }).toList(),
    );
  }
}