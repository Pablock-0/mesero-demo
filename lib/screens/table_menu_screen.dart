import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restaurant_table.dart';
import '../services/sound_service.dart';
import '../state/app_state.dart';
import '../utils/money.dart';

class TableMenuScreen extends StatelessWidget {
  final RestaurantTable table;

  const TableMenuScreen({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(table.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          for (final category in appState.menu) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            for (final item in category.items)
              ListTile(
                title: Text(item.name),
                subtitle: Text(formatMoney(item.price)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: appState.quantityOf(table.id, item.id) > 0
                          ? () => appState.decrementItem(table.id, item.id)
                          : null,
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${appState.quantityOf(table.id, item.id)}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        appState.incrementItem(table.id, item.id);
                        SoundService.instance.playAdd();
                      },
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.check),
        label: const Text('Listo!'),
      ),
    );
  }
}
