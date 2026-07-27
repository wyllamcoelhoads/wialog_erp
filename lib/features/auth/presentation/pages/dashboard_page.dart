import 'package:flutter/material.dart';
import '../../../auth/presentation/pages/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Controle de qual item do menu está selecionado
  int _selectedIndex = 0;

  // Lista de "Telas" simuladas para o nosso esqueleto (serão substituídas pelos módulos reais depois)
  final List<Widget> _pages = [
    const Center(
      child: Text(
        'Visão Geral (Dashboard e Gráficos no futuro)',
        style: TextStyle(fontSize: 24),
      ),
    ),
    const Center(
      child: Text(
        'Módulo de Frotas e Manutenções (Em breve)',
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
                // Logo e Título
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

                // Itens de Navegação
                _buildMenuItem(Icons.dashboard_outlined, 'Visão Geral', 0),
                _buildMenuItem(Icons.directions_car_outlined, 'Frotas', 1),
                _buildMenuItem(
                  Icons.account_balance_wallet_outlined,
                  'Financeiro',
                  2,
                ),

                const Spacer(),

                // Rodapé do Menu Lateral
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
                    // Volta para a tela de login
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // 2. Área de Conteúdo Principal (Onde a mágica acontece)
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

  // Widget auxiliar para desenhar os botões do menu
  Widget _buildMenuItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;

    return Container(
      color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 16,
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
