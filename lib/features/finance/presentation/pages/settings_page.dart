import 'package:flutter/material.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';
import '../../../../core/theme/app_colors.dart';
import 'category_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações do Sistema',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gerencie as preferências, usuários e tabelas auxiliares do ERP.',
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),

            // Grid Responsivo de Cartões de Configuração
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildSettingsCard(
                  context,
                  title: 'Categorias de Fornecedores',
                  subtitle: 'Criar, editar e inativar categorias.',
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
                _buildSettingsCard(
                  context,
                  title: 'Usuários do Sistema',
                  subtitle: 'Controle de acesso, senhas e permissões.',
                  icon: Icons.manage_accounts_outlined,
                  onTap: () {
                    // TODO: Implementar tela de usuários
                  },
                ),
                _buildSettingsCard(
                  context,
                  title: 'Funcionários e Motoristas',
                  subtitle: 'Gestão da equipe operacional.',
                  icon: Icons.badge_outlined,
                  onTap: () {
                    // TODO: Implementar tela de funcionários
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
                  title: 'Preferências Gerais',
                  subtitle: 'Licenciamento e dados da empresa.',
                  icon: Icons.business_center_outlined,
                  onTap: () {
                    // TODO: Implementar dados da empresa
                  },
                ),
              ],
            ),
          ],
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
