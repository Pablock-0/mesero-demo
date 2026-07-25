import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restaurant_table.dart';
import '../services/sound_service.dart';
import '../state/app_state.dart';
import 'bill_screen.dart';
import 'settings_screen.dart';
import 'table_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _cuentaMode = false;

  Future<void> _onTapTable(BuildContext context, RestaurantTable table) async {
    if (_cuentaMode) {
      final closed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => BillScreen(table: table)),
      );
      if (closed == true && mounted) {
        setState(() => _cuentaMode = false);
      }
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TableMenuScreen(table: table)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesero'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: appState.tables.length,
        itemBuilder: (context, index) {
          final table = appState.tables[index];
          final hasOrder = appState.hasOrder(table.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Text(
                table.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      decoration: _cuentaMode ? TextDecoration.underline : TextDecoration.none,
                      decorationThickness: 2,
                    ),
              ),
              trailing: hasOrder ? const Icon(Icons.restaurant_menu) : null,
              onTap: () => _onTapTable(context, table),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _cuentaMode ? Theme.of(context).colorScheme.primary : null,
        onPressed: () {
          SoundService.instance.playCuenta();
          setState(() => _cuentaMode = !_cuentaMode);
        },
        icon: const Icon(Icons.receipt_long),
        label: const Text('Cuenta'),
      ),
    );
  }
}
