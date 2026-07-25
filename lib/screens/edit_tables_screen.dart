import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restaurant_table.dart';
import '../state/app_state.dart';

class EditTablesScreen extends StatelessWidget {
  const EditTablesScreen({super.key});

  Future<void> _renameDialog(BuildContext context, AppState appState, RestaurantTable table) async {
    final controller = TextEditingController(text: table.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Renombrar mesa'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      appState.renameTable(table.id, newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar mesas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final table in appState.tables)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(table.name),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _renameDialog(context, appState, table),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: appState.addTable,
                  icon: const Icon(Icons.add),
                  label: const Text('+ Mesa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: appState.tables.length > 1
                      ? () => appState.removeTable(appState.tables.last.id)
                      : null,
                  icon: const Icon(Icons.remove),
                  label: const Text('- Mesa'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
