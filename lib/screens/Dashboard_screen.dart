import 'package:erpapp/providers/sales_order_provider.dart';
import 'package:erpapp/providers/theme_provider.dart';
import 'package:erpapp/screens/create_sales_order_screen.dart';
import 'package:erpapp/screens/sales_order_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();

    // Show daily summary popup after a short delay
    Future.delayed(Duration(milliseconds: 1500), () {
      _showDailySummaryDialog();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildAlertCard(),
                        _buildStatsCards(),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        _buildRecentOrders(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Hello, ${authProvider.userName ?? 'User'}!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
            ),
          ),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: Icon(
                    themeProvider.themeMode == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  Provider.of<AuthProvider>(context, listen: true).logout();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlertCard() {
    return Consumer<SalesOrderProvider>(
      builder: (context, provider, child) {
        if (!provider.showAlert) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            color: Colors.orange.shade50,
            child: ListTile(
              leading: Icon(
                Icons.warning,
                color: Colors.orange.shade700,
                size: 32,
              ),
              title: const Text(
                'AI Alert',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(provider.alertMessage),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => provider.dismissAlert(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Consumer<SalesOrderProvider>(
      builder: (context, provider, child) {
        final summary = provider.getDailySummary();

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Today\'s Orders',
                summary['totalOrders'].toString(),
                Icons.shopping_cart,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Pending',
                summary['pendingCount'].toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Revenue',
                '₹${(summary['totalValue'] as double).toStringAsFixed(0)}',
                Icons.currency_rupee,
                Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'View Orders',
                    Icons.list,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SalesOrderListScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'New Order',
                    Icons.add,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateSalesOrderScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Consumer<SalesOrderProvider>(
      builder: (context, provider, child) {
        final recentOrders = provider.salesOrders.take(3).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Orders',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SalesOrderListScreen(),
                        ),
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recentOrders.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No orders yet'),
                    ),
                  )
                else
                  ...recentOrders
                      .map((order) => _buildOrderTile(order))
                      .toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderTile(order) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: order.status == 'Pending'
            ? Colors.orange.shade100
            : Colors.green.shade100,
        child: Icon(
          order.status == 'Pending' ? Icons.pending : Icons.check_circle,
          color: order.status == 'Pending' ? Colors.orange : Colors.green,
        ),
      ),
      title: Text(
        order.customer,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('₹${order.amount.toStringAsFixed(0)}'),
      trailing: Chip(
        label: Text(order.status, style: const TextStyle(fontSize: 12)),
        backgroundColor: order.status == 'Pending'
            ? Colors.orange.shade100
            : Colors.green.shade100,
      ),
    );
  }

  void _showDailySummaryDialog() {
    final provider = Provider.of<SalesOrderProvider>(context, listen: false);
    final summary = provider.getDailySummary();

    if (summary['pendingCount'] > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.blue),
                SizedBox(width: 8),
                Text('Daily Summary'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have ${summary['pendingCount']} pending orders today worth ₹${(summary['pendingValue'] as double).toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (summary['deliveredCount'] > 0)
                  Text(
                    '${summary['deliveredCount']} orders completed today (₹${(summary['deliveredValue'] as double).toStringAsFixed(0)})',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Dismiss'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalesOrderListScreen(),
                    ),
                  );
                },
                child: const Text('View Orders'),
              ),
            ],
          );
        },
      );
    }
  }
}
