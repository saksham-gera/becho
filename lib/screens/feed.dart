import 'dart:math';
import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  final void Function(int categoryID) onCategorySelected;
  static const categories = [
    'Electronics',
    'Clothing',
    'Home Appliances',
    'Books',
    'Toys',
    'Groceries',
    'Beauty Products',
    'Sports Equipment',
    'Gadgets',
    'Furniture',
    'Jewelry',
    'Stationery',
    'Gaming',
    'Footwear',
    'Bags',
    'Accessories',
  ];

  ShopScreen({required this.onCategorySelected});

  Color _getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(128),
      random.nextInt(128),
      random.nextInt(128),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'What would you like to shop today?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onCategorySelected(index),
                child: Card(
                  color: _getRandomColor(),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      categories[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}