import 'package:flutter/material.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';
import 'package:wialog_erp/features/finance/presentation/pages/settings/bank_account_page.dart';
import 'package:wialog_erp/features/finance/presentation/pages/settings/employee_page.dart';
import 'package:wialog_erp/features/finance/presentation/pages/settings/payment_method_page.dart';
import 'package:wialog_erp/features/finance/presentation/pages/settings/preferences_page.dart';
import 'package:wialog_erp/features/finance/presentation/pages/settings/user_page.dart';
import 'package:wialog_erp/features/role/presentation/pages/role_page.dart';
import '../../../../core/theme/app_colors.dart';
import 'category_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configurações do Sistema',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gerencie as preferências, usuários e tabelas auxiliares do ERP.',
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
                  _buildSettingsCard(
                    context,
                    title: 'Categorias (Financeiro)',
                    subtitle: 'Criar, editar e inativar categorias de contas.',
                    icon: Icons.category_outlined,
                    onTap: () {
                      DashboardPage.of(context).openTab(
                        WorkspaceTab(
                          id: 'settings_categories',
                          title: 'Categorias',
                          icon: Icons.category,
                          content: const CategorySettingsPage(),
                        ),
                      );
                    },
                  ),
                  // NOVO CARTÃO: CONTAS BANCÁRIAS
                  _buildSettingsCard(
                    context,
                    title: 'Contas Bancárias e Caixas',
                    subtitle:
                        'Gerencie as contas da empresa para o fluxo de caixa.',
                    icon: Icons.account_balance_outlined,
                    onTap: () {
                      DashboardPage.of(context).openTab(
                        WorkspaceTab(
                          id: 'settings_bank_accounts',
                          title: 'Contas Bancárias',
                          icon: Icons.account_balance,
                          content: const BankAccountPage(),
                        ),
                      );
                    },
                  ),
                  // NOVO CARTÃO: FORMAS DE PAGAMENTO
                  _buildSettingsCard(
                    context,
                    title: 'Formas de Pagamento',
                    subtitle:
                        'Defina os meios aceitos (PIX, Boleto, Dinheiro...).',
                    icon: Icons.payments_outlined,
                    onTap: () {
                      DashboardPage.of(context).openTab(
                        WorkspaceTab(
                          id: 'settings_payment_methods',
                          title: 'Formas de Pgto.',
                          icon: Icons.payments,
                          content: const PaymentMethodPage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsCard(
                    context,
                    title: 'Usuários do Sistema',
                    subtitle: 'Controle de acesso, senhas e permissões.',
                    icon: Icons.manage_accounts_outlined,
                    onTap: () {
                      DashboardPage.of(context).openTab(
                        WorkspaceTab(
                          id: 'settings_users',
                          title: 'Usuários',
                          icon: Icons.manage_accounts,
                          content: const UserPage(),
                        ),
                      );
                    },
                  ),
                  // O CARTÃO DE CARGOS
                  _buildSettingsCard(
                    context,
                    title: 'Cargos do Sistema',
                    subtitle: 'Gestão de papéis e regras de acesso.',
                    icon: Icons.work_outline,
                    onTap: () {
                      DashboardPage.of(context).openTab(
                        WorkspaceTab(
                          id: 'settings_roles',
                          title: 'Cargos',
                          icon: Icons.work,
                          content: const RolePage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsCard(
                    context,
                    title: 'Funcionários e Motoristas',
                    subtitle: 'Gestão da equipe operacional.',
                    icon: Icons.badge_outlined,
                    onTap: () {
                      DashboardPage.of(context).openTab(
                        WorkspaceTab(
                          id: 'settings_employees',
                          title: 'Funcionários',
                          icon: Icons.badge,
                          content: const EmployeePage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsCard(
                    context,
                    title: 'Minha Conta',
                    subtitle: 'Alterar minha senha e dados pessoais.',
                    icon: Icons.lock_outline,
                    onTap: () {
                      // TODO: Implementar troca de senha
                    },
                  ),
                  _buildSettingsCard(
                    context,
                    title: 'Permissões e Preferências',
                    subtitle:
                        'Altere seu tema (Dark Mode) e visualize seus acessos.',
                    icon: Icons.tune,
                    onTap: () {
                      DashboardPage.of(context).openTab(
                        WorkspaceTab(
                          id: 'settings_preferences',
                          title: 'Minhas Preferências',
                          icon: Icons.tune,
                          content: const PreferencesPage(),
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

  Widget _buildSettingsCard(
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
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textMuted,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
