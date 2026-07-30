import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/features/finance/domain/entities/employee_entity.dart';
import 'package:wialog_erp/features/finance/domain/entities/user_entity.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/employee/employee_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/employee/employee_event.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/employee/employee_state.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/user/user_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/user/user_event.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/user/user_state.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _showInactive = false;
  bool _obscurePassword = true;

  final Map<UserRole, String> _roleLabels = {
    UserRole.admin: 'Administrador (Total)',
    UserRole.financial: 'Financeiro',
    UserRole.operational: 'Operacional (Frotas)',
  };

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(LoadUsers(includeInactive: _showInactive));
    // Carrega os funcionários em background para usar no Dropdown
    context.read<EmployeeBloc>().add(
      const LoadEmployees(includeInactive: false),
    );
  }

  void _showUserDialog({UserEntity? user}) {
    final isEditing = user != null;
    final formKey = GlobalKey<FormState>();

    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController(
      text: user?.password ?? '',
    );

    UserRole selectedRole = user?.role ?? UserRole.operational;
    int? selectedEmployeeId = user?.employeeId;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                isEditing ? 'Editar Usuário' : 'Novo Usuário do Sistema',
              ),
              content: SizedBox(
                width: 450,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // BLOCO 1: Seleção do Funcionário (Mágica do BLoC)
                        BlocBuilder<EmployeeBloc, EmployeeState>(
                          builder: (context, empState) {
                            if (empState is EmployeeLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (empState is EmployeeLoaded) {
                              // FILTRO: Remove os Motoristas (Eles não logam no sistema)
                              final eligibleEmployees = empState.employees
                                  .where((e) => e.role != EmployeeRole.driver)
                                  .toList();

                              // Se estiver editando, não pode trocar de funcionário (apenas mostrar o nome)
                              if (isEditing) {
                                return TextFormField(
                                  initialValue: user.employeeName,
                                  decoration: const InputDecoration(
                                    labelText: 'Funcionário Vinculado',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                  ),
                                  readOnly: true,
                                );
                              }

                              return DropdownButtonFormField<int>(
                                isExpanded: true,
                                initialValue: selectedEmployeeId,
                                decoration: const InputDecoration(
                                  labelText: 'Vincular a qual Funcionário?',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                items: eligibleEmployees.map((emp) {
                                  return DropdownMenuItem(
                                    value: emp.id,
                                    child: Text(
                                      emp.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setDialogState(
                                  () => selectedEmployeeId = val,
                                ),
                                validator: (val) =>
                                    val == null ? 'Obrigatório' : null,
                              );
                            }
                            return const Text('Erro ao carregar funcionários.');
                          },
                        ),
                        const SizedBox(height: 16),

                        // BLOCO 2: E-mail e Senha
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-mail de Login',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || !val.contains('@')
                              ? 'E-mail inválido'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha de Acesso',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setDialogState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (val) => val == null || val.length < 6
                              ? 'Mínimo de 6 caracteres'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // BLOCO 3: Permissão (Role)
                        DropdownButtonFormField<UserRole>(
                          isExpanded: true,
                          initialValue: selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Nível de Permissão',
                            prefixIcon: Icon(Icons.security),
                            border: OutlineInputBorder(),
                          ),
                          items: UserRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(_roleLabels[role]!),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setDialogState(() => selectedRole = val!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newUser = UserEntity(
                        id: user?.id ?? 0,
                        employeeId: selectedEmployeeId!,
                        email: emailController.text.trim().toLowerCase(),
                        password: passwordController.text,
                        role: selectedRole,
                        isActive: user?.isActive ?? true,
                      );

                      if (isEditing) {
                        context.read<UserBloc>().add(UpdateUser(newUser));
                      } else {
                        context.read<UserBloc>().add(AddUser(newUser));
                      }
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  child: Text(
                    isEditing ? 'Atualizar Permissões' : 'Criar Login',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(UserEntity user) {
    if (user.role == UserRole.admin && user.id == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você não pode inativar o Administrador Principal!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bloquear Acesso?'),
        content: Text(
          'Tem certeza que deseja inativar o acesso de "${user.employeeName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<UserBloc>().add(DeleteUser(user.id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Sim, Bloquear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuários do Sistema',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textTitle,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vincule funcionários a um E-mail e Senha para que eles acessem o ERP.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Mostrar Inativos',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    Switch(
                      value: _showInactive,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _showInactive = val);
                        context.read<UserBloc>().add(
                          LoadUsers(includeInactive: val),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showUserDialog(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Novo Usuário',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is UserLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is UserError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    if (state is UserLoaded) {
                      if (state.users.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhum usuário encontrado.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              AppColors.background,
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Funcionário (Dono da Conta)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'E-mail de Login',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Nível de Acesso',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Ações',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: state.users.map((user) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        Text(
                                          user.employeeName ?? 'Desconhecido',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: user.isActive
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                        ),
                                        if (!user.isActive) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.error.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Bloqueado',
                                              style: TextStyle(
                                                color: AppColors.error,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        color: user.isActive
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _roleLabels[user.role] ?? '',
                                      style: TextStyle(
                                        color: user.isActive
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: AppColors.info,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _showUserDialog(user: user),
                                          tooltip: 'Editar Permissões/Senha',
                                        ),
                                        if (user.isActive &&
                                            user.id !=
                                                1) // Esconde a lixeira para o super admin
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: AppColors.error,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _confirmDelete(user),
                                            tooltip: 'Bloquear Acesso',
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
