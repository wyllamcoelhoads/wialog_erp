import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/finance/domain/entities/category_entity.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/category/category_event.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/partner_entity.dart';
import '../bloc/partner/partner_bloc.dart';
import '../bloc/partner/partner_event.dart';
import '../bloc/partner/partner_state.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_state.dart';

class SupplierFormPage extends StatefulWidget {
  final PartnerEntity? partner;

  const SupplierFormPage({super.key, this.partner});

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  bool get _isEditing => widget.partner != null;

  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cnpjController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _obsController = TextEditingController();

  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Busca apenas as categorias exclusivas de Fornecedores
    context.read<CategoryBloc>().add(
      const LoadCategories(type: CategoryType.supplier),
    );

    if (_isEditing) {
      _prefillFromPartner(widget.partner!);
    }
  }

  void _prefillFromPartner(PartnerEntity p) {
    _nameController.text = p.name;
    // Aplica a máscara no documento que vem limpo do banco
    _cnpjController.text = _cnpjMask.maskText(p.document);

    if (p.contact.contains('@')) {
      _emailController.text = p.contact;
    } else if (p.contact.isNotEmpty) {
      _phoneController.text = _phoneMask.maskText(p.contact);
    }

    _selectedCategoryId = p.categoryId;
  }

  @override
  void dispose() {
    _cnpjController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          _isEditing ? 'Editar Fornecedor' : 'Cadastro de Fornecedor',
          style: TextStyle(
            color: context.appColors.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: context.appColors.error),
              tooltip: 'Excluir Fornecedor',
              onPressed: () {
                context.read<PartnerBloc>().add(
                  DeletePartner(widget.partner!.id),
                );
                _closeTab(context);
              },
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocListener<PartnerBloc, PartnerState>(
        listener: (context, state) {
          if (state is PartnerError && _isSaving) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.appColors.error,
              ),
            );
          } else if (state is PartnerLoaded && _isSaving) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Fornecedor atualizado com sucesso!'
                      : 'Fornecedor salvo com sucesso!',
                ),
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
                    _buildSectionTitle('1. Identificação do Fornecedor'),
                    Card(
                      color: context.appColors.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: context.appColors.textMuted.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildTextField(
                                    controller: _cnpjController,
                                    label: 'CNPJ',
                                    icon: Icons.domain,
                                    isRequired: true,
                                    inputFormatters: [_cnpjMask],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 4,
                                  child: _buildTextField(
                                    controller: _nameController,
                                    label: 'Razão Social / Nome Fantasia',
                                    icon: Icons.business,
                                    isRequired: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            BlocBuilder<CategoryBloc, CategoryState>(
                              builder: (context, state) {
                                if (state is CategoryLoading) {
                                  return const CircularProgressIndicator();
                                }
                                if (state is CategoryLoaded) {
                                  // PROTEÇÃO: Garante que o ID selecionado existe na lista atual
                                  final bool categoryExists = state.categories
                                      .any(
                                        (cat) => cat.id == _selectedCategoryId,
                                      );
                                  final int? safeValue = categoryExists
                                      ? _selectedCategoryId
                                      : null;

                                  return DropdownButtonFormField<int>(
                                    initialValue: safeValue,
                                    decoration: const InputDecoration(
                                      labelText: 'Categoria',
                                      prefixIcon: Icon(Icons.category_outlined),
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
                                        ? 'Selecione uma categoria'
                                        : null,
                                  );
                                }
                                return const Text(
                                  "Erro ao carregar categorias",
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('2. Contato Principal'),
                              Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: context.appColors.textMuted
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    children: [
                                      _buildTextField(
                                        controller: _phoneController,
                                        label: 'Telefone Principal',
                                        icon: Icons.phone,
                                        inputFormatters: [_phoneMask],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _emailController,
                                        label: 'E-mail para Contato',
                                        icon: Icons.email_outlined,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('3. Detalhes Adicionais'),
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
                                    controller: _obsController,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Detalhes sobre condições de pagamento, prazos de entrega...',
                                      border: OutlineInputBorder(),
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
                            foregroundColor: context.appColors.error,
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
                            _isSaving
                                ? 'Salvando...'
                                : (_isEditing
                                      ? 'Atualizar Fornecedor'
                                      : 'Salvar Fornecedor'),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: context.appColors.primary,
                          ),
                        ),
                      ],
                    ),
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
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      return;
    }

    setState(() => _isSaving = true);
    // NOVO: Pega o texto do controlador e remove tudo que não for número
    final rawDocument = _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final supplier = PartnerEntity(
      id: _isEditing
          ? widget.partner!.id
          : (100000 + Random().nextInt(899999)).toString(),
      name: _nameController.text,
      document: rawDocument, // Salva apenas os números
      type: PartnerType.supplier,
      contact: _phoneController.text.isNotEmpty
          ? _phoneController.text
          : _emailController.text,
      city: null,
      categoryId: _selectedCategoryId,
      isActive: _isEditing
          ? widget.partner!.isActive
          : true, // Preserva o status original
    );

    if (_isEditing) {
      context.read<PartnerBloc>().add(UpdatePartner(supplier));
    } else {
      context.read<PartnerBloc>().add(AddPartner(supplier));
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
          fontSize: 16,
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: isRequired
          ? (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null
          : null,
    );
  }
}
