import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla de gestión de menús para propietarios
class OwnerMenusManagementScreen extends ConsumerWidget {
  const OwnerMenusManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menús',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gestiona tus cartas y productos',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Función disponible próximamente'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nuevo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filtros por bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: 'all',
                    isExpanded: true,
                    dropdownColor: const Color(0xFF6366F1),
                    underline: const SizedBox(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('Todos los bares'),
                      ),
                      DropdownMenuItem(
                        value: 'bar1',
                        child: Text('El Rincón del Jazz'),
                      ),
                      DropdownMenuItem(
                        value: 'bar2',
                        child: Text('La Taberna Moderna'),
                      ),
                      DropdownMenuItem(
                        value: 'bar3',
                        child: Text('Bar Central'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Lista de menús
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      _buildMenuCard(
                        barName: 'El Rincón del Jazz',
                        menuName: 'Carta de Bebidas',
                        itemCount: 45,
                        category: 'Bebidas',
                        lastUpdated: '2 días atrás',
                      ),
                      const SizedBox(height: 16),
                      _buildMenuCard(
                        barName: 'El Rincón del Jazz',
                        menuName: 'Tapas y Entrantes',
                        itemCount: 28,
                        category: 'Comida',
                        lastUpdated: '1 semana atrás',
                      ),
                      const SizedBox(height: 16),
                      _buildMenuCard(
                        barName: 'La Taberna Moderna',
                        menuName: 'Carta Principal',
                        itemCount: 67,
                        category: 'Completo',
                        lastUpdated: '3 días atrás',
                      ),
                      const SizedBox(height: 16),
                      _buildMenuCard(
                        barName: 'La Taberna Moderna',
                        menuName: 'Menú del Día',
                        itemCount: 15,
                        category: 'Comida',
                        lastUpdated: 'Hoy',
                      ),
                      const SizedBox(height: 16),
                      _buildMenuCard(
                        barName: 'Bar Central',
                        menuName: 'Cócteles Premium',
                        itemCount: 32,
                        category: 'Bebidas',
                        lastUpdated: '5 días atrás',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String barName,
    required String menuName,
    required int itemCount,
    required String category,
    required String lastUpdated,
  }) {
    Color categoryColor;
    IconData categoryIcon;

    switch (category) {
      case 'Bebidas':
        categoryColor = const Color(0xFF3B82F6);
        categoryIcon = Icons.local_bar;
        break;
      case 'Comida':
        categoryColor = const Color(0xFFF59E0B);
        categoryIcon = Icons.restaurant;
        break;
      default:
        categoryColor = const Color(0xFF8B5CF6);
        categoryIcon = Icons.restaurant_menu;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      barName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '$itemCount productos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.update,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Actualizado $lastUpdated',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Ver'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
