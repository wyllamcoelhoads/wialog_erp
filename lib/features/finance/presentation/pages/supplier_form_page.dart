import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:math'; // Para gerar números aleatórios (novo cadastro)
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/partner_entity.dart';
import '../bloc/partner/partner_bloc.dart';
import '../bloc/partner/partner_event.dart';
import '../bloc/partner/partner_state.dart';

import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_state.dart';

class SupplierFormPage extends StatefulWidget {
  // NOVO: se vier preenchido, a tela entra em modo de edição
  final PartnerEntity? partner;

  const SupplierFormPage({super.key, this.partner});

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controle de salvamento
  bool _isSaving = false;

  // NOVO: se estamos editando um fornecedor já existente
  bool get _isEditing => widget.partner != null;

  // Máscaras fixas para Fornecedor
  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Controladores
  final _cnpjController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _obsController = TextEditingController();

  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _prefillFromPartner(widget.partner!);
    }
  }

  // NOVO: preenche o formulário com os dados do fornecedor a ser editado
  void _prefillFromPartner(PartnerEntity p) {
    _nameController.text = p.name;
    _cnpjController.text = _cnpjMask.maskText(p.document);

    // O campo "contact" guarda telefone OU e-mail (o form original salva só um).
    // Assumindo que contatos com "@" são e-mail e o restante é telefone.
    if (p.contact.contains('@')) {
      _emailController.text = p.contact;
    } else if (p.contact.isNotEmpty) {
      _phoneController.text = _phoneMask.maskText(p.contact);
    }

    _selectedCategoryId = p.categoryId;
    // Observação: "obs" não existe hoje em PartnerEntity,
    // então não há de onde recuperá-la ao editar (ver nota no chat).
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          _isEditing ? 'Editar Fornecedor' : 'Cadastro de Fornecedor',
          style: const TextStyle(
            color: AppColors.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<PartnerBloc, PartnerState>(
        listener: (context, state) {
          if (state is PartnerError && _isSaving) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
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
                    // ==========================================
                    // SEÇÃO 1: IDENTIFICAÇÃO
                    // ==========================================
                    _buildSectionTitle('1. Identificação do Fornecedor'),
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
                                  return DropdownButtonFormField<int>(
                                    initialValue: _selectedCategoryId,
                                    decoration: const InputDecoration(
                                      labelText: 'Categoria de Fornecimento',
                                      prefixIcon: Icon(Icons.category_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: state.categories.map((cat) {
                                      return DropdownMenuItem(
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

                    // ==========================================
                    // SEÇÃO 2: CONTATO
                    // ==========================================
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
                                  side: BorderSide(color: Colors.grey.shade200),
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
                        // ==========================================
                        // SEÇÃO 3: OBSERVAÇÕES
                        // ==========================================
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
                                          'Detalhes sobre condições de pagamento, prazos de entrega ou nomes de vendedores...',
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

                    // ==========================================
                    // BOTÕES
                    // ==========================================
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
                            backgroundColor: AppColors.primary,
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

  // NOVO: extraído do onPressed para lidar com criação e edição
  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final supplier = PartnerEntity(
      // Mantém o id original ao editar; gera um novo ao criar
      id: _isEditing
          ? widget.partner!.id
          : (100000 + Random().nextInt(899999)).toString(),
      name: _nameController.text,
      document: _cnpjMask.getUnmaskedText(),
      type: PartnerType.supplier,
      contact: _phoneController.text.isNotEmpty
          ? _phoneController.text
          : _emailController.text,
      city: null, // Fornecedores não usam o campo 'city'
      categoryId: _selectedCategoryId,
      isActive: _isEditing ? widget.partner!.isActive : true,
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
        style: const TextStyle(
          fontSize: 16,
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
