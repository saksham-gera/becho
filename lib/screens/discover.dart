import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../models/product_model.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _selectedCategoryIndex = 0;
  List<Map<String, dynamic>> categoryList = [];
  List<ProductModel> productList = [];
  bool isLoadingCategories = true;
  bool isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('https://bechoserver.vercel.app/category'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categoryList = [
            {'id': null, 'title': 'All'}, // Add "All" category at the start
            ...List<Map<String, dynamic>>.from(data),
          ];
          isLoadingCategories = false;
        });
        fetchProducts(); // Fetch products for the "All" category by default
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
      });
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchProducts([String? categoryId]) async {
    setState(() {
      isLoadingProducts = true;
    });
    try {
      final uri = categoryId != null
          ? Uri.parse('https://bechoserver.vercel.app/products?category=$categoryId')
          : Uri.parse('https://bechoserver.vercel.app/products');
      final response = await http.get(uri);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          productList = (data['data'] as List)
              .map((json) => ProductModel.fromJson(json))
              .toList();
          isLoadingProducts = false;
        });
      } else if (response.statusCode == 201 || (data['data'] as List).isEmpty) {
        setState(() {
          productList = [];
          isLoadingProducts = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        isLoadingProducts = false;
      });
      print('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoadingCategories
        ? const Center(child: CircularProgressIndicator())
        : ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
                      style: TextStyle(fontSize: 16),
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
            children: List.generate(categoryList.length, (index) {
              final category = categoryList[index];
              return CategoryCard(
                title: category['title'],
                isSelected: _selectedCategoryIndex == index,
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                  fetchProducts(category['id']); // Pass null for "All"
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Popular Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        isLoadingProducts
            ? const Center(child: CircularProgressIndicator())
            : productList.isEmpty
            ? const Center(
          child: Text(
            'No products found.',
            style: TextStyle(fontSize: 16),
          ),
        )
            : GridView.builder(
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
            return ProductCard(
              product: productList[index],
              refresh: () => fetchProducts(categoryList[_selectedCategoryIndex]['id']),
            );
          },
        ),
      ],
    );
  }
}