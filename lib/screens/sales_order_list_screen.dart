import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sales_order_provider.dart';
import 'create_sales_order_screen.dart';

class SalesOrderListScreen extends StatefulWidget {
  @override
  _SalesOrderListScreenState createState() => _SalesOrderListScreenState();
}

class _SalesOrderListScreenState extends State<SalesOrderListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutQuart,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Orders'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<SalesOrderProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // _buildFilterChips(provider),
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildOrdersList(provider),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateSalesOrderScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips(SalesOrderProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', provider.filterStatus == 'All', () {
              provider.setStatusFilter('All');
            }),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', provider.filterStatus == 'Pending', () {
              provider.setStatusFilter('Pending');
            }),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Delivered',
              provider.filterStatus == 'Delivered',
              () {
                provider.setStatusFilter('Delivered');
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              "Today's Orders",
              provider.filterDate != null &&
                  DateFormat('yyyy-MM-dd').format(provider.filterDate!) ==
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
              () {
                provider.setDateFilter(DateTime.now());
              },
            ),
            const SizedBox(width: 8),
            if (provider.filterStatus != 'All' || provider.filterDate != null)
              ActionChip(
                label: const Text('Clear'),
                onPressed: () => provider.clearFilters(),
                backgroundColor: Colors.red.shade100,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildOrdersList(SalesOrderProvider provider) {
    final orders = provider.salesOrders;

    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Tap + to create your first order',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, index);
      },
    );
  }

  Widget _buildOrderCard(order, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 50)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOrderDetails(order),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order.customer,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: order.status == 'Pending'
                            ? Colors.orange.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: order.status == 'Pending'
                              ? Colors.orange.shade800
                              : Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(order.date),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      '₹${order.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (order.product != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${order.product} × ${order.quantity}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Order Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Customer', order.customer),
                  _buildDetailRow(
                    'Order Date',
                    DateFormat('dd MMM yyyy').format(order.date),
                  ),
                  _buildDetailRow(
                    'Amount',
                    '₹${order.amount.toStringAsFixed(0)}',
                  ),
                  _buildDetailRow('Status', order.status),
                  if (order.product != null) ...[
                    _buildDetailRow('Product', order.product!),
                    _buildDetailRow('Quantity', order.quantity.toString()),
                    _buildDetailRow(
                      'Rate',
                      '₹${order.rate?.toStringAsFixed(2)}',
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Orders'),
                onTap: () {
                  Provider.of<SalesOrderProvider>(
                    context,
                    listen: false,
                  ).clearFilters();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Today\'s Orders'),
                onTap: () {
                  Provider.of<SalesOrderProvider>(
                    context,
                    listen: false,
                  ).setDateFilter(DateTime.now());
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Pending Only'),
                onTap: () {
                  Provider.of<SalesOrderProvider>(
                    context,
                    listen: false,
                  ).setStatusFilter('Pending');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Delivered Only'),
                onTap: () {
                  Provider.of<SalesOrderProvider>(
                    context,
                    listen: false,
                  ).setStatusFilter('Delivered');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
