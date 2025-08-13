import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/sales_order.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../utils/notification_service.dart';

class SalesOrderProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<SalesOrder> _salesOrders = [];
  List<Product> _products = [];
  String _filterStatus = 'All';
  DateTime? _filterDate;
  bool _showAlert = false;
  String _alertMessage = '';

  List<SalesOrder> get salesOrders {
    List<SalesOrder> filtered = List.from(_salesOrders);

    if (_filterStatus != 'All') {
      filtered = filtered
          .where((order) => order.status == _filterStatus)
          .toList();
    }

    if (_filterDate != null) {
      filtered = filtered.where((order) {
        return DateFormat('yyyy-MM-dd').format(order.date) ==
            DateFormat('yyyy-MM-dd').format(_filterDate!);
      }).toList();
    }

    return filtered;
  }

  List<Product> get products => _products;
  String get filterStatus => _filterStatus;
  DateTime? get filterDate => _filterDate;
  bool get showAlert => _showAlert;
  String get alertMessage => _alertMessage;

  SalesOrderProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadDummyData();
    await _loadSalesOrders();
    _checkForAlerts();
    _showDailySummary();
  }

  Future<void> _loadDummyData() async {
    // Initialize dummy products
    _products = [
      Product(id: 1, name: 'Steel Bars', price: 1200.0, category: 'Metal'),
      Product(
        id: 2,
        name: 'Cement Bags',
        price: 450.0,
        category: 'Construction',
      ),
      Product(id: 3, name: 'Paint Buckets', price: 800.0, category: 'Paint'),
      Product(id: 4, name: 'Wooden Planks', price: 300.0, category: 'Wood'),
      Product(id: 5, name: 'Glass Sheets', price: 600.0, category: 'Glass'),
    ];

    // Initialize dummy sales orders if database is empty
    final existingOrders = await _databaseService.getSalesOrders();
    if (existingOrders.isEmpty) {
      final dummyOrders = [
        SalesOrder(
          id: 1,
          customer: 'Reliance Retail',
          amount: 12000,
          status: 'Pending',
          date: DateTime.parse('2025-07-31'),
          product: 'Steel Bars',
          quantity: 10,
          rate: 1200.0,
        ),
        SalesOrder(
          id: 2,
          customer: 'Tata Steel',
          amount: 8000,
          status: 'Delivered',
          date: DateTime.parse('2025-07-29'),
          product: 'Cement Bags',
          quantity: 18,
          rate: 444.44,
        ),
        SalesOrder(
          id: 3,
          customer: 'Ambani Industries',
          amount: 15000,
          status: 'Pending',
          date: DateTime.now(),
          product: 'Paint Buckets',
          quantity: 19,
          rate: 789.47,
        ),
      ];

      for (final order in dummyOrders) {
        await _databaseService.insertSalesOrder(order);
      }
    }
  }

  Future<void> _loadSalesOrders() async {
    _salesOrders = await _databaseService.getSalesOrders();
    notifyListeners();
  }

  Future<void> addSalesOrder(SalesOrder order) async {
    await _databaseService.insertSalesOrder(order);
    await _loadSalesOrders();

    // Check for AI alert trigger
    if (order.amount > 10000) {
      _showAlert = true;
      _alertMessage =
          'High-value order alert! Order worth ₹${order.amount.toStringAsFixed(0)} from ${order.customer}';
      notifyListeners();

      // Show local notification
      await _notificationService.showNotification(
        'High Value Order Alert',
        'New order worth ₹${order.amount.toStringAsFixed(0)} from ${order.customer}',
      );
    }
  }

  void setStatusFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setDateFilter(DateTime? date) {
    _filterDate = date;
    notifyListeners();
  }

  void clearFilters() {
    _filterStatus = 'All';
    _filterDate = null;
    notifyListeners();
  }

  void dismissAlert() {
    _showAlert = false;
    _alertMessage = '';
    notifyListeners();
  }

  void _checkForAlerts() {
    final highValueOrders = _salesOrders
        .where((order) => order.amount > 10000)
        .toList();
    if (highValueOrders.isNotEmpty) {
      _showAlert = true;
      _alertMessage =
          '${highValueOrders.length} high-value orders require attention!';
      // Example: Set color info for alert message (store as a separate variable)
      // You can define an additional variable to hold the color, e.g.:
      // Color _alertColor = Colors.red;
      // If you want to include color info in the message itself, you could use a map:
      // _alertMessage = {
      //   'text': '${highValueOrders.length} high-value orders require attention!',
      //   'color': Colors.red,
      // };
      notifyListeners();
    }
  }

  void _showDailySummary() {
    final today = DateTime.now();
    final todaysOrders = _salesOrders.where((order) {
      return DateFormat('yyyy-MM-dd').format(order.date) ==
          DateFormat('yyyy-MM-dd').format(today);
    }).toList();

    final pendingOrders = todaysOrders
        .where((order) => order.status == 'Pending')
        .toList();
    final totalValue = pendingOrders.fold<double>(
      0,
      (sum, order) => sum + order.amount,
    );

    if (pendingOrders.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        _notificationService.showNotification(
          'Daily Sales Summary',
          'You have ${pendingOrders.length} pending orders today worth ₹${totalValue.toStringAsFixed(0)}',
        );
      });
    }
  }

  Map<String, dynamic> getDailySummary() {
    final today = DateTime.now();
    final todaysOrders = _salesOrders.where((order) {
      return DateFormat('yyyy-MM-dd').format(order.date) ==
          DateFormat('yyyy-MM-dd').format(today);
    }).toList();

    final pendingOrders = todaysOrders
        .where((order) => order.status == 'Pending')
        .toList();
    final deliveredOrders = todaysOrders
        .where((order) => order.status == 'Delivered')
        .toList();
    final totalPendingValue = pendingOrders.fold<double>(
      0,
      (sum, order) => sum + order.amount,
    );
    final totalDeliveredValue = deliveredOrders.fold<double>(
      0,
      (sum, order) => sum + order.amount,
    );

    return {
      'pendingCount': pendingOrders.length,
      'deliveredCount': deliveredOrders.length,
      'pendingValue': totalPendingValue,
      'deliveredValue': totalDeliveredValue,
      'totalOrders': todaysOrders.length,
      'totalValue': totalPendingValue + totalDeliveredValue,
    };
  }
}
