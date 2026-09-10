import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mesero/main.dart';
import 'package:mesero/models/sale_record.dart';
import 'package:mesero/services/sales_repository.dart';
import 'package:mesero/state/app_state.dart';

class _FakeSalesRepository extends SalesRepository {
  final List<SaleRecord> recorded = [];

  @override
  Future<void> recordSale(SaleRecord sale, {required int cutoffHour, int cutoffMinute = 0}) async {
    recorded.add(sale);
  }
}

void main() {
  testWidgets('Muestra las 7 mesas por default', (WidgetTester tester) async {
    await tester.pumpWidget(MeseroApp(appState: AppState()));

    expect(find.text('Mesa 1'), findsOneWidget);
    expect(find.text('Cuenta'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Mesa 7'),
      find.byType(ListView),
      const Offset(0, -100),
    );
    expect(find.text('Mesa 7'), findsOneWidget);
  });

  testWidgets('Agregar un producto incrementa su contador', (WidgetTester tester) async {
    await tester.pumpWidget(MeseroApp(appState: AppState()));

    await tester.tap(find.text('Mesa 1'));
    await tester.pumpAndSettle();

    expect(find.text('Comida 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pump();

    expect(find.text('1'), findsWidgets);
  });

  testWidgets('Flujo completo: ordenar, cobrar en efectivo con cambio y propina', (WidgetTester tester) async {
    final salesRepo = _FakeSalesRepository();
    final appState = AppState(salesRepository: salesRepo);
    await tester.pumpWidget(MeseroApp(appState: appState));

    // Ordenar 2 Comida 1 ($50 c/u = $100) en Mesa 1.
    await tester.tap(find.text('Mesa 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pump();

    await tester.tap(find.text('Listo!'));
    await tester.pumpAndSettle();

    // Activar modo Cuenta y abrir el desglose de Mesa 1.
    await tester.tap(find.text('Cuenta'));
    await tester.pump();
    await tester.tap(find.text('Mesa 1'));
    await tester.pumpAndSettle();

    expect(find.text('\$100'), findsWidgets); // línea del ítem y total coinciden en $100

    // Pagar.
    await tester.tap(find.text('Pagar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Efectivo'));
    await tester.pump();

    await tester.enterText(find.widgetWithText(TextField, 'Monto recibido'), '150');
    await tester.pump();

    expect(find.text('Cambio: \$50'), findsOneWidget);

    await tester.tap(find.text('15%'));
    await tester.pump();
    expect(find.text('15'), findsOneWidget); // 15% de 100

    await tester.tap(find.text('Cobrar'));
    await tester.pumpAndSettle();

    // De regreso en Home, la mesa quedó sin orden y el registro de venta se guardó.
    expect(find.text('Mesero'), findsOneWidget);
    expect(salesRepo.recorded, hasLength(1));
    expect(salesRepo.recorded.first.total, 100);
    expect(salesRepo.recorded.first.tip, 15);
    expect(salesRepo.recorded.first.change, 50);
  });

  testWidgets('Efectivo sin monto recibido se asume pago exacto', (WidgetTester tester) async {
    final salesRepo = _FakeSalesRepository();
    final appState = AppState(salesRepository: salesRepo);
    await tester.pumpWidget(MeseroApp(appState: appState));

    await tester.tap(find.text('Mesa 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pump();
    await tester.tap(find.text('Listo!'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cuenta'));
    await tester.pump();
    await tester.tap(find.text('Mesa 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pagar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Efectivo'));
    await tester.pump();

    // No se escribe nada en "Monto recibido".
    expect(find.text('Cambio: \$0'), findsOneWidget);

    await tester.tap(find.text('Cobrar'));
    await tester.pumpAndSettle();

    expect(salesRepo.recorded, hasLength(1));
    expect(salesRepo.recorded.first.amountPaid, 50);
    expect(salesRepo.recorded.first.change, 0);
  });

  test('El sonido está desactivado por default', () {
    final appState = AppState();
    expect(appState.soundEnabled, isFalse);
  });
}
