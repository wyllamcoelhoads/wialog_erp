import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/financial_document_entity.dart';
import '../bloc/bank_account/bank_account_bloc.dart';
import '../bloc/bank_account/bank_account_event.dart';
import '../bloc/bank_account/bank_account_state.dart';
import '../bloc/document/document_bloc.dart';
import '../bloc/document/document_event.dart';
import '../bloc/document/document_state.dart';
import '../bloc/payment_method/payment_method_bloc.dart';
import '../bloc/payment_method/payment_method_event.dart';
import '../bloc/payment_method/payment_method_state.dart';

class DocumentSettleWidget extends StatefulWidget {
  final DocumentType type; // Define se é Pagar ou Receber

  const DocumentSettleWidget({super.key, required this.type});

  @override
  State<DocumentSettleWidget> createState() => _DocumentSettleWidgetState();
}

class _DocumentSettleWidgetState extends State<DocumentSettleWidget> {
  FinancialDocumentEntity? _selectedDocument;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  int? _selectedBankAccountId;
  int? _selectedPaymentMethodId;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<DocumentBloc>().add(LoadDocuments(type: widget.type));
    context.read<BankAccountBloc>().add(const LoadBankAccounts());
    context.read<PaymentMethodBloc>().add(const LoadPaymentMethods());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectDocument(FinancialDocumentEntity doc) {
    setState(() {
      _selectedDocument = doc;
      _amountController.text = doc.value.toStringAsFixed(2);
      _paymentDate = DateTime.now();
      _selectedBankAccountId = doc.bankAccountId;
      _selectedPaymentMethodId = doc.paymentMethodId;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: context.appColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _paymentDate = picked);
    }
  }

  void _handleSettle() {
    if (!_formKey.currentState!.validate() ||
        _selectedBankAccountId == null ||
        _selectedPaymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha os campos obrigatórios.'),
          backgroundColor: context.appColors.warning,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final finalAmount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;

    context.read<DocumentBloc>().add(
      SettleDocument(
        documentId: _selectedDocument!.id,
        type: widget.type,
        bankAccountId: _selectedBankAccountId!,
        paymentMethodId: _selectedPaymentMethodId!,
        amount: finalAmount,
        paymentDate: _paymentDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isReceivable = widget.type == DocumentType.receivable;
    final primaryColor = isReceivable
        ? context.appColors.success
        : context.appColors.error;
    final actionLabel = isReceivable ? 'Receber Título' : 'Pagar Título';

    return BlocListener<DocumentBloc, DocumentState>(
      listener: (context, state) {
        if (state is DocumentError && _isProcessing) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.appColors.error,
            ),
          );
        } else if (state is DocumentLoaded && _isProcessing) {
          setState(() {
            _isProcessing = false;
            _selectedDocument = null; // Limpa a seleção após o sucesso
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$actionLabel processado com sucesso! O saldo foi atualizado.',
              ),
              backgroundColor: context.appColors.success,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // LADO ESQUERDO: LISTA DE PENDENTES
            // ==========================================
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.appColors.textMuted.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Títulos Pendentes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.appColors.textTitle,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: BlocBuilder<DocumentBloc, DocumentState>(
                        builder: (context, state) {
                          if (state is DocumentLoading)
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          if (state is DocumentLoaded &&
                              state.type == widget.type) {
                            // Filtra apenas os que NÃO estão pagos ou cancelados
                            final pendingDocs = state.documents
                                .where(
                                  (d) =>
                                      d.status != DocumentStatus.paid &&
                                      d.status != DocumentStatus.canceled,
                                )
                                .toList();

                            if (pendingDocs.isEmpty) {
                              return Center(
                                child: Text(
                                  'Nenhum título pendente.',
                                  style: TextStyle(
                                    color: context.appColors.textMuted,
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: pendingDocs.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final doc = pendingDocs[index];
                                final isSelected =
                                    _selectedDocument?.id == doc.id;
                                final isLate = doc.dueDate.isBefore(
                                  DateTime.now().subtract(
                                    const Duration(days: 1),
                                  ),
                                );

                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor: primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: isLate
                                        ? context.appColors.error.withOpacity(
                                            0.2,
                                          )
                                        : primaryColor.withOpacity(0.2),
                                    child: Icon(
                                      isLate
                                          ? Icons.warning_amber
                                          : Icons.receipt_long,
                                      color: isLate
                                          ? context.appColors.error
                                          : primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    '${doc.id} - ${doc.partnerName ?? 'N/A'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: context.appColors.textTitle,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Venc: ${doc.dueDate.day.toString().padLeft(2, '0')}/${doc.dueDate.month.toString().padLeft(2, '0')} | ${doc.description}',
                                  ),
                                  trailing: Text(
                                    'R\$ ${doc.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: context.appColors.textTitle,
                                    ),
                                  ),
                                  onTap: () => _selectDocument(doc),
                                );
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),

            // ==========================================
            // LADO DIREITO: FORMULÁRIO DE BAIXA
            // ==========================================
            Expanded(
              flex: 3,
              child: _selectedDocument == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 64,
                            color: context.appColors.textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Selecione um título ao lado\npara realizar a baixa.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: context.appColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Card(
                      color: context.appColors.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: context.appColors.textMuted.withOpacity(0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Processar $actionLabel',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: context.appColors.textTitle,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_selectedDocument!.id} - ${_selectedDocument!.description}',
                                style: TextStyle(
                                  color: context.appColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 24),

                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: context.appColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Valor Original:',
                                      style: TextStyle(
                                        color: context.appColors.textBody,
                                      ),
                                    ),
                                    Text(
                                      'R\$ ${_selectedDocument!.value.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: context.appColors.textTitle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: _pickDate,
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Data da Baixa',
                                          prefixIcon: Icon(
                                            Icons.event_available,
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        child: Text(
                                          '${_paymentDate.day.toString().padLeft(2, '0')}/${_paymentDate.month.toString().padLeft(2, '0')}/${_paymentDate.year}',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _amountController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}'),
                                        ),
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Valor Pago/Recebido (R\$)',
                                        prefixIcon: Icon(Icons.attach_money),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (val) =>
                                          val == null || val.isEmpty
                                          ? 'Obrigatório'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              BlocBuilder<BankAccountBloc, BankAccountState>(
                                builder: (context, state) {
                                  if (state is BankAccountLoaded) {
                                    final accounts = state.accounts
                                        .where((a) => a.isActive)
                                        .toList();
                                    final bool exists = accounts.any(
                                      (a) => a.id == _selectedBankAccountId,
                                    );
                                    return DropdownButtonFormField<int>(
                                      isExpanded: true,
                                      value: exists
                                          ? _selectedBankAccountId
                                          : null,
                                      decoration: const InputDecoration(
                                        labelText:
                                            'Conta Bancária (Destino/Origem)',
                                        prefixIcon: Icon(Icons.account_balance),
                                        border: OutlineInputBorder(),
                                      ),
                                      items: accounts
                                          .map(
                                            (acc) => DropdownMenuItem(
                                              value: acc.id,
                                              child: Text(acc.description),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) => setState(
                                        () => _selectedBankAccountId = val,
                                      ),
                                      validator: (val) =>
                                          val == null ? 'Obrigatório' : null,
                                    );
                                  }
                                  return const LinearProgressIndicator();
                                },
                              ),
                              const SizedBox(height: 16),

                              BlocBuilder<
                                PaymentMethodBloc,
                                PaymentMethodState
                              >(
                                builder: (context, state) {
                                  if (state is PaymentMethodLoaded) {
                                    final methods = state.methods
                                        .where((m) => m.isActive)
                                        .toList();
                                    final bool exists = methods.any(
                                      (m) => m.id == _selectedPaymentMethodId,
                                    );
                                    return DropdownButtonFormField<int>(
                                      isExpanded: true,
                                      value: exists
                                          ? _selectedPaymentMethodId
                                          : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Forma de Pagamento',
                                        prefixIcon: Icon(Icons.payments),
                                        border: OutlineInputBorder(),
                                      ),
                                      items: methods
                                          .map(
                                            (m) => DropdownMenuItem(
                                              value: m.id,
                                              child: Text(m.name),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) => setState(
                                        () => _selectedPaymentMethodId = val,
                                      ),
                                      validator: (val) =>
                                          val == null ? 'Obrigatório' : null,
                                    );
                                  }
                                  return const LinearProgressIndicator();
                                },
                              ),

                              const Spacer(),
                              SizedBox(
                                height: 50,
                                child: FilledButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : _handleSettle,
                                  icon: _isProcessing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.check_circle),
                                  label: Text(
                                    _isProcessing
                                        ? 'Processando...'
                                        : 'Confirmar $actionLabel',
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
