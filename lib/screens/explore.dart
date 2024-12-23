import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import 'dart:math';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> products = [];
  bool isSearching = false;
  bool hasResults = true;
  bool showShopScreen = true;
  String selectedSort = 'Price Low to High';
  String selectedFilter = 'All';
  Map<String, String?> filters = {
    'category': null,
    'minPrice': null,
    'maxPrice': null,
    'ratings': null,
    'discount': null,
  };

  double selectedMinPrice = 0;
  double selectedMaxPrice = 100000000;
  double minPrice = 0;
  double maxPrice = 100000000;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchProducts({String? query}) async {
    setState(() {
      isSearching = true;
      showShopScreen = false; // Switch to product view on search
    });

    Map<String, String> queryParams = {};

    // Ensure that searchQuery is always included if there's a value
    if (query != null && query.isNotEmpty) {
      queryParams['searchQuery'] = query;
    } else if (_searchController.text.isNotEmpty) {
      queryParams['searchQuery'] = _searchController.text;
    }

    // Apply filters only if they are set
    filters.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        queryParams[key] = value;
      }
    });

    // Apply minPrice and maxPrice
    queryParams['minPrice'] = selectedMinPrice.round().toString();
    queryParams['maxPrice'] = selectedMaxPrice.round().toString();

    final uri = Uri.https('bechoserver.vercel.app', '/products', queryParams);
    print('Fetching products with URI: $uri'); // Debugging Log

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data'); // Debugging Log
        setState(() {
          if (data['data'].isEmpty) {
            products = [];
            hasResults = false;
          } else {
            products = List<ProductModel>.from(
              data['data'].map((product) => ProductModel.fromJson(product)),
            );
            hasResults = true;
          }
          isSearching = false;
        });
      } else {
        print(
            'Error fetching products: ${response.statusCode} - ${response.body}');
        setState(() {
          products = [];
          hasResults = false;
          isSearching = false;
        });
      }
    } catch (error) {
      print('Exception while fetching products: $error'); // Debugging Log
      setState(() {
        products = [];
        hasResults = false;
        isSearching = false;
      });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildExpandableFilter(
                      title: "Price Range",
                      content: Column(
                        children: [
                          Text(
                            'Selected Range: \$${selectedMinPrice.round()} - \$${selectedMaxPrice.round()}',
                          ),
                          RangeSlider(
                            activeColor: Colors.black,
                            inactiveColor: Colors.black,
                            values:
                                RangeValues(selectedMinPrice, selectedMaxPrice),
                            min: minPrice,
                            max: maxPrice,
                            divisions: 100,
                            labels: RangeLabels(
                              '\$${selectedMinPrice.round()}',
                              '\$${selectedMaxPrice.round()}',
                            ),
                            onChanged: (values) {
                              setState(() {
                                selectedMinPrice = values.start;
                                selectedMaxPrice = values.end;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildExpandableFilter(
                      title: "Discount",
                      content: Column(
                        children: [
                          _buildRadioFilterOption(
                              '15%+', '15', 'discount', setState),
                          _buildRadioFilterOption(
                              '20%+', '20', 'discount', setState),
                          _buildRadioFilterOption(
                              '25%+', '25', 'discount', setState),
                          _buildRadioFilterOption(
                              '40%+', '40', 'discount', setState),
                        ],
                      ),
                    ),
                    _buildExpandableFilter(
                      title: "Ratings",
                      content: Column(
                        children: [
                          _buildRadioFilterOption(
                              '3+', '3', 'ratings', setState),
                          _buildRadioFilterOption(
                              '4+', '4', 'ratings', setState),
                          _buildRadioFilterOption(
                              '4.5+', '4.5', 'ratings', setState),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              filters = {
                                'category': null,
                                'ratings': null,
                                'discount': null,
                              };
                              selectedMinPrice = minPrice;
                              selectedMaxPrice = maxPrice;
                            });
                            Navigator.pop(context);
                            _fetchProducts(); // Reset filters
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Colors.redAccent,
                                width: 2), // Border color and width
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor:
                                Colors.transparent, // Default background color
                          ).copyWith(
                            overlayColor: MaterialStateProperty.all(
                                Colors.redAccent), // Background on press
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent, // Text color
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchProducts(); // Apply filters
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRadioFilterOption(
      String label, String value, String filterKey, StateSetter setState) {
    return RadioListTile<String>(
      activeColor: Colors.black,
      title: Text(label),
      value: value,
      groupValue: filters[filterKey],
      onChanged: (selected) {
        setState(() {
          filters[filterKey] = selected;
        });
      },
    );
  }

  Widget _buildExpandableFilter(
      {required String title, required Widget content}) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors
            .transparent, // Remove the divider line between the tile and expanded content
      ),
      child: ExpansionTile(
        title: Text(title),
        children: [
          content,
        ],
      ),
    );
  }

  void _onCategorySelected(int categoryID) {
    final category = ShopScreen.categories[categoryID];
    _searchController.text = category; // Update search bar
    _fetchProducts(query: category); // Fetch products for the selected category
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showShopScreen
          ? ShopScreen(onCategorySelected: _onCategorySelected)
          : CustomScrollView(
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
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (query) {
                            _fetchProducts(query: query);
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
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Checking for search status and products found
          isSearching
              ? SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
              : !hasResults
              ? SliverFillRemaining(
            child: Center(
              child: Text(
                'No products found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          )
              : SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return ProductCard(
                    product: products[index],
                    refresh: _fetchProducts,
                  );
                },
                childCount: products.length > 0 ? products.length : 1,
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
      floatingActionButton: !showShopScreen
          ? FloatingActionButton(
        onPressed: _showFilterSheet,
        backgroundColor: Colors.black,
        child: Icon(
          Icons.filter_list,
          color: Colors.white,
        ),
      )
          : null,
    );
  }
}

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
