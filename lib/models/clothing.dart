class Clothing {
  final int? id;
  final String name;
  final int price;
  final String category;
  final String? brand;
  final int? sold;
  final double rating;
  final int? stock;
  final int? yearReleased;
  final String? material;

  Clothing({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    this.brand,
    this.sold,
    required this.rating,
    this.stock,
    this.yearReleased,
    this.material,
  });

  factory Clothing.fromJson(Map<String, dynamic> json) {
    return Clothing(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      category: json['category'],
      brand: json['brand'],
      sold: json['sold'],
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'],
      yearReleased: json['yearReleased'],
      material: json['material'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'category': category,
      if (brand != null) 'brand': brand,
      if (sold != null) 'sold': sold,
      'rating': rating,
      if (stock != null) 'stock': stock,
      if (yearReleased != null) 'yearReleased': yearReleased,
      if (material != null) 'material': material,
    };
  }
}
