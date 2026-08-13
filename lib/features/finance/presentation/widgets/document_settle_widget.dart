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
  final DocumentType type;

  const DocumentSettleWidget({super.key, required this.type});

  @override
  State<DocumentSettleWidget> createState() => _DocumentSettleWidgetState();
}

class _DocumentSettleWidgetState extends State<DocumentSettleWidget> {
  FinancialDocumentEntity? _selectedDocument;

  // Controles do Formulário de Baixa
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  int? _selectedBankAccountId;
  int? _selectedPaymentMethodId;
  bool _isProcessing = false;

  // Controles do Filtro de Pesquisa Avançada
  final _searchController = TextEditingController();
  bool _searchAll = false;
  bool _filterByIssueDate = false;
  bool _isOverdue = false;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Limpa a tela de pesquisa ao abrir (Força o usuário a pesquisar antes)
    context.read<DocumentBloc>().add(ClearDocuments());

    // Carrega bancos e meios de pagamento em background para o formulário
    context.read<BankAccountBloc>().add(const LoadBankAccounts());
    context.read<PaymentMethodBloc>().add(const LoadPaymentMethods());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    // Trava de segurança: obriga a digitar o nome se não marcou "Pesquisar Todos"
    if (!_searchAll && _searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Informe o nome do parceiro/ID ou marque a flag "Listar Todos".',
          ),
          backgroundColor: context.appColors.warning,
        ),
      );
      return;
    }

    // Dispara a busca com todos os parâmetros do painel
    context.read<DocumentBloc>().add(
      LoadDocuments(
        type: widget.type,
        query: _searchController.text,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
        filterByIssueDate: _filterByIssueDate,
        isOverdue: _isOverdue,
      ),
    );
  }

  void _selectDocument(FinancialDocumentEntity doc) {
    setState(() {
      _selectedDocument = doc;
      // 👇 Agora ele sugere pagar o SALDO (balance) e não o valor original (value)
      _amountController.text = doc.balance.toStringAsFixed(2);
      _amountController.text = doc.value.toStringAsFixed(2);
      _paymentDate = DateTime.now();
      _selectedBankAccountId = doc.bankAccountId;
      _selectedPaymentMethodId = doc.paymentMethodId;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
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
      setState(() => _selectedDateRange = picked);
    }
  }

  Future<void> _pickPaymentDate() async {
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
            _selectedDocument = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$actionLabel processado com sucesso!'),
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
            // LADO ESQUERDO: FILTROS + LISTA
            // ==========================================
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.appColors.border.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // PAINEL DE FILTROS AVANÇADOS
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.appColors.background.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  enabled: !_searchAll,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Nome/Documento do Parceiro ou Nº do Título...',
                                    prefixIcon: const Icon(Icons.search),
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                    filled: _searchAll,
                                    fillColor: _searchAll
                                        ? Colors.grey.shade200
                                        : context.appColors.surface,
                                  ),
                                  onSubmitted: (_) => _loadData(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  Switch(
                                    value: _searchAll,
                                    activeThumbColor: context.appColors.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        _searchAll = val;
                                        if (val) _searchController.clear();
                                      });
                                    },
                                  ),
                                  Text(
                                    'Listar Todos',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: context.appColors.textTitle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<bool>(
                                  initialValue: _filterByIssueDate,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                    filled: true,
                                    fillColor: context.appColors.surface,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: false,
                                      child: Text('Filtrar por Vencimento'),
                                    ),
                                    DropdownMenuItem(
                                      value: true,
                                      child: Text('Filtrar por Emissão'),
                                    ),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => _filterByIssueDate = val!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickDateRange,
                                  icon: const Icon(Icons.calendar_month),
                                  label: Text(
                                    _selectedDateRange == null
                                        ? 'Período: Qualquer'
                                        : '${_selectedDateRange!.start.day.toString().padLeft(2, '0')}/${_selectedDateRange!.start.month.toString().padLeft(2, '0')} até ${_selectedDateRange!.end.day.toString().padLeft(2, '0')}/${_selectedDateRange!.end.month.toString().padLeft(2, '0')}',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    backgroundColor: context.appColors.surface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isOverdue,
                                    activeColor: context.appColors.error,
                                    onChanged: (val) =>
                                        setState(() => _isOverdue = val!),
                                  ),
                                  Text(
                                    'Apenas Títulos Vencidos/Atrasados',
                                    style: TextStyle(
                                      color: context.appColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              FilledButton.icon(
                                onPressed:
                                    context.watch<DocumentBloc>().state
                                        is DocumentLoading
                                    ? null
                                    : _loadData,
                                icon: const Icon(Icons.manage_search),
                                label: const Text('Aplicar Filtros'),
                                style: FilledButton.styleFrom(
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
                    ),
                    const Divider(height: 1),

                    // LISTA DE RESULTADOS
                    Expanded(
                      child: BlocBuilder<DocumentBloc, DocumentState>(
                        builder: (context, state) {
                          if (state is DocumentInitial) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.manage_search,
                                    size: 64,
                                    color: context.appColors.textMuted
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Utilize os filtros acima e clique em "Aplicar Filtros"\npara carregar os títulos pendentes.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: context.appColors.textMuted,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (state is DocumentLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state is DocumentLoaded &&
                              state.type == widget.type) {
                            // 👇 Filtra Títulos Pendentes OU Parciais
                            final pendingDocs = state.documents
                                .where(
                                  (d) =>
                                      d.status == DocumentStatus.pending ||
                                      d.status == DocumentStatus.partial,
                                )
                                .toList();

                            if (pendingDocs.isEmpty) {
                              return Center(
                                child: Text(
                                  'Nenhum título pendente encontrado para este filtro.',
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
                                  selectedTileColor: primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: isLate
                                        ? context.appColors.error.withValues(
                                            alpha: 0.2,
                                          )
                                        : primaryColor.withValues(alpha: 0.2),
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
                                  // 👇 Mostra o saldo devedor na lista esquerda
                                  trailing: Text(
                                    'Falta:\nR\$ ${doc.balance.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
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
              flex: 4,
              child: _selectedDocument == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 64,
                            color: context.appColors.textMuted.withValues(
                              alpha: 0.5,
                            ),
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
                          color: context.appColors.border.withValues(
                            alpha: 0.2,
                          ),
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
                                      onTap: _pickPaymentDate,
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
                                      initialValue: exists
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
                                              child: Text(
                                                acc.description,
                                                overflow: TextOverflow.ellipsis,
                                              ),
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
                                      initialValue: exists
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
                                              child: Text(
                                                m.name,
                                                overflow: TextOverflow.ellipsis,
                                              ),
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
