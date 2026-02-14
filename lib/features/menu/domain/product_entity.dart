class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int calories;
  final int stock;
  final int? categoryId;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.calories = 0,
    this.stock = 0,
    this.categoryId,
    this.isAvailable = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      category:
          json['categoryName'] as String? ??
          json['category'] as String? ??
          'Uncategorized',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      isAvailable: (json['isAvailable'] == 1 || json['isAvailable'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'calories': calories,
      'stock': stock,
      'categoryId': categoryId,
      'isAvailable': isAvailable,
    };
  }

  Product copyWith({
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    int? stock,
    int? categoryId,
    bool? isAvailable,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      calories: calories,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
