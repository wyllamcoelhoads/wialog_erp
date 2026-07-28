import 'package:flutter/material.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Quantidade de abas
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do Módulo
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Gestão Financeira',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          // Menu de Abas
          const TabBar(
            labelColor: Color(0xFF34495E),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF5D6D7E),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(icon: Icon(Icons.money_off), text: 'Contas a Pagar'),
              Tab(icon: Icon(Icons.attach_money), text: 'Contas a Receber'),
              Tab(
                icon: Icon(Icons.people_alt_outlined),
                text: 'Clientes & Fornecedores',
              ),
              Tab(icon: Icon(Icons.bar_chart), text: 'Relatórios'),
            ],
          ),
          // Conteúdo de cada Aba
          Expanded(
            child: TabBarView(
              children: [
                _buildPlaceholder(
                  'Módulo de Contas a Pagar\n(Aqui vai a lista de despesas e o botão de Nova Conta)',
                ),
                _buildPlaceholder(
                  'Módulo de Contas a Receber\n(Aqui vai a lista de receitas)',
                ),
                _buildPlaceholder(
                  'Módulo de Cadastros\n(Gestão de Clientes e Fornecedores)',
                ),
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

  // Widget temporário apenas para preencher o espaço enquanto não criamos as listas reais
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
