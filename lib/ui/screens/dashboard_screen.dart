import 'package:flutter/material.dart';

import '../../app/app_session.dart';
import 'create_invoice_screen.dart';
import 'customer_list_screen.dart';
import 'invoice_list_screen.dart';
import 'product_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.session});

  final AppSession session;

  @override
  Widget build(BuildContext context) {
    final user = session.user!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: session.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(user.name),
              subtitle: Text('Store: ${user.storeId} | User ID: ${user.id}'),
              leading: const CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
          const SizedBox(height: 12),
          _ActionTile(
            title: 'Customer List',
            icon: Icons.groups,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CustomerListScreen(session: session),
                ),
              );
            },
          ),
          _ActionTile(
            title: 'Create Invoice',
            icon: Icons.receipt_long,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateInvoiceScreen(session: session),
                ),
              );
            },
          ),
          _ActionTile(
            title: 'Product List',
            icon: Icons.inventory_2,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(
                    session: session,
                    title: 'Product List',
                    allowSelection: false,
                  ),
                ),
              );
            },
          ),
          _ActionTile(
            title: 'Invoice List',
            icon: Icons.list_alt,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InvoiceListScreen(session: session),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
