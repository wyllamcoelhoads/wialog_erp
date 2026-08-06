import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/features/finance/domain/entities/payment_method_entity.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/payment_method/payment_method_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/payment_method/payment_method_event.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/payment_method/payment_method_state.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    context.read<PaymentMethodBloc>().add(
      LoadPaymentMethods(includeInactive: _showInactive),
    );
  }

  void _showAddMethodDialog({PaymentMethodEntity? method}) {
    final isEditing = method != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: method?.name ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.appColors.surface,
          title: Text(
            isEditing ? 'Editar Forma de Pagamento' : 'Nova Forma de Pagamento',
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome (Ex: PIX, Boleto, Dinheiro)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Obrigatório' : null,
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
                  final newMethod = PaymentMethodEntity(
                    id: method?.id ?? 0,
                    name: nameController.text.trim(),
                    isActive: method?.isActive ?? true,
                  );

                  if (isEditing) {
                    context.read<PaymentMethodBloc>().add(
                      UpdatePaymentMethod(newMethod),
                    );
                  } else {
                    context.read<PaymentMethodBloc>().add(
                      AddPaymentMethod(newMethod),
                    );
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

  void _confirmDelete(PaymentMethodEntity method) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inativar Forma de Pagamento?'),
        content: Text(
          'Tem certeza que deseja inativar "${method.name}"?\nIsso não afetará os pagamentos antigos que já usaram essa forma.',
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
              context.read<PaymentMethodBloc>().add(
                DeletePaymentMethod(method.id),
              );
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
                      'Formas de Pagamento',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cadastre os meios de pagamento aceitos pela empresa.',
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
                      'Mostrar Inativas',
                      style: TextStyle(color: context.appColors.textMuted),
                    ),
                    Switch(
                      value: _showInactive,
                      activeColor: context.appColors.primary,
                      onChanged: (val) {
                        setState(() => _showInactive = val);
                        context.read<PaymentMethodBloc>().add(
                          LoadPaymentMethods(includeInactive: val),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddMethodDialog(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Novo Método',
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
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.appColors.textMuted.withOpacity(0.2),
                  ),
                ),
                child: BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
                  builder: (context, state) {
                    if (state is PaymentMethodLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is PaymentMethodError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: TextStyle(color: context.appColors.error),
                        ),
                      );
                    }
                    if (state is PaymentMethodLoaded) {
                      if (state.methods.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhuma forma de pagamento encontrada.',
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
                          rows: state.methods.map((method) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    method.id.toString(),
                                    style: TextStyle(
                                      color: method.isActive
                                          ? context.appColors.textBody
                                          : context.appColors.textMuted,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      Text(
                                        method.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: method.isActive
                                              ? context.appColors.textBody
                                              : context.appColors.textMuted,
                                        ),
                                      ),
                                      if (!method.isActive) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.appColors.error
                                                .withOpacity(0.1),
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
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: context.appColors.info,
                                          size: 20,
                                        ),
                                        onPressed: () => _showAddMethodDialog(
                                          method: method,
                                        ),
                                        tooltip: 'Editar Forma de Pagamento',
                                      ),
                                      if (method.isActive)
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: context.appColors.error,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _confirmDelete(method),
                                          tooltip:
                                              'Inativar Forma de Pagamento',
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
