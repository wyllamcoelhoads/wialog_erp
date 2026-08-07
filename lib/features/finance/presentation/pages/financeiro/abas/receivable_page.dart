import 'package:flutter/material.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/features/finance/presentation/widgets/receivable_list_widget.dart';

class ReceivablePage extends StatelessWidget {
  const ReceivablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Quantidade de abas
      child: Scaffold(
        backgroundColor: context.appColors.background,
        appBar: AppBar(
          backgroundColor: context.appColors.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          automaticallyImplyLeading: false,
          title: Text(
            'Contas a Receber',
            style: TextStyle(
              color: context.appColors.textTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            isScrollable: true, // Permite rolagem se a tela for pequena
            tabAlignment: TabAlignment.start,
            labelColor: context.appColors.primary,
            unselectedLabelColor: context.appColors.textMuted,
            indicatorColor: context.appColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.list_alt), text: 'Painel de Títulos'),
              Tab(icon: Icon(Icons.savings), text: 'Baixas e Recebimentos'),
              Tab(icon: Icon(Icons.rule), text: 'Régua de Cobrança'),
              Tab(
                icon: Icon(Icons.library_add_check),
                text: 'Faturamento em Lote',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ABA 1: A lista que já criamos
            const ReceivableListWidget(),

            // ABA 2: Baixa e Conciliação
            _buildPlaceholder(
              context,
              Icons.savings,
              'Baixas e Recebimentos',
              'Área para processar o recebimento, selecionando a Conta Bancária destino\ne o método (PIX, Boleto, etc).',
            ),

            // ABA 3: Cobranças
            _buildPlaceholder(
              context,
              Icons.rule,
              'Régua de Cobrança',
              'Gestão de Inadimplência: Clientes atrasados, histórico de contatos e renegociações.\n(Em desenvolvimento)',
            ),

            // ABA 4: Faturamento
            _buildPlaceholder(
              context,
              Icons.library_add_check,
              'Faturamento em Lote',
              'Agrupamento de múltiplos fretes/serviços em uma única fatura para o cliente.\n(Em desenvolvimento)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: context.appColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.appColors.textTitle,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: context.appColors.textMuted),
          ),
        ],
      ),
    );
  }
}
