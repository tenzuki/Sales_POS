class UserModel {
  final int id;
  final String name;
  final String email;
  final int? storeId;
  final String? isStaff;
  final int? rolId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.storeId,
    this.isStaff,
    this.rolId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      storeId: json['store_id'] != null
          ? (json['store_id'] is int ? json['store_id'] : int.parse(json['store_id'].toString()))
          : null,
      isStaff: json['is_staff']?.toString(),
      rolId: json['rol_id'] != null
          ? (json['rol_id'] is int ? json['rol_id'] : int.parse(json['rol_id'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'store_id': storeId,
      'is_staff': isStaff,
      'rol_id': rolId,
    };
  }
}

class UserSettings {
  final int id;
  final int storeId;
  final String vatNoVat;
  final String soRate;
  final String salesRate;
  final String attendance;
  final String discount;
  final String validateQtyInSales;
  final String printer;

  UserSettings({
    required this.id,
    required this.storeId,
    required this.vatNoVat,
    required this.soRate,
    required this.salesRate,
    required this.attendance,
    required this.discount,
    required this.validateQtyInSales,
    required this.printer,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      storeId: json['store_id'] is int ? json['store_id'] : int.parse(json['store_id'].toString()),
      vatNoVat: json['vat_no_vat'] ?? 'Disable',
      soRate: json['so_rate'] ?? 'LastRate',
      salesRate: json['sales_rate'] ?? 'LastRate',
      attendance: json['attendance'] ?? 'Required',
      discount: json['discount'] ?? 'Disable',
      validateQtyInSales: json['validate_qty_in_sales'] ?? 'No',
      printer: json['printer'] ?? 'Bluetooth',
    );
  }
}

class UserDetail {
  final int id;
  final int routeId;
  final int vanId;
  final int userId;
  final int storeId;
  final int status;

  UserDetail({
    required this.id,
    required this.routeId,
    required this.vanId,
    required this.userId,
    required this.storeId,
    required this.status,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      routeId: json['route_id'] is int ? json['route_id'] : int.parse(json['route_id'].toString()),
      vanId: json['van_id'] is int ? json['van_id'] : int.parse(json['van_id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      storeId: json['store_id'] is int ? json['store_id'] : int.parse(json['store_id'].toString()),
      status: json['status'] is int ? json['status'] : int.parse(json['status'].toString()),
    );
  }
}
