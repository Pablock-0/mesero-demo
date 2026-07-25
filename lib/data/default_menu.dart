import '../models/menu_category.dart';
import '../models/menu_item.dart';

/// Menú de ejemplo genérico, solo para mostrar el concepto de la app.
/// Cada restaurante debería personalizar esto desde Configuración > Editar menú.
List<MenuCategory> buildDefaultMenu() {
  return [
    const MenuCategory(name: 'Comida', items: [
      MenuItem(id: 'comida_1', name: 'Comida 1', price: 50),
      MenuItem(id: 'comida_2', name: 'Comida 2', price: 60),
    ]),
    const MenuCategory(name: 'Bebida', items: [
      MenuItem(id: 'bebida_1', name: 'Bebida 1', price: 20),
      MenuItem(id: 'bebida_2', name: 'Bebida 2', price: 25),
    ]),
  ];
}
