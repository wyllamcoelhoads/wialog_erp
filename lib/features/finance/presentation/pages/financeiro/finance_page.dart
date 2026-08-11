import 'package:flutter/material.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';
import 'package:wialog_erp/features/finance/presentation/pages/financeiro/abas/pay_able_page.dart';
import 'package:wialog_erp/features/finance/presentation/pages/financeiro/abas/receivable_page.dart';
import 'package:wialog_erp/features/finance/presentation/widgets/partners_list_widget.dart';

// ADICIONAMOS AS DUAS TELAS NOVAS AQUI

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestão Financeira',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Controle o fluxo de caixa, contas a pagar, receber e gerencie seus parceiros.',
                style: TextStyle(
                  fontSize: 16,
                  color: context.appColors.textMuted,
                ),
              ),
              const SizedBox(height: 32),

              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildFinanceCard(
                    context,
                    title: 'Contas a Pagar',
                    subtitle:
                        'Gerencie suas despesas, boletos e pagamentos agendados.',
                    icon: Icons.money_off,
                    onTap: () {
                      DashboardPage.of(context).openTab(
                        WorkspaceTab(
                          id: 'finance_payable',
                          title: 'Contas a Pagar',
                          icon: Icons.money_off,
                          // AGORA ELE CHAMA A NOVA TELA CHEIA DE ABAS
                          content: const PayablePage(),
                        ),
                      );
                    },
                  ),
                  _buildFinanceCard(
                    context,
                    title: 'Contas a Receber',
                    subtitle:
                        'Acompanhe fretes faturados, clientes pendentes e recebimentos.',
                    icon: Icons.attach_money,
                    onTap: () {
                      DashboardPage.of(context).openTab(
                        WorkspaceTab(
                          id: 'finance_receivable',
                          title: 'Contas a Receber',
                          icon: Icons.attach_money,
                          // AGORA ELE CHAMA A NOVA TELA CHEIA DE ABAS
                          content: const ReceivablePage(),
                        ),
                      );
                    },
                  ),
                  _buildFinanceCard(
                    context,
                    title: 'Clientes e Fornecedores',
                    subtitle:
                        'Base de dados de parceiros comerciais da empresa.',
                    icon: Icons.people_outline,
                    onTap: () {
                      DashboardPage.of(context).openTab(
                        WorkspaceTab(
                          id: 'finance_partners',
                          title: 'Parceiros',
                          icon: Icons.people,
                          content: _buildTabContent(
                            context,
                            'Gestão de Clientes e Fornecedores',
                            const PartnersListWidget(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildFinanceCard(
                    context,
                    title: 'Relatórios Financeiros',
                    subtitle:
                        'Gere DRE, extratos de período e análises de custo.',
                    icon: Icons.bar_chart,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Em breve: Relatórios e Exportação em PDF!',
                          ),
                          backgroundColor: context.appColors.info,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mantemos esse empacotador apenas para o PartnersListWidget que não tem abas próprias (ainda)
  Widget _buildTabContent(BuildContext context, String title, Widget child) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: TextStyle(
            color: context.appColors.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: child,
    );
  }

  Widget _buildFinanceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 320,
        height: 210,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.appColors.textMuted.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.appColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 32, color: context.appColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.appColors.textTitle,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
