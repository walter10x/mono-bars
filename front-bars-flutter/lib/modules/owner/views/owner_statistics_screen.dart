import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla de estadísticas y análisis para propietarios
/// Rediseñada con tema oscuro premium
class OwnerStatisticsScreen extends ConsumerStatefulWidget {
  const OwnerStatisticsScreen({super.key});

  @override
  ConsumerState<OwnerStatisticsScreen> createState() => _OwnerStatisticsScreenState();
}

class _OwnerStatisticsScreenState extends ConsumerState<OwnerStatisticsScreen> {
  // Colores del tema oscuro premium
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);

  int _selectedPeriod = 0; // 0=Semana, 1=Mes, 2=Año

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con estilo premium
            _buildHeader(),

            // Contenido
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  // Período de tiempo
                  _buildPeriodSelector(),

                  const SizedBox(height: 24),

                  // Métricas principales
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Visitas',
                          value: '1,234',
                          change: '+12%',
                          isPositive: true,
                          icon: Icons.visibility,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Reservas',
                          value: '156',
                          change: '+8%',
                          isPositive: true,
                          icon: Icons.event_available,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Ingresos',
                          value: '€4,567',
                          change: '+15%',
                          isPositive: true,
                          icon: Icons.euro,
                          color: accentAmber,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Rating',
                          value: '4.5',
                          change: '-0.2',
                          isPositive: false,
                          icon: Icons.star,
                          color: const Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Gráfico de visitas
                  _buildChartSection(),

                  const SizedBox(height: 24),

                  // Rendimiento por bar
                  _buildBarPerformanceSection(),

                  const SizedBox(height: 24),

                  // Productos más vendidos
                  _buildTopProductsSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(24.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryDark,
            secondaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentAmber.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentAmber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.analytics,
              color: accentAmber,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [accentAmber, accentGold],
                  ).createShader(bounds),
                  child: const Text(
                    'Estadísticas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Análisis de rendimiento',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Semana', 'Mes', 'Año'];
    return Row(
      children: periods.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final isSelected = _selectedPeriod == index;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == periods.length - 1 ? 0 : 4,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPeriod = index;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: [accentAmber, accentGold])
                        : null,
                    color: isSelected ? null : primaryDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : accentAmber.withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFF10B981).withOpacity(0.15)
                      : const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: isPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPositive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.show_chart,
                  color: accentAmber,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Visitas de la Semana',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChartBar('L', 120, 200),
                _buildChartBar('M', 180, 200),
                _buildChartBar('X', 150, 200),
                _buildChartBar('J', 200, 200),
                _buildChartBar('V', 190, 200),
                _buildChartBar('S', 160, 200),
                _buildChartBar('D', 140, 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double value, double maxValue) {
    final percentage = value / maxValue;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 80 * percentage,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accentAmber, accentGold],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: accentAmber.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarPerformanceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Rendimiento por Bar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBarPerformance(
            'El Rincón del Jazz',
            '45%',
            0.45,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),
          _buildBarPerformance(
            'La Taberna Moderna',
            '35%',
            0.35,
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 16),
          _buildBarPerformance(
            'Bar Central',
            '20%',
            0.20,
            accentAmber,
          ),
        ],
      ),
    );
  }

  Widget _buildBarPerformance(
      String name, String percentage, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                percentage,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: secondaryDark,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_bar,
                  color: Color(0xFFEC4899),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Productos Más Vendidos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTopProduct('1', 'Cerveza Artesanal', '234 uds', accentGold),
          Divider(color: Colors.white.withOpacity(0.1), height: 24),
          _buildTopProduct('2', 'Tapa de Jamón Ibérico', '189 uds', Colors.grey),
          Divider(color: Colors.white.withOpacity(0.1), height: 24),
          _buildTopProduct('3', 'Gin Tonic Premium', '156 uds', const Color(0xFFCD7F32)),
          Divider(color: Colors.white.withOpacity(0.1), height: 24),
          _buildTopProduct('4', 'Tabla de Quesos', '143 uds', null),
          Divider(color: Colors.white.withOpacity(0.1), height: 24),
          _buildTopProduct('5', 'Mojito Clásico', '128 uds', null),
        ],
      ),
    );
  }

  Widget _buildTopProduct(String rank, String name, String sales, Color? medalColor) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: medalColor != null
                ? LinearGradient(
                    colors: [medalColor, medalColor.withOpacity(0.7)],
                  )
                : null,
            color: medalColor == null ? secondaryDark : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              rank,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: medalColor != null ? Colors.black : Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          sales,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
