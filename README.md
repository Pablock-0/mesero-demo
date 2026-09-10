# Mesero

App móvil para Android hecha en Flutter para llevar la comanda y el cobro de un restaurante chico: registro de pedidos por mesa, cierre de cuenta con desglose, cobro en efectivo (con cálculo de cambio) o tarjeta, propina, y un cierre de caja diario descargable en TXT/CSV.

Esta es una versión de demostración con un menú genérico (Comida 1, Comida 2, Bebida 1, Bebida 2) solo para mostrar el flujo de la app. Cada restaurante personaliza su propio menú, mesas y hora de corte desde la pantalla de Configuración.

## 📲 Instalar la app en tu teléfono (sin saber de programación)

Solo necesitas un teléfono **Android**. Hazlo **desde el teléfono**, no desde la computadora:

1. Abre este enlace y espera a que baje el archivo:
   ### 👉 [Descargar Mesero (demo)](https://github.com/Pablock-0/mesero-demo/releases/latest/download/mesero.apk)
2. Cuando termine, toca el archivo descargado (**`mesero.apk`**). Aparece en la barra de notificaciones o en tu carpeta **Descargas**.
3. La primera vez, Android dirá que no puede instalar apps de este origen. Toca **Ajustes** en ese aviso y activa **Permitir de esta fuente**; luego regresa.
4. Toca **Instalar**. Si sale una advertencia de *Play Protect*, toca **Más detalles → Instalar de todas formas**.
5. Abre **Mesero** desde tus aplicaciones. Listo.

> Es una app para instalar por tu cuenta (no está en Google Play). No usa internet y todos los datos se quedan **solo en tu teléfono**. Para desinstalarla, mantén presionado el ícono y elige *Desinstalar*.

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

## Publicar una versión descargable

El enlace "Descargar Mesero (demo)" de arriba apunta a `releases/latest/download/mesero.apk`. Para actualizarlo tras un cambio:

```
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk mesero.apk
gh release create vX.Y -R Pablock-0/mesero-demo -t "Mesero (demo) vX.Y" -n "Cambios de esta versión" mesero.apk
```

El APK va firmado con la llave de debug (no hay `key.properties` de release en esta copia); para instalar de forma manual entre teléfonos es suficiente. `mesero.apk` está en `.gitignore`, vive solo como asset del release.

---

Construido con [Claude Code](https://claude.com/claude-code).
