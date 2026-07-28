import 'package:flutter/material.dart';
import 'package:wialog_erp/features/auth/presentation/pages/login_page.dart';
import 'package:wialog_erp/features/finance/presentation/pages/finance_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Variável para controlar qual item do menu está selecionado
  int _selectedIndex = 0;

  // Renderiza a tela da direita com base no menu selecionado
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildVisaoGeral();
      case 1:
        return const Center(child: Text('Módulo de Frotas (Em breve)'));
      case 2:
        return const FinancePage(); // Chama a nossa nova tela financeira!
      default:
        return _buildVisaoGeral();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F6F8,
      ), // Fundo cinza bem claro (cara de sistema)
      body: Row(
        children: [
          // Menu Lateral
          Container(
            width: 250,
            color: const Color(0xFF5D6D7E), // Azul corporativo
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo e Nome
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

                // Itens de Navegação
                _buildMenuItem(Icons.dashboard, 'Visão Geral', 0),
                _buildMenuItem(Icons.directions_car, 'Frotas', 1),
                _buildMenuItem(Icons.account_balance_wallet, 'Financeiro', 2),

                const Spacer(),
                // Botão de Sair
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

          // Área Principal Direita (Muda conforme o menu)
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // Componente para desenhar os botões do menu lateral
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

  // A Visão Geral (Dashboard) que você já tinha feito
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
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKpiCard(
                'Veículos Ativos',
                '12',
                Icons.local_shipping,
                Colors.blue,
              ),
              _buildKpiCard('Em Manutenção', '2', Icons.build, Colors.orange),
              _buildKpiCard(
                'A Pagar (Mês)',
                'R\$ 14.500',
                Icons.arrow_downward,
                Colors.red,
              ),
              _buildKpiCard(
                'A Receber (Mês)',
                'R\$ 32.800',
                Icons.arrow_upward,
                Colors.green,
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
        color: Colors.white,
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
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Icon(icon, color: color),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
