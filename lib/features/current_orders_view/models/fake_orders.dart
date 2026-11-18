enum OrderStatus { pending, success, failed }

class OrderItem {
  const OrderItem({
    required this.id,
    required this.reference,
    required this.deliveryMan,
    required this.amount,
    required this.createdAt,
    this.status = OrderStatus.pending,
  });

  final String id;

  /// اسم العميل أو رقم الفاتورة.
  final String reference;
  final String deliveryMan;
  final double amount;

  /// وقت إضافة الأوردر.
  final DateTime createdAt;
  final OrderStatus status;

  OrderItem copyWith({OrderStatus? status}) {
    return OrderItem(
      id: id,
      reference: reference,
      deliveryMan: deliveryMan,
      amount: amount,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}

// الأوقات نسبية للوقت الحالي عشان تفضل منطقية في الداتا الوهمية.
final List<OrderItem> fakeOrders = [
  OrderItem(
    id: 'o1',
    reference: 'Mona Salah',
    deliveryMan: 'Ahmed Hany',
    amount: 350,
    createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
  ),
  OrderItem(
    id: 'o2',
    reference: '10452',
    deliveryMan: 'Youssef Magdy',
    amount: 1275.5,
    createdAt: DateTime.now().subtract(const Duration(minutes: 47)),
  ),
  OrderItem(
    id: 'o3',
    reference: 'Hassan Ibrahim',
    deliveryMan: 'Mohamed Samir',
    amount: 90,
    createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
  ),
  OrderItem(
    id: 'o4',
    reference: '10460',
    deliveryMan: 'Karim Adel',
    amount: 620,
    createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
  ),
];
