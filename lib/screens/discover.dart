import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../widgets/discover_header.dart';
import '../models/product_model.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _selectedCategoryIndex = 0;

  final List<ProductModel> productList = [
    ProductModel(
      id: '1',
      title: 'Xbox Series X',
      description: 'Next-gen gaming console with 4K gaming.',
      mrp: '\$570.00',
      discount: '10%',
      ratings: '4.5',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ProductModel(
      id: '2',
      title: 'PlayStation 5',
      description: 'PlayStation 5 with lightning-fast load times.',
      mrp: '\$499.00',
      discount: '5%',
      ratings: '4.7',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ProductModel(
      id: '3',
      title: 'Nintendo Switch',
      description: 'Portable gaming console with detachable controllers.',
      mrp: '\$299.00',
      discount: '0%',
      ratings: '4.2',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ProductModel(
      id: '4',
      title: 'Nintendo Switch',
      description: 'Portable gaming console with detachable controllers.',
      mrp: '\$299.00',
      discount: '0%',
      ratings: '4.3',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ProductModel(
      id: '5',
      title: 'Nintendo Switch',
      description: 'Portable gaming console with detachable controllers.',
      mrp: '\$299.00',
      discount: '5%',
      ratings: '4.1',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ProductModel(
      id: '6',
      title: 'Nintendo Switch',
      description: 'Portable gaming console with detachable controllers.',
      mrp: '\$299.00',
      discount: '10%',
      ratings: '4.4',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ProductModel(
      id: '7',
      title: 'Nintendo Switch',
      description: 'Portable gaming console with detachable controllers.',
      mrp: '\$299.00',
      discount: '0%',
      ratings: '4.0',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ProductModel(
      id: '8',
      title: 'Nintendo Switch',
      description: 'Portable gaming console with detachable controllers.',
      mrp: '\$299.00',
      discount: '15%',
      ratings: '4.6',
      imageUrl: 'https://via.placeholder.com/150',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Clearance Sale Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clearance Sales',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Up to 50%',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.arrow_right,
                size: 24,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Categories Slider
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CategoryCard(
                title: 'All',
                isSelected: _selectedCategoryIndex == 0,
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = 0;
                  });
                },
              ),
              CategoryCard(
                title: 'Smartphones',
                isSelected: _selectedCategoryIndex == 1,
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = 1;
                  });
                },
              ),
              CategoryCard(
                title: 'Headphones',
                isSelected: _selectedCategoryIndex == 2,
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = 2;
                  });
                },
              ),
              CategoryCard(
                title: 'Accessories',
                isSelected: _selectedCategoryIndex == 3,
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = 3;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Popular Products Section
        const Text(
          'Popular Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3 / 4,
          ),
          itemCount: productList.length,
          itemBuilder: (context, index) {
            return ProductCard(product: productList[index]);
          },
        ),
      ],
    );
  }
}