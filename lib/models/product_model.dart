class ProductModel {
  final String id;
  final String title;
  final String description;
  final String mrp;
  final String discount;
  final String ratings;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.mrp,
    required this.discount,
    required this.ratings,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      mrp: json['mrp'],
      discount: json['discount'],
      ratings: json['ratings'],
      imageUrl: json['imageUrl'],
    );
  }
}