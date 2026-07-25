import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restaurant_table.dart';
import '../state/app_state.dart';
import '../utils/money.dart';

enum _PaymentMethod { efectivo, tarjeta }

class PaymentScreen extends StatefulWidget {
  final RestaurantTable table;

  const PaymentScreen({super.key, required this.table});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  _PaymentMethod? _method;
  final _amountController = TextEditingController();
  final _tipController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  double get _total => context.read<AppState>().totalFor(widget.table.id);

  /// Si el campo queda vacío se asume que se pagó exacto.
  double? get _amountPaid {
    final text = _amountController.text.trim();
    if (text.isEmpty) return _total;
    return double.tryParse(text.replaceAll(',', '.'));
  }

  double? get _change {
    final paid = _amountPaid;
    if (paid == null) return null;
    return paid - _total;
  }

  double get _tip => double.tryParse(_tipController.text.replaceAll(',', '.')) ?? 0;

  void _setTipPercent(int percent) {
    final value = _total * percent / 100;
    setState(() {
      _tipController.text = value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toStringAsFixed(2);
    });
  }

  bool get _canCharge {
    if (_method == null) return false;
    if (_method == _PaymentMethod.efectivo) {
      return _amountPaid != null && _amountPaid! >= _total;
    }
    return true;
  }

  Future<void> _charge() async {
    final appState = context.read<AppState>();
    await appState.completeSale(
      tableId: widget.table.id,
      paymentMethod: _method == _PaymentMethod.efectivo ? 'efectivo' : 'tarjeta',
      amountPaid: _method == _PaymentMethod.efectivo ? _amountPaid : null,
      change: _method == _PaymentMethod.efectivo ? _change : null,
      tip: _tip,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;

    return Scaffold(
      appBar: AppBar(title: Text('Pagar — ${widget.table.name}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Center(
            child: Text(
              'Total: ${formatMoney(total)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _MethodButton(
                  label: 'Efectivo',
                  icon: Icons.money,
                  selected: _method == _PaymentMethod.efectivo,
                  onTap: () => setState(() => _method = _PaymentMethod.efectivo),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MethodButton(
                  label: 'Tarjeta',
                  icon: Icons.credit_card,
                  selected: _method == _PaymentMethod.tarjeta,
                  onTap: () => setState(() => _method = _PaymentMethod.tarjeta),
                ),
              ),
            ],
          ),
          if (_method == _PaymentMethod.efectivo) ...[
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Monto recibido',
                helperText: 'Vacío = pago exacto',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_amountPaid != null)
              Text(
                _change != null && _change! >= 0
                    ? 'Cambio: ${formatMoney(_change!)}'
                    : 'Falta ${formatMoney(_amountPaid! - total < 0 ? total - _amountPaid! : 0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: (_change ?? -1) >= 0 ? Colors.green[700] : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
          if (_method != null) ...[
            const SizedBox(height: 24),
            Text('Propina', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final pct in [10, 15, 20])
                  ChoiceChip(
                    label: Text('$pct%'),
                    selected: false,
                    onSelected: (_) => _setTipPercent(pct),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tipController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Propina (personalizado)',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _canCharge ? _charge : null,
        icon: const Icon(Icons.check_circle),
        label: const Text('Cobrar'),
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MethodButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: selected ? scheme.primaryContainer : null,
        side: BorderSide(color: selected ? scheme.primary : scheme.outline),
      ),
    );
  }
}
