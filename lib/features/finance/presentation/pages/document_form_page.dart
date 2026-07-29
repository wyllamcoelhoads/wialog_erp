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

  // Controladores para Parcelas e ID Base
  late TextEditingController _installmentsController;
  late String _documentId;

  DateTime? _selectedDueDate;
  int? _selectedCategoryId;
  String? _selectedPartnerId;

  @override
  void initState() {
    super.initState();
    final doc = widget.document;

    // 1. Carrega as Categorias e Parceiros baseados no Tipo (Receita/Despesa)
    final categoryType = widget.isReceivable
        ? CategoryType.receivable
        : CategoryType.payable;
    final partnerType = widget.isReceivable
        ? PartnerType.client
        : PartnerType.supplier;

    context.read<CategoryBloc>().add(LoadCategories(type: categoryType));
    context.read<PartnerBloc>().add(LoadPartners(type: partnerType));

    // 2. Define o ID do documento ao abrir a tela
    _documentId = _isEditing
        ? doc!['id'].toString()
        : (100000 + Random().nextInt(899999)).toString();
    _installmentsController = TextEditingController(
      text: '1',
    ); // Padrão: 1 parcela

    // 3. Preenche os dados se for Edição
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textTitle,
            ),
          ),
          child: child!,
        );
      },
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          pageTitle,
          style: const TextStyle(
            color: AppColors.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Excluir Documento',
              onPressed: () {
                context.read<DocumentBloc>().add(
                  DeleteDocument(
                    widget.document!['id'],
                    widget.isReceivable
                        ? DocumentType.receivable
                        : DocumentType.payable,
                  ),
                );
                _closeTab(context);
              },
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentError && _isSaving) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is DocumentLoaded && _isSaving) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Documento salvo com sucesso!'),
                backgroundColor: AppColors.success,
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
                    _buildSectionTitle('Informações Principais'),
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    initialValue: _documentId,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Nº Documento',
                                      prefixIcon: const Icon(Icons.tag),
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                    ),
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
                                // SELETOR DE CATEGORIA (BLOC)
                                Expanded(
                                  child: BlocBuilder<CategoryBloc, CategoryState>(
                                    builder: (context, state) {
                                      if (state is CategoryLoading) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (state is CategoryLoaded) {
                                        // Trava de segurança contra o erro da tela vermelha
                                        final bool categoryExists = state
                                            .categories
                                            .any(
                                              (c) =>
                                                  c.id == _selectedCategoryId,
                                            );

                                        return DropdownButtonFormField<int>(
                                          initialValue: categoryExists
                                              ? _selectedCategoryId
                                              : null,
                                          decoration: const InputDecoration(
                                            labelText: 'Categoria',
                                            prefixIcon: Icon(
                                              Icons.category_outlined,
                                            ),
                                            border: OutlineInputBorder(),
                                          ),
                                          items: state.categories.map((cat) {
                                            return DropdownMenuItem<int>(
                                              value: cat.id,
                                              child: Text(cat.name),
                                            );
                                          }).toList(),
                                          onChanged: (value) => setState(
                                            () => _selectedCategoryId = value,
                                          ),
                                          validator: (value) => value == null
                                              ? 'Obrigatório'
                                              : null,
                                        );
                                      }
                                      return const Text('Erro ao carregar');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // SELETOR DE PARCEIRO (BLOC)
                                Expanded(
                                  child: BlocBuilder<PartnerBloc, PartnerState>(
                                    builder: (context, state) {
                                      if (state is PartnerLoading) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (state is PartnerLoaded) {
                                        // Trava de segurança contra o erro da tela vermelha
                                        final bool partnerExists = state
                                            .partners
                                            .any(
                                              (p) => p.id == _selectedPartnerId,
                                            );

                                        return DropdownButtonFormField<String>(
                                          initialValue: partnerExists
                                              ? _selectedPartnerId
                                              : null,
                                          decoration: InputDecoration(
                                            labelText: widget.isReceivable
                                                ? 'Cliente / Remetente'
                                                : 'Fornecedor / Favorecido',
                                            prefixIcon: const Icon(
                                              Icons.business_outlined,
                                            ),
                                            border: const OutlineInputBorder(),
                                          ),
                                          items: state.partners.map((partner) {
                                            return DropdownMenuItem<String>(
                                              value: partner.id,
                                              child: Text(partner.name),
                                            );
                                          }).toList(),
                                          onChanged: (value) => setState(
                                            () => _selectedPartnerId = value,
                                          ),
                                          validator: (value) => value == null
                                              ? 'Obrigatório'
                                              : null,
                                        );
                                      }
                                      return const Text('Erro ao carregar');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // SELETOR DE DATA
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectDate(context),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Data de Vencimento',
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
                                            ? 'Selecionar data'
                                            : '${_selectedDueDate!.day.toString().padLeft(2, '0')}/${_selectedDueDate!.month.toString().padLeft(2, '0')}/${_selectedDueDate!.year}',
                                      ),
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

                    // SEÇÃO DE PARCELAMENTO E OBSERVAÇÕES
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Parcelamento'),
                              Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: _buildTextField(
                                    controller: _installmentsController,
                                    label: 'Nº de Parcelas',
                                    icon: Icons.layers_outlined,
                                    isNumeric: true,
                                    readOnly:
                                        _isEditing, // Só parcela novos cadastros
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Observações Adicionais'),
                              Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: TextFormField(
                                    controller: _notesController,
                                    maxLines: 1,
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Detalhes ou centro de custo...',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.notes),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _closeTab(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _handleSave,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(_isEditing ? Icons.save_as : Icons.save),
                          label: Text(
                            _isSaving ? 'Salvando...' : 'Salvar Documento',
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: widget.isReceivable
                                ? AppColors.success
                                : AppColors.error,
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

  // AQUI ESTÁ A LÓGICA DE SALVAR QUE ESTAVA QUEBRADA/PERDIDA!
  void _handleSave() {
    if (!_formKey.currentState!.validate() ||
        _selectedDueDate == null ||
        _selectedCategoryId == null ||
        _selectedPartnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Formata os dados de valor e parcelas
    final double valorTotal =
        double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0.0;
    int parcelas = int.tryParse(_installmentsController.text) ?? 1;
    if (parcelas <= 0) parcelas = 1;

    if (_isEditing) {
      // MODO EDIÇÃO (Não mexe no parcelamento, só atualiza o documento único)
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
      // MODO CRIAÇÃO (Faz o loop para criar múltiplas parcelas se necessário)
      final double valorParcela = valorTotal / parcelas;

      for (int i = 1; i <= parcelas; i++) {
        // Se for 1 parcela, usa o ID normal. Se for mais, adiciona o traço (ex: 12001-1, 12001-2)
        String docId = parcelas == 1 ? _documentId : '$_documentId-$i';

        // Joga o vencimento 1 mês para frente a cada parcela (aproximação simples de 30 dias)
        DateTime dueDateParcela = DateTime(
          _selectedDueDate!.year,
          _selectedDueDate!.month + (i - 1),
          _selectedDueDate!.day,
        );

        // Ajusta a descrição para indicar a parcela se houver mais de uma
        String descricaoParcela = parcelas == 1
            ? _descriptionController.text
            : '${_descriptionController.text} (Parc $i/$parcelas)';

        final document = FinancialDocumentEntity(
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
          notes: _notesController.text,
        );

        context.read<DocumentBloc>().add(AddDocument(document));
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textTitle,
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
        fillColor: readOnly ? Colors.grey.shade100 : null,
        filled: readOnly,
      ),
      validator: isRequired
          ? (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null
          : null,
    );
  }
}
