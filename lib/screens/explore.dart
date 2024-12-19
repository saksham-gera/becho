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
  Map<String, String?> filters = {
    'category': null,
    'minPrice': null,
    'maxPrice': null,
    'ratings': null,
    'discount': null,
  };

  double selectedMinPrice = 0;
  double selectedMaxPrice = 1000;
  double minPrice = 0;
  double maxPrice = 1000;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({String? query}) async {
    setState(() {
      isSearching = true;
    });

    // Build the query parameters
    Map<String, String> queryParams = {};
    if (query != null && query.isNotEmpty) {
      queryParams['query'] = query;
    }
    filters.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        queryParams[key] = value;
      }
    });

    // Add the selected price range to the queryParams
    queryParams['minPrice'] = selectedMinPrice.toString();
    queryParams['maxPrice'] = selectedMaxPrice.toString();

    final uri = Uri.https('bechoserver.vercel.app', '/products', queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
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
                            values: RangeValues(selectedMinPrice, selectedMaxPrice),
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
                          _buildRadioFilterOption('15%+', '15', 'discount', setState),
                          _buildRadioFilterOption('20%+', '20', 'discount', setState),
                          _buildRadioFilterOption('25%+', '25', 'discount', setState),
                          _buildRadioFilterOption('40%+', '40', 'discount', setState),
                        ],
                      ),
                    ),
                    _buildExpandableFilter(
                      title: "Ratings",
                      content: Column(
                        children: [
                          _buildRadioFilterOption('3+', '3', 'ratings', setState),
                          _buildRadioFilterOption('4+', '4', 'ratings', setState),
                          _buildRadioFilterOption('4.5+', '4.5', 'ratings', setState),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _fetchProducts(); // Apply filters
                      },
                      child: const Text('Apply Filters'),
                    ),
                    ElevatedButton(
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
                      child: const Text('Reset All Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRadioFilterOption(String label, String value, String filterKey, StateSetter setState) {
    return RadioListTile<String>(
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

  Widget _buildExpandableFilter({required String title, required Widget content}) {
    return ExpansionTile(
      title: Text(title),
      children: [content],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _showFilterSheet,
                        child: Text('Filter'),
                      ),
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