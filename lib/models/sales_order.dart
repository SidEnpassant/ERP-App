class SalesOrder {
  final int? id;
  final String customer;
  final double amount;
  final String status;
  final DateTime date;
  final String? product;
  final int? quantity;
  final double? rate;

  SalesOrder({
    this.id,
    required this.customer,
    required this.amount,
    required this.status,
    required this.date,
    this.product,
    this.quantity,
    this.rate,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      id: json['id'],
      customer: json['customer'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      date: DateTime.parse(json['date']),
      product: json['product'],
      quantity: json['quantity'],
      rate: json['rate']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'amount': amount,
      'status': status,
      'date': date.toIso8601String(),
      'product': product,
      'quantity': quantity,
      'rate': rate,
    };
  }

  SalesOrder copyWith({
    int? id,
    String? customer,
    double? amount,
    String? status,
    DateTime? date,
    String? product,
    int? quantity,
    double? rate,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      date: date ?? this.date,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
    );
  }
}
