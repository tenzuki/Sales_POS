class ProductModel {
  final int id;
  final String? code;
  final String name;
  final String? proImage;
  final double taxPercentage;
  final double basePrice;
  final int storeId;
  final int status;
  final List<ProductUnit> units;

  ProductModel({
    required this.id,
    this.code,
    required this.name,
    this.proImage,
    required this.taxPercentage,
    required this.basePrice,
    required this.storeId,
    required this.status,
    required this.units,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var unitsList = <ProductUnit>[];
    if (json['units'] != null) {
      unitsList = (json['units'] as List)
          .map((u) => ProductUnit.fromJson(u))
          .toList();
    }
    
    return ProductModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      code: json['code']?.toString(),
      name: json['name'] ?? '',
      proImage: json['pro_image']?.toString(),
      taxPercentage: json['tax_percentage'] != null
          ? double.parse(json['tax_percentage'].toString())
          : 0.0,
      basePrice: json['price'] != null
          ? double.parse(json['price'].toString())
          : 0.0,
      storeId: json['store_id'] is int ? json['store_id'] : int.parse(json['store_id'].toString()),
      status: json['status'] is int ? json['status'] : int.parse(json['status'].toString()),
      units: unitsList,
    );
  }
}

class ProductUnit {
  final int id;
  final String name;
  final double price;
  final double? minPrice;
  final double stock;

  ProductUnit({
    required this.id,
    required this.name,
    required this.price,
    this.minPrice,
    required this.stock,
  });

  factory ProductUnit.fromJson(Map<String, dynamic> json) {
    return ProductUnit(
      id: json['id'] != null 
          ? (json['id'] is int ? json['id'] : int.parse(json['id'].toString()))
          : (json['unit'] is int ? json['unit'] : int.parse(json['unit'].toString())),
      name: json['name'] ?? 'UNIT',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      minPrice: json['min_price'] != null ? double.parse(json['min_price'].toString()) : null,
      stock: json['stock'] != null ? double.parse(json['stock'].toString()) : 0.0,
    );
  }
}

class ProductTypeModel {
  final int id;
  final String name;
  final int status;

  ProductTypeModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory ProductTypeModel.fromJson(Map<String, dynamic> json) {
    return ProductTypeModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      status: json['status'] is int ? json['status'] : int.parse(json['status'].toString()),
    );
  }
}
