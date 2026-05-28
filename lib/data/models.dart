class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.storeId,
  });

  final int id;
  final String name;
  final String email;
  final int storeId;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      storeId: (json['store_id'] ?? 0) as int,
    );
  }
}

class UserDetail {
  const UserDetail({
    required this.routeId,
    required this.vanId,
    required this.userId,
    required this.storeId,
  });

  final int routeId;
  final int vanId;
  final int userId;
  final int storeId;

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      routeId: (json['route_id'] ?? 0) as int,
      vanId: (json['van_id'] ?? 0) as int,
      userId: (json['user_id'] ?? 0) as int,
      storeId: (json['store_id'] ?? 0) as int,
    );
  }
}

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.contact,
    required this.paymentTerms,
  });

  final int id;
  final String name;
  final String contact;
  final String paymentTerms;

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      contact: (json['contact_number'] ?? '') as String,
      paymentTerms: (json['payment_terms'] ?? '') as String,
    );
  }
}

class ProductUnit {
  const ProductUnit({
    required this.id,
    required this.name,
    required this.price,
  });

  final int id;
  final String name;
  final double price;

  factory ProductUnit.fromJson(Map<String, dynamic> json) {
    return ProductUnit(
      id: (json['id'] ?? json['unit'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      price: double.tryParse((json['price'] ?? '0').toString()) ?? 0,
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.taxPercentage,
    required this.price,
    required this.units,
  });

  final int id;
  final String name;
  final double taxPercentage;
  final double price;
  final List<ProductUnit> units;

  factory Product.fromJson(Map<String, dynamic> json) {
    final unitData = (json['units'] as List<dynamic>? ?? const []);
    return Product(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      taxPercentage: double.tryParse((json['tax_percentage'] ?? '0').toString()) ?? 0,
      price: double.tryParse((json['price'] ?? '0').toString()) ?? 0,
      units: unitData
          .whereType<Map<String, dynamic>>()
          .map(ProductUnit.fromJson)
          .toList(growable: false),
    );
  }
}

class ProductType {
  const ProductType({required this.id, required this.name});

  final int id;
  final String name;

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
    );
  }
}

class CartItem {
  CartItem({
    required this.product,
    required this.unit,
    required this.productType,
    required this.quantity,
  });

  final Product product;
  final ProductUnit unit;
  final ProductType productType;
  int quantity;

  double get lineTotal => unit.price * quantity;
  double get lineTax => lineTotal * product.taxPercentage / 100;
  double get lineGrandTotal => lineTotal + lineTax;
}

class VanSale {
  const VanSale({
    required this.id,
    required this.invoiceNo,
    required this.date,
    required this.customerName,
    required this.total,
    required this.tax,
    required this.grandTotal,
  });

  final int id;
  final String invoiceNo;
  final String date;
  final String customerName;
  final double total;
  final double tax;
  final double grandTotal;

  factory VanSale.fromJson(Map<String, dynamic> json) {
    final customer = (json['customer'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .cast<Map<String, dynamic>>()
        .toList();

    return VanSale(
      id: (json['id'] ?? 0) as int,
      invoiceNo: (json['invoice_no'] ?? '-') as String,
      date: (json['in_date'] ?? '-') as String,
      customerName: customer.isNotEmpty ? (customer.first['name'] ?? '-') as String : '-',
      total: double.tryParse((json['total'] ?? '0').toString()) ?? 0,
      tax: double.tryParse((json['total_tax'] ?? '0').toString()) ?? 0,
      grandTotal: double.tryParse((json['grand_total'] ?? '0').toString()) ?? 0,
    );
  }
}
