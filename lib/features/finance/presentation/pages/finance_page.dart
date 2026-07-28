import 'package:flutter/material.dart';
import '../widgets/payable_list_widget.dart';
import '../widgets/receivable_list_widget.dart';
import '../widgets/partners_list_widget.dart'; // NOVO IMPORT

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 4 Abas internas
      child: Column(
        children: [
          // Cabeçalho da Aba
          Container(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
            color: Colors.white,
            width: double.infinity,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestão Financeira',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 24),
                TabBar(
                  labelColor: Color(0xFF1E3A8A),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF1E3A8A),
                  indicatorWeight: 3,
                  tabs: [
                    Tab(icon: Icon(Icons.money_off), text: 'Contas a Pagar'),
                    Tab(
                      icon: Icon(Icons.attach_money),
                      text: 'Contas a Receber',
                    ),
                    Tab(
                      icon: Icon(Icons.people),
                      text: 'Clientes & Fornecedores',
                    ),
                    Tab(icon: Icon(Icons.bar_chart), text: 'Relatórios'),
                  ],
                ),
              ],
            ),
          ),

          // Conteúdo de cada Aba
          Expanded(
            child: TabBarView(
              children: [
                const PayableListWidget(),
                const ReceivableListWidget(),
                const PartnersListWidget(), // SUBSTITUÍMOS O PLACEHOLDER AQUI!
                _buildPlaceholder(
                  'Emissão de Relatórios\n(Filtros por data, DRE simplificado e exportação para PDF)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper para criar as telas provisórias
  Widget _buildPlaceholder(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
