import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'closing_screen.dart';
import 'edit_menu_screen.dart';
import 'edit_tables_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editCutoff(BuildContext context, AppState appState) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: appState.cutoffHour, minute: appState.cutoffMinute),
      helpText: 'Hora de corte',
    );
    if (picked != null) {
      appState.setCutoff(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cutoff = TimeOfDay(hour: appState.cutoffHour, minute: appState.cutoffMinute);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.point_of_sale),
                  title: const Text('Cierre de caja'),
                  subtitle: const Text('Descargar el resumen y detalle de ventas del día'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClosingScreen()),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: const Text('Editar menú'),
                  subtitle: const Text('Categorías, artículos y precios'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditMenuScreen()),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.table_bar),
                  title: const Text('Editar mesas'),
                  subtitle: const Text('Nombres, agregar o quitar mesas'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditTablesScreen()),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Editar hora de corte'),
                  subtitle: Text(cutoff.format(context)),
                  onTap: () => _editCutoff(context, appState),
                ),
                const Divider(),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up),
                  title: const Text('Efectos de sonido'),
                  value: appState.soundEnabled,
                  onChanged: (value) => appState.soundEnabled = value,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Diseñado por Pablock-0, construido con Claude',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
