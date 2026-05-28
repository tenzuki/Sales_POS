class CustomerModel {
  final int id;
  final String name;
  final String code;
  final String? contactNumber;
  final String paymentTerms; // CASH or CREDIT
  final int routeId;
  final int storeId;
  final int status;

  CustomerModel({
    required this.id,
    required this.name,
    required this.code,
    this.contactNumber,
    required this.paymentTerms,
    required this.routeId,
    required this.storeId,
    required this.status,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      contactNumber: json['contact_number']?.toString(),
      paymentTerms: json['payment_terms'] ?? 'CASH',
      routeId: json['route_id'] is int ? json['route_id'] : int.parse(json['route_id'].toString()),
      storeId: json['store_id'] is int ? json['store_id'] : int.parse(json['store_id'].toString()),
      status: json['status'] is int ? json['status'] : int.parse(json['status'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'contact_number': contactNumber,
      'payment_terms': paymentTerms,
      'route_id': routeId,
      'store_id': storeId,
      'status': status,
    };
  }
}
