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

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
                      labelText: 'Descrição / Futuras Permissões',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                ],
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
                  final newRole = RoleEntity(
                    id: role?.id ?? 0,
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
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
              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
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
        const SnackBar(
          content: Text('Você não pode inativar o cargo de Administrador.'),
          backgroundColor: AppColors.error,
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
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
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
                      'Cargos e Permissões',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textTitle,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Cadastre os cargos da empresa para gerenciar acessos futuros.',
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
                child: BlocBuilder<RoleBloc, RoleState>(
                  builder: (context, state) {
                    if (state is RoleLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is RoleError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    if (state is RoleLoaded) {
                      if (state.roles.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhum cargo encontrado.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.background,
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
                                          ? Colors.black
                                          : Colors.grey,
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
                                              ? Colors.black
                                              : Colors.grey,
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
                                            color: AppColors.error.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Text(
                                            'Inativo',
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
                                    role.description ?? '-',
                                    style: TextStyle(
                                      color: role.isActive
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
                                            _showRoleDialog(role: role),
                                        tooltip: 'Editar Cargo',
                                      ),
                                      if (role.isActive &&
                                          role.name.toLowerCase() !=
                                              'administrador')
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: AppColors.error,
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
