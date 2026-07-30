import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/features/finance/domain/entities/employee_entity.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/employee/employee_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/employee/employee_event.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/employee/employee_state.dart';
import 'package:wialog_erp/features/role/presentation/bloc/role_bloc.dart';
import 'package:wialog_erp/features/role/presentation/bloc/role_event.dart';
import 'package:wialog_erp/features/role/presentation/bloc/role_state.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(
      LoadEmployees(includeInactive: _showInactive),
    );
    context.read<RoleBloc>().add(const LoadRoles(includeInactive: false));
  }

  void _showAddEmployeeDialog({EmployeeEntity? employee}) {
    final isEditing = employee != null;
    final formKey = GlobalKey<FormState>();

    final cpfMask = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      initialText: employee?.cpf ?? '',
    );

    final nameController = TextEditingController(text: employee?.name ?? '');
    final cpfController = TextEditingController(text: cpfMask.getMaskedText());

    int? selectedRoleId = employee?.roleId;
    String? selectedRoleName = employee?.roleName;
    String? selectedLicenseCategory = employee?.licenseCategory;
    DateTime? selectedExpiration = employee?.licenseExpiration;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                isEditing ? 'Editar Funcionário' : 'Novo Funcionário',
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome Completo',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Obrigatório'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: cpfController,
                          inputFormatters: [cpfMask],
                          decoration: const InputDecoration(
                            labelText: 'CPF',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.length < 14
                              ? 'CPF Inválido'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<RoleBloc, RoleState>(
                          builder: (context, roleState) {
                            if (roleState is RoleLoading) {
                              return const CircularProgressIndicator();
                            }
                            if (roleState is RoleLoaded) {
                              return DropdownButtonFormField<int>(
                                isExpanded: true,
                                // CORREÇÃO 1: Troque initialValue por value
                                value: selectedRoleId,
                                decoration: const InputDecoration(
                                  labelText: 'Cargo',
                                  border: OutlineInputBorder(),
                                ),
                                items: roleState.roles.map((role) {
                                  return DropdownMenuItem(
                                    value: role.id,
                                    child: Text(role.name),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedRoleId = val!;
                                    selectedRoleName = roleState.roles
                                        .firstWhere((r) => r.id == val)
                                        .name;
                                    // Se deixou de ser motorista, limpa os dados de CNH
                                    if (selectedRoleName?.toLowerCase() !=
                                        'motorista') {
                                      selectedLicenseCategory = null;
                                      selectedExpiration = null;
                                    }
                                  });
                                },
                                validator: (val) =>
                                    val == null ? 'Obrigatório' : null,
                              );
                            }
                            return const Text('Erro ao carregar cargos');
                          },
                        ),

                        // CAMPOS EXCLUSIVOS PARA MOTORISTAS
                        if (selectedRoleName?.toLowerCase() == 'motorista') ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text(
                            'Dados da CNH',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  // CORREÇÃO 2: Troque initialValue por value
                                  value: selectedLicenseCategory,
                                  decoration: const InputDecoration(
                                    labelText: 'Categoria',
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      [
                                        'A',
                                        'B',
                                        'C',
                                        'D',
                                        'E',
                                        'AB',
                                        'AC',
                                        'AD',
                                        'AE',
                                      ].map((cat) {
                                        return DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat),
                                        );
                                      }).toList(),
                                  onChanged: (val) => setDialogState(
                                    () => selectedLicenseCategory = val,
                                  ),
                                  validator: (val) =>
                                      val == null ? 'Obrigatório' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          selectedExpiration ??
                                          DateTime.now().add(
                                            const Duration(days: 365),
                                          ),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null) {
                                      setDialogState(
                                        () => selectedExpiration = picked,
                                      );
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Validade CNH',
                                      border: const OutlineInputBorder(),
                                      errorText: selectedExpiration == null
                                          ? 'Obrigatório'
                                          : null,
                                    ),
                                    child: Text(
                                      selectedExpiration == null
                                          ? 'Selecionar...'
                                          : '${selectedExpiration!.day.toString().padLeft(2, '0')}/${selectedExpiration!.month.toString().padLeft(2, '0')}/${selectedExpiration!.year}',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                      // Verifica obrigatoriedade da CNH
                      if (selectedRoleName?.toLowerCase() == 'motorista' &&
                          (selectedLicenseCategory == null ||
                              selectedExpiration == null)) {
                        return; // O Validator visual já vai acusar
                      }

                      final newEmp = EmployeeEntity(
                        id: employee?.id ?? 0,
                        name: nameController.text.trim(),
                        cpf: cpfMask.getUnmaskedText(), // Salva limpo no banco
                        roleId: selectedRoleId!,
                        licenseCategory: selectedLicenseCategory,
                        licenseExpiration: selectedExpiration,
                        isActive: employee?.isActive ?? true,
                      );

                      if (isEditing) {
                        context.read<EmployeeBloc>().add(
                          UpdateEmployee(newEmp),
                        );
                      } else {
                        context.read<EmployeeBloc>().add(AddEmployee(newEmp));
                      }
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  child: Text(isEditing ? 'Atualizar' : 'Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(EmployeeEntity employee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inativar Funcionário?'),
        content: Text('Tem certeza que deseja inativar "${employee.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<EmployeeBloc>().add(DeleteEmployee(employee.id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Sim, Inativar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCNHChip(String? category, DateTime? expiration) {
    if (category == null || expiration == null) return const Text('-');

    final isExpired = expiration.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isExpired
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Cat $category - Venc: ${expiration.day.toString().padLeft(2, '0')}/${expiration.month.toString().padLeft(2, '0')}/${expiration.year}',
        style: TextStyle(
          color: isExpired ? AppColors.error : AppColors.success,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
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
                      'Funcionários e Motoristas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textTitle,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gerencie a equipe e valide o vencimento de CNH dos motoristas.',
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
                        context.read<EmployeeBloc>().add(
                          LoadEmployees(includeInactive: val),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEmployeeDialog(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Novo Funcionário',
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
                child: BlocBuilder<EmployeeBloc, EmployeeState>(
                  builder: (context, state) {
                    if (state is EmployeeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is EmployeeError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    if (state is EmployeeLoaded) {
                      if (state.employees.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhum funcionário encontrado.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        );
                      }
                      // Duplo Scroll para responsividade!
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
                                  'Nome',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'CPF',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Cargo',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status CNH',
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
                            rows: state.employees.map((emp) {
                              // Formata CPF limpo do banco (ex: 11122233344 -> 111.222.333-44)
                              String displayCpf = emp.cpf;
                              if (displayCpf.length == 11) {
                                displayCpf =
                                    '${displayCpf.substring(0, 3)}.${displayCpf.substring(3, 6)}.${displayCpf.substring(6, 9)}-${displayCpf.substring(9)}';
                              }

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        Text(
                                          emp.name,

                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,

                                            color: emp.isActive
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                        ),

                                        if (!emp.isActive) ...[
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
                                      displayCpf,

                                      style: TextStyle(
                                        color: emp.isActive
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),

                                  DataCell(
                                    Text(
                                      emp.roleName ?? '',

                                      style: TextStyle(
                                        color: emp.isActive
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),

                                  DataCell(
                                    emp.roleName?.toLowerCase() == 'motorista'
                                        ? _buildCNHChip(
                                            emp.licenseCategory,

                                            emp.licenseExpiration,
                                          )
                                        : const Text('-'),
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
                                              _showAddEmployeeDialog(
                                                employee: emp,
                                              ),

                                          tooltip: 'Editar',
                                        ),

                                        if (emp.isActive)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,

                                              color: AppColors.error,

                                              size: 20,
                                            ),

                                            onPressed: () =>
                                                _confirmDelete(emp),

                                            tooltip: 'Inativar',
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
