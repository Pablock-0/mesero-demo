# Mesero

App móvil para Android hecha en Flutter para llevar la comanda y el cobro de un restaurante chico: registro de pedidos por mesa, cierre de cuenta con desglose, cobro en efectivo (con cálculo de cambio) o tarjeta, propina, y un cierre de caja diario descargable en TXT/CSV.

Esta es una versión de demostración con un menú genérico (Comida 1, Comida 2, Bebida 1, Bebida 2) solo para mostrar el flujo de la app. Cada restaurante personaliza su propio menú, mesas y hora de corte desde la pantalla de Configuración.

## Funcionalidad

- Pantalla principal con las mesas del restaurante (número configurable).
- Menú por mesa con contador +/- por artículo.
- Modo "Cuenta": desglose de la mesa (artículos, precio unitario, total) y edición de la orden desde ahí mismo.
- Cobro en efectivo (cambio calculado en vivo, monto vacío = pago exacto) o tarjeta, con propina de 10/15/20% o personalizada.
- Cierre de caja: resumen de efectivo/tarjeta/propinas, stock vendido por artículo, detalle de ventas, y descarga en TXT o CSV (compartir o guardar en el dispositivo).
- Retención automática de los últimos 10 días de ventas, con rotación de "día de negocio" según una hora de corte configurable.
- Editor de menú y de mesas, todo desde la app.

## Stack

Flutter (Android + Linux desktop para pruebas), sin backend — todo el almacenamiento es local en el dispositivo (JSON/JSONL).

## Correr el proyecto

```
flutter pub get
flutter run -d linux   # o -d <tu-dispositivo-android>
```

## Pruebas

```
flutter test
```

---

Construido con [Claude Code](https://claude.com/claude-code).
