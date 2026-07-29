import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/features/finance/domain/entities/bank_account_entity.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/bank_account/bank_account_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/bank_account/bank_account_event.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/bank_account/bank_account_state.dart';

class BankAccountPage extends StatefulWidget {
  const BankAccountPage({super.key});

  @override
  State<BankAccountPage> createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  @override
  void initState() {
    super.initState();
    context.read<BankAccountBloc>().add(LoadBankAccounts());
  }

  void _showAddAccountDialog({BankAccountEntity? account}) {
    final isEditing = account != null;
    final formKey = GlobalKey<FormState>();

    // Se for edição, preenchemos os campos com os dados existentes
    final descriptionController = TextEditingController(
      text: account?.description ?? '',
    );
    final agencyController = TextEditingController(text: account?.agency ?? '');
    final accountController = TextEditingController(
      text: account?.accountNumber ?? '',
    );
    final balanceController = TextEditingController(
      text: account != null
          ? account.initialBalance.toStringAsFixed(2)
          : '0.00',
    );

    int selectedBankId = account?.bankId ?? 1;
    AccountType selectedType = account?.accountType ?? AccountType.checking;

    final banks = {
      1: 'Caixa Interno / Cofre',
      2: 'Banco do Brasil',
      3: 'Caixa Econômica Federal',
      4: 'Itaú Unibanco',
      5: 'Bradesco',
      6: 'Santander',
      7: 'Banco Inter',
      8: 'Nubank',
      12: 'Sicredi',
    };

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            isEditing
                ? 'Editar Conta Bancária / Caixa'
                : 'Nova Conta Bancária / Caixa',
          ),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (Ex: C/C Itaú Matriz)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: selectedBankId,
                      decoration: const InputDecoration(
                        labelText: 'Instituição Financeira',
                        border: OutlineInputBorder(),
                      ),
                      items: banks.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => selectedBankId = val!,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<AccountType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Conta',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: AccountType.checking,
                          child: Text('Conta Corrente'),
                        ),
                        DropdownMenuItem(
                          value: AccountType.savings,
                          child: Text('Conta Poupança'),
                        ),
                        DropdownMenuItem(
                          value: AccountType.cash,
                          child: Text('Caixa Físico / Cofre'),
                        ),
                      ],
                      onChanged: (val) => selectedType = val!,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: agencyController,
                            decoration: const InputDecoration(
                              labelText: 'Agência',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: accountController,
                            decoration: const InputDecoration(
                              labelText: 'Número da Conta',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      // TRAVA DE SEGURANÇA: Bloqueia o saldo se estiver editando!
                      readOnly: isEditing,
                      decoration: InputDecoration(
                        labelText: isEditing
                            ? 'Saldo Inicial (Bloqueado)'
                            : 'Saldo Inicial (R\$)',
                        border: const OutlineInputBorder(),
                        filled: isEditing,
                        fillColor: isEditing ? Colors.grey.shade100 : null,
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Obrigatório' : null,
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
                  final newAccount = BankAccountEntity(
                    id: account?.id ?? 0,
                    description: descriptionController.text,
                    bankId: selectedBankId,
                    bankName: banks[selectedBankId] ?? 'Desconhecido',
                    agency: agencyController.text,
                    accountNumber: accountController.text,
                    accountType: selectedType,
                    // Se estiver editando, mantém os saldos que vieram do banco. Se não, pega do campo.
                    initialBalance: isEditing
                        ? account.initialBalance
                        : double.parse(balanceController.text),
                    currentBalance: isEditing
                        ? account.currentBalance
                        : double.parse(balanceController.text),
                    isActive: account?.isActive ?? true,
                  );

                  // Dispara o evento correto (Update se estiver editando, Add se for nova)
                  if (isEditing) {
                    context.read<BankAccountBloc>().add(
                      UpdateBankAccount(newAccount),
                    );
                  } else {
                    context.read<BankAccountBloc>().add(
                      AddBankAccount(newAccount),
                    );
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
              child: Text(isEditing ? 'Atualizar Conta' : 'Salvar Conta'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BankAccountEntity account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inativar Conta?'),
        content: Text(
          'Tem certeza que deseja inativar a conta "${account.description}"?\nIsso não apagará o histórico financeiro dela.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<BankAccountBloc>().add(
                DeleteBankAccount(account.id),
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
                      'Contas Bancárias e Caixas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textTitle,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gerencie os locais onde o dinheiro da empresa está guardado.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showAddAccountDialog(), // Chama vazio para criar nova
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Nova Conta',
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
            const SizedBox(height: 32),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: BlocBuilder<BankAccountBloc, BankAccountState>(
                  builder: (context, state) {
                    if (state is BankAccountLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is BankAccountError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    if (state is BankAccountLoaded) {
                      if (state.accounts.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhuma conta cadastrada.',
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
                                'Descrição',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Banco',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Ag / Conta',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Saldo Atual',
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
                          rows: state.accounts.map((acc) {
                            String agConta = '';
                            if (acc.accountType == AccountType.cash) {
                              agConta = '-';
                            } else {
                              agConta =
                                  '${acc.agency ?? ''} / ${acc.accountNumber ?? ''}';
                            }

                            return DataRow(
                              cells: [
                                DataCell(Text(acc.id.toString())),
                                DataCell(
                                  Text(
                                    acc.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(Text(acc.bankName)),
                                DataCell(Text(agConta)),
                                DataCell(
                                  Text(
                                    'R\$ ${acc.currentBalance.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: acc.currentBalance < 0
                                          ? AppColors.error
                                          : AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // NOVO BOTÃO DE EDITAR
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: AppColors.info,
                                          size: 20,
                                        ),
                                        onPressed: () => _showAddAccountDialog(
                                          account: acc,
                                        ), // Passa a conta atual!
                                        tooltip: 'Editar Conta',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                        onPressed: () => _confirmDelete(acc),
                                        tooltip: 'Inativar Conta',
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
