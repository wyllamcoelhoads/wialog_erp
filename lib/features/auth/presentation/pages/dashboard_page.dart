import 'package:flutter/material.dart';
import '../../../auth/presentation/pages/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    _buildOverviewTab(),
    const Center(
      child: Text(
        'Módulo de Frotas (Em breve)',
        style: TextStyle(fontSize: 24),
      ),
    ),
    const Center(
      child: Text(
        'Módulo Financeiro (Em breve)',
        style: TextStyle(fontSize: 24),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Menu Lateral (Sidebar)
          Container(
            width: 260,
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.local_shipping, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'WiaLog ERP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                _buildMenuItem(Icons.dashboard_outlined, 'Visão Geral', 0),
                _buildMenuItem(Icons.directions_car_outlined, 'Frotas', 1),
                _buildMenuItem(
                  Icons.account_balance_wallet_outlined,
                  'Financeiro',
                  2,
                ),

                const Spacer(),

                const Divider(color: Colors.white24, height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  leading: const Icon(Icons.logout, color: Colors.white70),
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // 2. Área de Conteúdo Principal
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  // Método que constrói a aba de Visão Geral com base no RF08
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visão Geral',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Acompanhamento em tempo real da sua operação (Julho/2026).',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Grid com os Indicadores (KPIs)
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  'Veículos Ativos',
                  '12',
                  Icons.local_shipping,
                  Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildKpiCard(
                  'Em Manutenção',
                  '3',
                  Icons.build,
                  Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildKpiCard(
                  'A Pagar (Mês)',
                  'R\$ 15.420',
                  Icons.arrow_circle_down,
                  Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildKpiCard(
                  'A Receber (Mês)',
                  'R\$ 42.900',
                  Icons.arrow_circle_up,
                  Colors.green.shade700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Área para futuros gráficos ou tabelas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildPlaceholderSection(
                  'Próximas Manutenções',
                  Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: _buildPlaceholderSection(
                  'Fluxo de Caixa',
                  Icons.bar_chart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card de Indicador individual
  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Card genérico para ocupar espaço de relatórios futuros
  Widget _buildPlaceholderSection(String title, IconData icon) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
          const Expanded(
            child: Center(
              child: Text(
                'Gráficos e Listagens em breve...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;

    return Container(
      color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
