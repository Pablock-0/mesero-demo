import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restaurant_table.dart';
import '../state/app_state.dart';
import '../utils/money.dart';
import 'payment_screen.dart';
import 'table_menu_screen.dart';

class BillScreen extends StatelessWidget {
  final RestaurantTable table;

  const BillScreen({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lines = appState.lineItemsFor(table.id);
    final total = appState.totalFor(table.id);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 190,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TableMenuScreen(table: table)),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
            ),
          ],
        ),
        title: Text('Cuenta — ${table.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          if (lines.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('Sin artículos todavía')),
            ),
          for (final line in lines)
            ListTile(
              title: Text(line.name),
              subtitle: Text('${line.quantity} x ${formatMoney(line.unitPrice)}'),
              trailing: Text(
                formatMoney(line.lineTotal),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          const Divider(),
          ListTile(
            title: Text(
              'Total',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              formatMoney(total),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final paid = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => PaymentScreen(table: table)),
          );
          if (paid == true && context.mounted) {
            Navigator.pop(context, true);
          }
        },
        icon: const Icon(Icons.payments),
        label: const Text('Pagar'),
      ),
    );
  }
}
