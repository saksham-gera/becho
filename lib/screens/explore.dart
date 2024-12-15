import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';
import '../widgets/product_card.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> products = [];
  bool isSearching = false;
  bool hasResults = true;
  String selectedSort = 'Price Low to High';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    products = List.generate(
      18,
          (index) => ProductModel(
        id: '$index',
        title: 'Placeholder Product $index',
        description: 'This is a placeholder description for product $index.',
        mrp: '\$${(index + 1) * 50}',
        discount: index % 2 == 0 ? '10%' : '0%', // 10% discount for even indices
        ratings: (index % 5 + 1).toString(),
        imageUrl: 'https://via.placeholder.com/150',
      ),
    );
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        products = List.generate(
          18,
              (index) => ProductModel(
            id: '$index',
            title: 'Placeholder Product $index',
            description: 'This is a placeholder description for product $index.',
            mrp: '\$${(index + 1) * 50}',
            discount: index % 2 == 0 ? '10%' : '0%',
            ratings: (index % 5 + 1).toString(),
            imageUrl: 'https://via.placeholder.com/150',
          ),
        );
        isSearching = false;
        hasResults = true;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    final response = await http.get(Uri.parse('https://api.example.com/search?query=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['products'].isEmpty) {
        setState(() {
          products = [];
          hasResults = false;
        });
      } else {
        setState(() {
          products = List<ProductModel>.from(
            data['products'].map((product) => ProductModel.fromJson(product)),
          );
          hasResults = true;
        });
      }
    } else {
      setState(() {
        products = [];
        hasResults = false;
      });
    }
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption('Price Low to High'),
              _buildSortOption('Price High to Low'),
              _buildSortOption('New Arrivals'),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('All'),
              _buildFilterOption('Category 1'),
              _buildFilterOption('Category 2'),
              _buildFilterOption('Category 3'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String option) {
    return ListTile(
      title: Text(option),
      trailing: selectedSort == option
          ? Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() {
          selectedSort = option;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildFilterOption(String option) {
    return ListTile(
      title: Text(option),
      trailing: selectedFilter == option
          ? Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        setState(() {
          selectedFilter = option;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double searchBarWidth = isSearching
        ? screenWidth * 0.58
        : screenWidth * 0.92;

    double buttonPadding = screenWidth * 0.02;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Colors.white,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: searchBarWidth,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (query) {
                            _searchProducts(query);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      if (isSearching) ...[
                        SizedBox(width: buttonPadding),
                        ElevatedButton(
                          onPressed: _showSortBottomSheet,
                          child: Text('Sort'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                        SizedBox(width: buttonPadding),
                        ElevatedButton(
                          onPressed: _showFilterBottomSheet,
                          child: Text('Filter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: isSearching
                ? SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Center(child: CircularProgressIndicator());
                },
                childCount: 1,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
            )
                : SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (!hasResults) {
                    return Center(child: Text('No products found'));
                  }
                  return ProductCard(product: products[index]);
                },
                childCount: products.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}