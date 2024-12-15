import 'dart:math';
import 'package:flutter/material.dart';
import 'reels.dart';

class ShopScreen extends StatefulWidget {
  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<String> categories = [
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

  final Random random = Random();
  int? selectedCategoryID;

  Color getRandomColor() {
    return Color.fromARGB(
      255,
      random.nextInt(128),
      random.nextInt(128),
      random.nextInt(128),
    );
  }

  void resetCategorySelection() {
    setState(() {
      selectedCategoryID = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedCategoryID == null
          ? Column(
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
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryID = index;
                    });
                  },
                  child: Card(
                    color: getRandomColor(),
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
      )
          : ReelScreen(
        categoryID: selectedCategoryID!,
        onBack: resetCategorySelection,
      ),
    );
  }
}