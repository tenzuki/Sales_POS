import 'customer.dart';
import 'product.dart';

class CartItem {
  final ProductModel product;
  final ProductUnit selectedUnit;
  final int productTypeId; // Normal = 1, FOC = 2, Change = 3, Sample = 4
  final String productTypeName;
  int quantity;
  double customPrice; // Can edit or defaults to selectedUnit.price

  CartItem({
    required this.product,
    required this.selectedUnit,
    required this.productTypeId,
    required this.productTypeName,
    required this.quantity,
    required this.customPrice,
  });

  double get subtotal => customPrice * quantity;
  double get taxAmount => subtotal * (product.taxPercentage / 100);
  double get totalWithTax => subtotal + taxAmount;
}

class InvoiceItem {
  final int id;
  final int itemId;
  final String name;
  final int quantity;
  final double mrp;
  final double amount;
  final String unit;

  InvoiceItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.mrp,
    required this.amount,
    required this.unit,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      itemId: json['item_id'] is int ? json['item_id'] : int.parse(json['item_id'].toString()),
      name: json['name'] ?? json['product_description'] ?? 'Unknown Product',
      quantity: json['quantity'] is int ? json['quantity'] : int.parse(json['quantity'].toString()),
      mrp: json['mrp'] != null ? double.parse(json['mrp'].toString()) : 0.0,
      amount: json['amount'] != null ? double.parse(json['amount'].toString()) : 0.0,
      unit: json['unit'] ?? 'PCS',
    );
  }
}

class VanSaleInvoice {
  final int id;
  final int customerId;
  final String billMode;
  final String inDate;
  final String inTime;
  final String invoiceNo;
  final double discountedAmount;
  final double discount;
  final double total;
  final double totalTax;
  final double grandTotal;
  final int userId;
  final int storeId;
  final String? remarks;
  final String? customerName;
  final List<InvoiceItem> details;

  VanSaleInvoice({
    required this.id,
    required this.customerId,
    required this.billMode,
    required this.inDate,
    required this.inTime,
    required this.invoiceNo,
    required this.discountedAmount,
    required this.discount,
    required this.total,
    required this.totalTax,
    required this.grandTotal,
    required this.userId,
    required this.storeId,
    this.remarks,
    this.customerName,
    required this.details,
  });

  factory VanSaleInvoice.fromJson(Map<String, dynamic> json) {
    // Customer details could be embedded as a list or a map
    String? custName;
    if (json['customer'] != null) {
      if (json['customer'] is List && (json['customer'] as List).isNotEmpty) {
        final custMap = (json['customer'] as List).first;
        if (custMap is Map && custMap['name'] != null) {
          custName = custMap['name'].toString();
        }
      } else if (json['customer'] is Map && json['customer']['name'] != null) {
        custName = json['customer']['name'].toString();
      }
    }

    var detailsList = <InvoiceItem>[];
    if (json['detail'] != null && json['detail'] is List) {
      detailsList = (json['detail'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList();
    }
    
    return VanSaleInvoice(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      customerId: json['customer_id'] is int ? json['customer_id'] : int.parse(json['customer_id'].toString()),
      billMode: json['bill_mode'] ?? 'CASH',
      inDate: json['in_date'] ?? '',
      inTime: json['in_time'] ?? '',
      invoiceNo: json['invoice_no'] ?? '',
      discountedAmount: json['discounted_amount'] != null ? double.parse(json['discounted_amount'].toString()) : 0.0,
      discount: json['discount'] != null ? double.parse(json['discount'].toString()) : 0.0,
      total: json['total'] != null ? double.parse(json['total'].toString()) : 0.0,
      totalTax: json['total_tax'] != null ? double.parse(json['total_tax'].toString()) : 0.0,
      grandTotal: json['grand_total'] != null ? double.parse(json['grand_total'].toString()) : 0.0,
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      storeId: json['store_id'] is int ? json['store_id'] : int.parse(json['store_id'].toString()),
      remarks: json['remarks']?.toString(),
      customerName: custName,
      details: detailsList,
    );
  }
}
