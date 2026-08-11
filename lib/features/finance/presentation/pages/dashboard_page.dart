import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/features/auth/presentation/bloc/auth_event.dart';
import 'package:wialog_erp/features/finance/domain/entities/user_entity.dart';
import 'package:wialog_erp/features/finance/presentation/pages/financeiro/finance_page.dart';
import 'package:wialog_erp/features/finance/presentation/pages/settings_page.dart';

// Classe auxiliar para gerenciar as abas abertas
class WorkspaceTab {
  final String id;
  final String title;
  final IconData icon;
  final Widget content;

  WorkspaceTab({
    required this.id,
    required this.title,
    required this.icon,
    required this.content,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  // NOVO: Permite que qualquer tela do sistema acesse o gerenciador de abas!
  static DashboardPageState of(BuildContext context) {
    return context.findAncestorStateOfType<DashboardPageState>()!;
  }

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

// REMOVEMOS O UNDERLINE '_' PARA TORNAR A CLASSE PÚBLICA
class DashboardPageState extends State<DashboardPage> {
  // Lista de abas atualmente abertas
  final List<WorkspaceTab> _openTabs = [];

  // Índice da aba que está visível na tela
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Inicia o sistema sempre com a Visão Geral aberta
    openTab(
      WorkspaceTab(
        // TIRE O UNDERLINE AQUI
        id: 'dashboard',
        title: 'Visão Geral',
        icon: Icons.dashboard,
        content: _buildVisaoGeral(),
      ),
    );
  }

  // Função central para abrir ou focar em uma aba (TIRE O UNDERLINE AQUI)
  void openTab(WorkspaceTab tab) {
    setState(() {
      // Verifica se a aba já está aberta (buscando pelo ID)
      final existingIndex = _openTabs.indexWhere((t) => t.id == tab.id);

      if (existingIndex != -1) {
        // Se já está aberta, apenas foca nela
        _activeTabIndex = existingIndex;
      } else {
        // Se não está, adiciona na lista e foca na última aba
        _openTabs.add(tab);
        _activeTabIndex = _openTabs.length - 1;
      }
    });
  }

  // Função para fechar uma aba (TIRE O UNDERLINE AQUI)
  void closeTab(int index) {
    setState(() {
      // Regra: Não deixar fechar se for a última aba do sistema
      if (_openTabs.length <= 1) return;

      _openTabs.removeAt(index);

      // Ajusta o índice ativo para não quebrar a tela
      if (_activeTabIndex >= _openTabs.length) {
        _activeTabIndex = _openTabs.length - 1;
      } else if (_activeTabIndex > index) {
        _activeTabIndex--;
      }
    });
  }

  // NOVO: Função para a aba fechar a si mesma
  void closeCurrentTab() {
    closeTab(_activeTabIndex);
  }

  // FUNÇÃO MESTRA DE CHECAGEM DE PERMISSÃO
  bool? _hasPermission(UserEntity user, String module) {
    // 1. O Super Admin tem passe livre absoluto
    if (user.roleName?.toLowerCase() == 'admin' ||
        user.roleName?.toLowerCase() == 'administrador') {
      return true;
    }

    // 2. Se o usuário tem permissões específicas, a palavra dele é a lei
    if (user.customPermissions!.isNotEmpty &&
        user.customPermissions!.containsKey(module)) {
      return user.customPermissions?[module]!;
    }

    // 3. Se não tem permissão específica, herda a regra do Cargo dele
    return user.rolePermissions[module] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Pegamos o usuário logado
    final authState = context.watch<AuthBloc>().state;
    UserEntity? currentUser;
    if (authState is AuthAuthenticated) {
      currentUser = authState.user;
    }

    // Se a sessão caiu, não mostra nada
    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // ==============================
          // MENU LATERAL FIXO
          // ==============================
          Container(
            width: 250,
            color: context.appColors.sidebar,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.local_shipping,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
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

                // Botões do menu que agora ABRIRÃO ABAS
                if (_hasPermission(currentUser, 'dashboard') == true)
                  _buildSidebarItem(
                    icon: Icons.dashboard,
                    title: 'Visão Geral',
                    onTap: () => openTab(
                      WorkspaceTab(
                        // TIRE O UNDERLINE AQUI
                        id: 'dashboard',
                        title: 'Visão Geral',
                        icon: Icons.dashboard,
                        content: _buildVisaoGeral(),
                      ),
                    ),
                  ),
                if (mounted && _hasPermission(currentUser, 'frotas') == true)
                  _buildSidebarItem(
                    icon: Icons.directions_car,
                    title: 'Frotas',
                    onTap: () => openTab(
                      WorkspaceTab(
                        // TIRE O UNDERLINE AQUI
                        id: 'frotas',
                        title: 'Frotas',
                        icon: Icons.directions_car,
                        content: const Center(
                          child: Text(
                            'Módulo de Frotas e Manutenções (Em breve)',
                          ),
                        ),
                      ),
                    ),
                  ),
                if (mounted && _hasPermission(currentUser, 'finance') == true)
                  _buildSidebarItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Financeiro',
                    onTap: () => openTab(
                      WorkspaceTab(
                        // TIRE O UNDERLINE AQUI
                        id: 'finance',
                        title: 'Financeiro',
                        icon: Icons.account_balance_wallet,
                        content: const FinancePage(),
                      ),
                    ),
                  ),
                if (mounted && _hasPermission(currentUser, 'settings') == true)
                  // NOVO ITEM: O Botão de Configurações na Barra Esquerda
                  _buildSidebarItem(
                    icon: Icons.settings,
                    title: 'Configurações',
                    onTap: () => openTab(
                      WorkspaceTab(
                        id: 'settings',
                        title: 'Configurações',
                        icon: Icons.settings,
                        content: const SettingsPage(),
                      ),
                    ),
                  ),

                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white70),
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    // NOVO: Voltar para a rota raiz de forma segura
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // ==============================
          // ÁREA DE TRABALHO (WORKSPACE)
          // ==============================
          Expanded(
            child: Column(
              children: [
                // Barra Superior de Abas (Estilo Navegador)
                Container(
                  height: 50,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _openTabs.length,
                          itemBuilder: (context, index) {
                            final tab = _openTabs[index];
                            final isActive = _activeTabIndex == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeTabIndex = index;
                                });
                              },
                              child: Container(
                                width: 180,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor
                                      : Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isActive
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    right: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      tab.icon,
                                      size: 16,
                                      color: isActive
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : context.appColors.textMuted,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tab.title,
                                        style: TextStyle(
                                          color: isActive
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : context.appColors.textMuted,
                                          fontWeight: isActive
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Só mostra o "X" se tiver mais de uma aba aberta
                                    if (_openTabs.length > 1)
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 16),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        color: context.appColors.textMuted,
                                        onHover: (hovering) {},
                                        onPressed: () => closeTab(
                                          index,
                                        ), // TIRE O UNDERLINE AQUI
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // O IndexedStack mantém todas as abas vivas na memória,
                // mas só exibe a que estiver com o índice ativo!
                Expanded(
                  child: IndexedStack(
                    index: _activeTabIndex,
                    children: _openTabs.map((tab) => tab.content).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Componente extraído para facilitar o menu lateral
  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    // CORREÇÃO AQUI: O Material transparente envolve o ListTile para permitir os efeitos de clique
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        onTap: onTap,
        hoverColor: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }

  // A Visão Geral (Dashboard) intacta
  Widget _buildVisaoGeral() {
    return Builder(
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visão Geral',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.textTitle,
                  ),
                ),
                const SizedBox(height: 32),
                // SUBSTITUÍMOS O ROW (LINHA FIXA) PELO WRAP (QUEBRA AUTOMÁTICA)
                Wrap(
                  spacing: 24, // Espaçamento horizontal entre os cartões
                  runSpacing:
                      24, // Espaçamento vertical (caso a tela encolha e eles desçam)
                  children: [
                    _buildKpiCard(
                      context, // Passamos o context seguro do Builder!
                      'Veículos Ativos',
                      '12',
                      Icons.local_shipping,
                      context.appColors.info,
                    ),
                    _buildKpiCard(
                      context,
                      'Em Manutenção',
                      '2',
                      Icons.build,
                      context.appColors.warning,
                    ),
                    _buildKpiCard(
                      context,
                      'A Pagar (Mês)',
                      'R\$ 14.500',
                      Icons.arrow_downward,
                      context.appColors.error,
                    ),
                    _buildKpiCard(
                      context,
                      'A Receber (Mês)',
                      'R\$ 32.800',
                      Icons.arrow_upward,
                      context.appColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // CORREÇÃO: Adicionamos o BuildContext context como parâmetro obrigatório aqui
  Widget _buildKpiCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                style: TextStyle(
                  color: context.appColors.textMuted,
                  fontSize: 14,
                ),
              ),
              Icon(icon, color: color),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
