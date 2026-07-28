import 'package:flutter/material.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/features/auth/presentation/pages/login_page.dart';
import '../../../finance/presentation/pages/finance_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildVisaoGeral();
      case 1:
        return const Center(child: Text('Módulo de Frotas (Em breve)'));
      case 2:
        return const FinancePage();
      default:
        return _buildVisaoGeral();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O Scaffold já pega a cor de fundo do main.dart automaticamente, mas podemos garantir:
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Menu Lateral
          Container(
            width: 250,
            color: AppColors.sidebar, // Usando a cor padronizada!
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.local_shipping, size: 48, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  'WiaLog ERP',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                _buildMenuItem(Icons.dashboard, 'Visão Geral', 0),
                _buildMenuItem(Icons.directions_car, 'Frotas', 1),
                _buildMenuItem(Icons.account_balance_wallet, 'Financeiro', 2),

                const Spacer(),
                ListTile(
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
                const SizedBox(height: 20),
              ],
            ),
          ),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;

    return Container(
      color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
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

  Widget _buildVisaoGeral() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visão Geral',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textTitle, // Usando cor de texto padrão
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Usando as cores semânticas padronizadas!
              _buildKpiCard(
                'Veículos Ativos',
                '12',
                Icons.local_shipping,
                AppColors.info,
              ),
              _buildKpiCard(
                'Em Manutenção',
                '2',
                Icons.build,
                AppColors.warning,
              ),
              _buildKpiCard(
                'A Pagar (Mês)',
                'R\$ 14.500',
                Icons.arrow_downward,
                AppColors.error,
              ),
              _buildKpiCard(
                'A Receber (Mês)',
                'R\$ 32.800',
                Icons.arrow_upward,
                AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              Icon(icon, color: color),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textTitle,
            ),
          ),
        ],
      ),
    );
  }
}
