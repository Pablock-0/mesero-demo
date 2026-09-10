import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/menu_category.dart';
import '../models/menu_item.dart';
import '../state/app_state.dart';
import '../utils/money.dart';

class EditMenuScreen extends StatelessWidget {
  const EditMenuScreen({super.key});

  Future<void> _renameCategoryDialog(BuildContext context, AppState appState, MenuCategory category) async {
    final controller = TextEditingController(text: category.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Renombrar categoría'),
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
      appState.renameCategory(category.name, newName);
    }
  }

  Future<void> _confirmRemoveCategory(BuildContext context, AppState appState, MenuCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('Se eliminará "${category.name}" y todos sus artículos. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed == true) {
      appState.removeCategory(category.name);
    }
  }

  Future<void> _addCategoryDialog(BuildContext context, AppState appState) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nueva categoría'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      appState.addCategory(name);
    }
  }

  Future<void> _itemDialog(
    BuildContext context,
    AppState appState,
    MenuCategory category, {
    MenuItem? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(
      text: existing != null ? formatMoney(existing.price).replaceAll('\$', '') : '',
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'Nuevo artículo' : 'Editar artículo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Precio', prefixText: '\$ '),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (result != true) return;
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.replaceAll(',', '.'));
    if (name.isEmpty || price == null) return;
    if (existing == null) {
      appState.addMenuItem(category.name, name, price);
    } else {
      appState.updateMenuItem(existing.id, name: name, price: price);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar menú')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final category in appState.menu) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _renameCategoryDialog(context, appState, category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmRemoveCategory(context, appState, category),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _itemDialog(context, appState, category),
                ),
              ],
            ),
            for (final item in category.items)
              ListTile(
                title: Text(item.name),
                subtitle: Text(formatMoney(item.price)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _itemDialog(context, appState, category, existing: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => appState.removeMenuItem(item.id),
                    ),
                  ],
                ),
              ),
            const Divider(),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _addCategoryDialog(context, appState),
            icon: const Icon(Icons.add),
            label: const Text('+ Categoría'),
          ),
        ],
      ),
    );
  }
}
