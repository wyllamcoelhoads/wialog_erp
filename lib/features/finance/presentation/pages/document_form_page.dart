import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';
import 'dart:math';

import '../../../../core/theme/app_colors.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/partner_entity.dart';
import '../../domain/entities/financial_document_entity.dart';

import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_event.dart';
import '../bloc/category/category_state.dart';

import '../bloc/partner/partner_bloc.dart';
import '../bloc/partner/partner_event.dart';
import '../bloc/partner/partner_state.dart';

import '../bloc/document/document_bloc.dart';
import '../bloc/document/document_event.dart';
import '../bloc/document/document_state.dart';

class DocumentFormPage extends StatefulWidget {
  final Map<String, dynamic>? document;
  final bool isReceivable;

  const DocumentFormPage({super.key, this.document, this.isReceivable = false});

  @override
  State<DocumentFormPage> createState() => _DocumentFormPageState();
}

class _DocumentFormPageState extends State<DocumentFormPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  bool get _isEditing => widget.document != null;

  late TextEditingController _descriptionController;
  late TextEditingController _valueController;
  late TextEditingController _notesController;
  late TextEditingController _installmentsController;
  late String _documentId;

  DateTime? _selectedDueDate;
  int? _selectedCategoryId;
  String? _selectedPartnerId;
  String _installmentInterval = 'Mensal'; // Padrão

  // NOVO: Lista temporária para a Subgrid (Preview)
  List<FinancialDocumentEntity> _previewInstallments = [];

  @override
  void initState() {
    super.initState();
    final doc = widget.document;

    final categoryType = widget.isReceivable
        ? CategoryType.receivable
        : CategoryType.payable;
    final partnerType = widget.isReceivable
        ? PartnerType.client
        : PartnerType.supplier;

    context.read<CategoryBloc>().add(LoadCategories(type: categoryType));
    context.read<PartnerBloc>().add(LoadPartners(type: partnerType));

    _documentId = _isEditing
        ? doc!['id'].toString()
        : (100000 + Random().nextInt(899999)).toString();
    _installmentsController = TextEditingController(text: '1');

    if (_isEditing && doc != null) {
      _selectedCategoryId = doc['category_id'] as int?;
      _selectedPartnerId = doc['partner_id'] as String?;
      if (doc['due_date'] != null) {
        _selectedDueDate = DateTime.parse(doc['due_date'].toString());
      }
    }

    _descriptionController = TextEditingController(
      text: doc?['description'] ?? '',
    );
    _valueController = TextEditingController(
      text: doc != null ? doc['value'].toString() : '',
    );
    _notesController = TextEditingController(text: doc?['notes'] ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    _installmentsController.dispose();
    super.dispose();
  }

  // Helper de Datas para resolver o bug do dia 31 (Ex: 31/08 -> 30/09 e não 01/10)
  DateTime _addMonthsFixed(DateTime date, int monthsToAdd) {
    int newYear = date.year;
    int newMonth = date.month + monthsToAdd;

    while (newMonth > 12) {
      newYear++;
      newMonth -= 12;
    }

    // Descobre qual é o último dia do novo mês gerado
    int lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;

    // Se o dia original for maior que o último dia do mês alvo, trava no último dia
    int newDay = date.day > lastDayOfNewMonth ? lastDayOfNewMonth : date.day;

    return DateTime(newYear, newMonth, newDay);
  }

  // Gera o Preview das parcelas
  void _generatePreview() {
    if (!_formKey.currentState!.validate() ||
        _selectedDueDate == null ||
        _selectedCategoryId == null ||
        _selectedPartnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Preencha as Informações Principais antes de gerar parcelas.',
          ),
          backgroundColor: context.appColors.error,
        ),
      );
      return;
    }

    final double valorTotal =
        double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0.0;
    int parcelas = int.tryParse(_installmentsController.text) ?? 1;
    if (parcelas <= 0) parcelas = 1;

    final double valorParcela = valorTotal / parcelas;
    List<FinancialDocumentEntity> geradas = [];

    for (int i = 1; i <= parcelas; i++) {
      String docId = parcelas == 1 ? _documentId : '$_documentId-$i';
      DateTime dueDateParcela;

      // Cálculo de intervalo inteligente
      if (_installmentInterval == 'Mensal') {
        dueDateParcela = _addMonthsFixed(_selectedDueDate!, i - 1);
      } else if (_installmentInterval == 'Quinzenal') {
        dueDateParcela = _selectedDueDate!.add(Duration(days: 15 * (i - 1)));
      } else if (_installmentInterval == 'Semanal') {
        dueDateParcela = _selectedDueDate!.add(Duration(days: 7 * (i - 1)));
      } else {
        // Diário
        dueDateParcela = _selectedDueDate!.add(Duration(days: i - 1));
      }

      String descricaoParcela = parcelas == 1
          ? _descriptionController.text
          : '${_descriptionController.text} (Parc $i/$parcelas)';

      geradas.add(
        FinancialDocumentEntity(
          id: docId,
          description: descricaoParcela,
          type: widget.isReceivable
              ? DocumentType.receivable
              : DocumentType.payable,
          value: double.parse(valorParcela.toStringAsFixed(2)),
          balance: double.parse(valorParcela.toStringAsFixed(2)),
          issueDate: DateTime.now(),
          dueDate: dueDateParcela,
          categoryId: _selectedCategoryId!,
          partnerId: _selectedPartnerId!,
          status: DocumentStatus.pending,
        ),
      );
    }

    setState(() {
      _previewInstallments = geradas;
    });
  }

  // Altera a data de uma parcela específica na grid
  Future<void> _editPreviewDate(int index) async {
    final current = _previewInstallments[index].dueDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current,
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

    if (picked != null && picked != current) {
      setState(() {
        // Recria a entidade com a nova data
        final old = _previewInstallments[index];
        _previewInstallments[index] = FinancialDocumentEntity(
          id: old.id,
          description: old.description,
          type: old.type,
          value: old.value,
          balance: old.balance,
          issueDate: old.issueDate,
          dueDate: picked,
          categoryId: old.categoryId,
          partnerId: old.partnerId,
          status: old.status,
        );
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String pageTitle = _isEditing
        ? 'Documento #${widget.document!['id']}'
        : (widget.isReceivable
              ? 'Nova Receita (Faturamento)'
              : 'Novo Lançamento (Despesa)');

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          pageTitle,
          style: TextStyle(
            color: context.appColors.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentError && _isSaving) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.appColors.error,
              ),
            );
          } else if (state is DocumentLoaded && _isSaving) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Documentos salvos com sucesso!'),
                backgroundColor: context.appColors.success,
              ),
            );
            _closeTab(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // INFORMAÇÕES PRINCIPAIS
                    _buildSectionTitle('Informações Principais'),
                    Card(
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _buildTextField(
                                    controller: TextEditingController(
                                      text: _documentId,
                                    ),
                                    label: 'Nº Documento',
                                    icon: Icons.tag,
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 3,
                                  child: _buildTextField(
                                    controller: _descriptionController,
                                    label: 'Descrição do Lançamento',
                                    icon: Icons.description_outlined,
                                    isRequired: true,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 1,
                                  child: _buildTextField(
                                    controller: _valueController,
                                    label: 'Valor Total (R\$)',
                                    icon: Icons.attach_money,
                                    isRequired: true,
                                    isNumeric: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: BlocBuilder<CategoryBloc, CategoryState>(
                                    builder: (context, state) {
                                      if (state is CategoryLoaded) {
                                        final bool exists = state.categories
                                            .any(
                                              (c) =>
                                                  c.id == _selectedCategoryId,
                                            );
                                        return DropdownButtonFormField<int>(
                                          isExpanded:
                                              true, // <-- MUDANÇA AQUI: Evita quebra de tela
                                          value: exists
                                              ? _selectedCategoryId
                                              : null,
                                          decoration: const InputDecoration(
                                            labelText: 'Categoria',
                                            prefixIcon: Icon(
                                              Icons.category_outlined,
                                            ),
                                            border: OutlineInputBorder(),
                                          ),
                                          items: state.categories
                                              .map(
                                                (cat) => DropdownMenuItem(
                                                  value: cat.id,
                                                  child: Text(
                                                    cat.name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                              .toList(), // <-- MUDANÇA AQUI: Adiciona os ...
                                          onChanged: (val) => setState(
                                            () => _selectedCategoryId = val,
                                          ),
                                          validator: (val) => val == null
                                              ? 'Obrigatório'
                                              : null,
                                        );
                                      }
                                      return const CircularProgressIndicator();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: BlocBuilder<PartnerBloc, PartnerState>(
                                    builder: (context, state) {
                                      if (state is PartnerLoaded) {
                                        final bool exists = state.partners.any(
                                          (p) => p.id == _selectedPartnerId,
                                        );
                                        return DropdownButtonFormField<String>(
                                          isExpanded: true, // <-- MUDANÇA AQUI
                                          value: exists
                                              ? _selectedPartnerId
                                              : null,
                                          decoration: InputDecoration(
                                            labelText: widget.isReceivable
                                                ? 'Cliente'
                                                : 'Fornecedor',
                                            prefixIcon: const Icon(
                                              Icons.business,
                                            ),
                                            border: const OutlineInputBorder(),
                                          ),
                                          items: state.partners
                                              .map(
                                                (p) => DropdownMenuItem(
                                                  value: p.id,
                                                  child: Text(
                                                    p.name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                              .toList(), // <-- MUDANÇA AQUI
                                          onChanged: (val) => setState(
                                            () => _selectedPartnerId = val,
                                          ),
                                          validator: (val) => val == null
                                              ? 'Obrigatório'
                                              : null,
                                        );
                                      }
                                      return const CircularProgressIndicator();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectDate(context),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Data Base / 1º Venc.',
                                        prefixIcon: const Icon(
                                          Icons.calendar_today,
                                        ),
                                        border: const OutlineInputBorder(),
                                        errorText: _selectedDueDate == null
                                            ? 'Obrigatório'
                                            : null,
                                      ),
                                      child: Text(
                                        _selectedDueDate == null
                                            ? 'Selecionar'
                                            : '${_selectedDueDate!.day.toString().padLeft(2, '0')}/${_selectedDueDate!.month.toString().padLeft(2, '0')}/${_selectedDueDate!.year}',
                                        overflow: TextOverflow.ellipsis,
                                      ), // <-- MUDANÇA AQUI
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SEÇÃO DE PARCELAMENTO (SUBGRID)
                    if (!_isEditing) ...[
                      _buildSectionTitle('Geração de Parcelas'),
                      Card(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _installmentsController,
                                      label: 'Qtd. Parcelas',
                                      icon: Icons.layers_outlined,
                                      isNumeric: true,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true, // <-- MUDANÇA AQUI
                                      value: _installmentInterval,
                                      decoration: const InputDecoration(
                                        labelText: 'Intervalo',
                                        prefixIcon: Icon(Icons.update),
                                        border: OutlineInputBorder(),
                                      ),
                                      items:
                                          [
                                                'Diário',
                                                'Semanal',
                                                'Quinzenal',
                                                'Mensal',
                                              ]
                                              .map(
                                                (s) => DropdownMenuItem(
                                                  value: s,
                                                  child: Text(
                                                    s,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                              .toList(), // <-- MUDANÇA AQUI
                                      onChanged: (val) => setState(
                                        () => _installmentInterval = val!,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: SizedBox(
                                      height: 55,
                                      child: ElevatedButton.icon(
                                        onPressed: _generatePreview,
                                        icon: const Icon(
                                          Icons.auto_awesome,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Gerar Previsão',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              context.appColors.info,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (_previewInstallments.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  'Confirme ou altere as datas antes de salvar:',
                                  style: TextStyle(
                                    color: context.appColors.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: context.appColors.textMuted
                                          .withOpacity(0.2),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      context.appColors.background,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text('Documento')),
                                      DataColumn(label: Text('Descrição')),
                                      DataColumn(label: Text('Valor (R\$)')),
                                      DataColumn(
                                        label: Text(
                                          'Vencimento (Clique p/ Editar)',
                                        ),
                                      ),
                                    ],
                                    rows: _previewInstallments.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final parc = entry.value;
                                      final dateStr =
                                          '${parc.dueDate.day.toString().padLeft(2, '0')}/${parc.dueDate.month.toString().padLeft(2, '0')}/${parc.dueDate.year}';

                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              parc.id,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(parc.description)),
                                          DataCell(
                                            Text(
                                              'R\$ ${parc.value.toStringAsFixed(2)}',
                                            ),
                                          ),
                                          DataCell(
                                            InkWell(
                                              onTap: () =>
                                                  _editPreviewDate(index),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    dateStr,
                                                    style: TextStyle(
                                                      color: context
                                                          .appColors
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Icon(
                                                    Icons.edit_calendar,
                                                    size: 16,
                                                    color: context
                                                        .appColors
                                                        .primary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    _buildSectionTitle('Observações Adicionais'),
                    Card(
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
                        child: TextFormField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: 'Detalhes...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _closeTab(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.appColors.error,
                          ),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _handleSave,
                          icon: _isSaving
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.save),
                          label: Text(
                            _isSaving ? 'Salvando...' : 'Salvar Documento(s)',
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: widget.isReceivable
                                ? context.appColors.success
                                : context.appColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate() ||
        _selectedDueDate == null ||
        _selectedCategoryId == null ||
        _selectedPartnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha os campos obrigatórios.'),
          backgroundColor: context.appColors.warning,
        ),
      );
      return;
    }

    // Trava de segurança: Se for cadastro novo, obriga a gerar a preview antes de salvar
    if (!_isEditing && _previewInstallments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, clique em "Gerar Previsão" antes de salvar.',
          ),
          backgroundColor: context.appColors.error,
        ),
      );
      return;
    }

    // Trava de segurança: Se for cadastro novo, obriga a gerar a preview antes de salvar
    if (!_isEditing && _previewInstallments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, clique em "Gerar Previsão" antes de salvar.',
          ),
          backgroundColor: context.appColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    if (_isEditing) {
      // MODO EDIÇÃO
      final valorTotal =
          double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0.0;
      final document = FinancialDocumentEntity(
        id: _documentId,
        description: _descriptionController.text,
        type: widget.isReceivable
            ? DocumentType.receivable
            : DocumentType.payable,
        value: valorTotal,
        balance: double.parse(widget.document!['balance'].toString()),
        issueDate: DateTime.parse(widget.document!['issue_date'].toString()),
        dueDate: _selectedDueDate!,
        categoryId: _selectedCategoryId!,
        partnerId: _selectedPartnerId!,
        status: widget.document!['status'] == 'paid'
            ? DocumentStatus.paid
            : DocumentStatus.pending,
        notes: _notesController.text,
      );
      context.read<DocumentBloc>().add(UpdateDocument(document));
    } else {
      // MODO CRIAÇÃO (Salva todas as parcelas geradas na Preview)
      for (var doc in _previewInstallments) {
        // Injeta a observação atualizada em todas as parcelas antes de disparar
        final docToSave = FinancialDocumentEntity(
          id: doc.id,
          description: doc.description,
          type: doc.type,
          value: doc.value,
          balance: doc.balance,
          issueDate: doc.issueDate,
          dueDate: doc.dueDate,
          categoryId: doc.categoryId,
          partnerId: doc.partnerId,
          status: doc.status,
          notes: _notesController.text, // Atualiza a obs
        );
        context.read<DocumentBloc>().add(AddDocument(docToSave));
      }
    }
  }

  void _closeTab(BuildContext context) {
    try {
      DashboardPage.of(context).closeCurrentTab();
    } catch (_) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.appColors.textTitle,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    bool isNumeric = false,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        fillColor: readOnly
            ? context.appColors.textMuted.withOpacity(0.05)
            : null,
        filled: readOnly,
      ),
      validator: isRequired
          ? (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null
          : null,
    );
  }
}
