import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/role/domain/entities/role_entity.dart';
import 'package:wialog_erp/features/role/presentation/bloc/role_bloc.dart';
import 'package:wialog_erp/features/role/presentation/bloc/role_event.dart';
import 'package:wialog_erp/features/role/presentation/bloc/role_state.dart';

import '../../../../core/theme/app_colors.dart';

class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    context.read<RoleBloc>().add(LoadRoles(includeInactive: _showInactive));
  }

  void _showRoleDialog({RoleEntity? role}) {
    final isEditing = role != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: role?.name ?? '');
    final descController = TextEditingController(text: role?.description ?? '');

    final Map<String, String> availablePermissions = {
      'dashboard': 'Visão Geral (Dashboard)',
      'fleet': 'Frotas e Manutenções',
      'finance': 'Módulo Financeiro (Caixa, Contas)',
      'settings': 'Configurações Gerais',
      'users': 'Gestão de Usuários e Acessos',
    };

    Map<String, bool> currentPermissions = Map.from(role?.permissions ?? {});

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.appColors.surface,
          title: Text(isEditing ? 'Editar Cargo' : 'Novo Cargo'),
          content: SizedBox(
            width: 450,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Cargo (Ex: Analista Fiscal)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Obrigatório'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Permissões de Acesso aos Módulos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: context.appColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Defina quais áreas do sistema os funcionários com este cargo poderão acessar.',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: availablePermissions.entries.map((entry) {
                      final isAllowed = currentPermissions[entry.key] ?? false;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.value,
                              style: TextStyle(
                                color: context.appColors.textBody,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Checkbox(
                              value: isAllowed,
                              onChanged: (val) {
                                setState(() {
                                  currentPermissions[entry.key] = val ?? false;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.error,
              ),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newRole = RoleEntity(
                    id: role?.id ?? 0,
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    permissions: currentPermissions,
                    isActive: role?.isActive ?? true,
                  );

                  if (isEditing) {
                    context.read<RoleBloc>().add(UpdateRole(newRole));
                  } else {
                    context.read<RoleBloc>().add(AddRole(newRole));
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: context.appColors.success,
              ),
              child: Text(isEditing ? 'Atualizar' : 'Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(RoleEntity role) {
    if (role.name.toLowerCase() == 'administrador') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você não pode inativar o cargo de Administrador.'),
          backgroundColor: context.appColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inativar Cargo?'),
        content: Text(
          'Tem certeza que deseja inativar o cargo "${role.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: context.appColors.error,
            ),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.appColors.error,
            ),
            onPressed: () {
              context.read<RoleBloc>().add(DeleteRole(role.id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Sim, Inativar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cargos e Permissões',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.textTitle,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Cadastre os cargos da empresa para gerenciar acessos futuros.',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.appColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Mostrar Inativos',
                      style: TextStyle(color: context.appColors.textMuted),
                    ),
                    Switch(
                      value: _showInactive,
                      activeThumbColor: context.appColors.primary,
                      onChanged: (val) {
                        setState(() => _showInactive = val);
                        context.read<RoleBloc>().add(
                          LoadRoles(includeInactive: val),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showRoleDialog(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Novo Cargo',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.primary,
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
                padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.appColors.border),
                ),
                child: BlocBuilder<RoleBloc, RoleState>(
                  builder: (context, state) {
                    if (state is RoleLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is RoleError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: TextStyle(color: context.appColors.error),
                        ),
                      );
                    }
                    if (state is RoleLoaded) {
                      if (state.roles.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhum cargo encontrado.',
                            style: TextStyle(
                              color: context.appColors.textMuted,
                            ),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            context.appColors.background,
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Nome do Cargo',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Descrição',
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
                          rows: state.roles.map((role) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    role.id.toString(),
                                    style: TextStyle(
                                      color: role.isActive
                                          ? context.appColors.textBody
                                          : Colors.redAccent,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      Text(
                                        role.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: role.isActive
                                              ? context.appColors.textBody
                                              : Colors.redAccent,
                                        ),
                                      ),
                                      if (!role.isActive) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.appColors.error
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'Inativo',
                                            style: TextStyle(
                                              color: context.appColors.error,
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
                                    role.description ?? '-',
                                    style: TextStyle(
                                      color: role.isActive
                                          ? context.appColors.textBody
                                          : Colors.redAccent,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: context.appColors.info,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _showRoleDialog(role: role),
                                        tooltip: 'Editar Cargo',
                                      ),
                                      if (role.isActive &&
                                          role.name.toLowerCase() !=
                                              'administrador')
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: context.appColors.error,
                                            size: 20,
                                          ),
                                          onPressed: () => _confirmDelete(role),
                                          tooltip: 'Inativar Cargo',
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
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
