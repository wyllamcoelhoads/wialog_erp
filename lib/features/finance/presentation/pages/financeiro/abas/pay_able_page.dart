import 'package:flutter/material.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/features/finance/presentation/widgets/payable_list_widget.dart';

class PayablePage extends StatelessWidget {
  const PayablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Quantidade de abas
      child: Scaffold(
        backgroundColor: context.appColors.background,
        appBar: AppBar(
          backgroundColor: context.appColors.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          automaticallyImplyLeading:
              false, // Esconde a seta de voltar (pois usamos no nosso sistema de abas principal)
          title: Text(
            'Contas a Pagar',
            style: TextStyle(
              color: context.appColors.textTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: context.appColors.primary,
            unselectedLabelColor: context.appColors.textMuted,
            indicatorColor: context.appColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.list_alt), text: 'Painel de Títulos'),
              Tab(icon: Icon(Icons.price_check), text: 'Baixas e Pagamentos'),
              Tab(icon: Icon(Icons.event_repeat), text: 'Despesas Recorrentes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ABA 1: A lista que já criamos
            const PayableListWidget(),

            // ABA 2: A sua nova excelente ideia
            _buildPlaceholder(
              context,
              Icons.price_check,
              'Baixa de Títulos',
              'Aqui o usuário informará a Conta Bancária, Forma de Pagamento,\nData Real de Pagamento, Juros e Descontos.',
            ),

            // ABA 3: Recorrentes
            _buildPlaceholder(
              context,
              Icons.event_repeat,
              'Despesas Recorrentes',
              'Gestão de contratos fixos (Aluguel, Internet, Contabilidade, etc).\n(Em desenvolvimento)',
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
