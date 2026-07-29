import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/partner_entity.dart';
import '../bloc/partner/partner_bloc.dart';
import '../bloc/partner/partner_event.dart';
import '../bloc/partner/partner_state.dart';

class ClientFormPage extends StatefulWidget {
  final PartnerEntity? partner;

  const ClientFormPage({super.key, this.partner});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isPF = false;
  bool _isSaving = false;
  bool get _isEditing => widget.partner != null;

  final _docMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _docController = TextEditingController();
  final _nameController = TextEditingController();
  final _fantasyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cepController = TextEditingController();
  final _cityController = TextEditingController();
  final _obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _prefillFromPartner(widget.partner!);
    }
  }

  void _prefillFromPartner(PartnerEntity p) {
    _isPF = p.document.length <= 11;
    _docMask.updateMask(mask: _isPF ? '###.###.###-##' : '##.###.###/####-##');

    _nameController.text = p.name;
    // Garante que o documento vindo do banco seja formatado na tela
    _docController.text = _docMask.maskText(p.document);
    _cityController.text = p.city ?? '';

    if (p.contact.contains('@')) {
      _emailController.text = p.contact;
    } else if (p.contact.isNotEmpty) {
      _phoneController.text = _phoneMask.maskText(p.contact);
    }
  }

  @override
  void dispose() {
    _docController.dispose();
    _nameController.dispose();
    _fantasyNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cepController.dispose();
    _cityController.dispose();
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
          _isEditing ? 'Editar Cliente' : 'Cadastro de Cliente',
          style: const TextStyle(
            color: AppColors.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Excluir Cliente',
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
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is PartnerLoaded && _isSaving) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Cliente atualizado com sucesso!'
                      : 'Cliente salvo com sucesso!',
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
                    _buildSectionTitle('1. Identificação'),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                  value: false,
                                  label: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text('Pessoa Jurídica (PJ)'),
                                  ),
                                ),
                                ButtonSegment(
                                  value: true,
                                  label: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text('Pessoa Física (PF)'),
                                  ),
                                ),
                              ],
                              selected: {_isPF},
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _isPF = selection.first;
                                  _docController.clear();
                                  _docMask.updateMask(
                                    mask: _isPF
                                        ? '###.###.###-##'
                                        : '##.###.###/####-##',
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildTextField(
                                    controller: _docController,
                                    label: _isPF ? 'CPF' : 'CNPJ',
                                    icon: Icons.badge_outlined,
                                    isRequired: true,
                                    inputFormatters: [_docMask],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 4,
                                  child: _buildTextField(
                                    controller: _nameController,
                                    label: _isPF
                                        ? 'Nome Completo'
                                        : 'Razão Social',
                                    icon: _isPF
                                        ? Icons.person_outline
                                        : Icons.business_outlined,
                                    isRequired: true,
                                  ),
                                ),
                              ],
                            ),
                            if (!_isPF) ...[
                              const SizedBox(height: 24),
                              _buildTextField(
                                controller: _fantasyNameController,
                                label: 'Nome Fantasia',
                                icon: Icons.storefront_outlined,
                              ),
                            ],
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
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    children: [
                                      _buildTextField(
                                        controller: _phoneController,
                                        label: 'Telefone / WhatsApp',
                                        icon: Icons.phone_outlined,
                                        inputFormatters: [_phoneMask],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _emailController,
                                        label: 'E-mail',
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
                              _buildSectionTitle('3. Endereço e Faturamento'),
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
                                            child: _buildTextField(
                                              controller: _cepController,
                                              label: 'CEP',
                                              icon: Icons.map_outlined,
                                              inputFormatters: [_cepMask],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            flex: 2,
                                            child: _buildTextField(
                                              controller: _cityController,
                                              label: 'Cidade/UF',
                                              icon:
                                                  Icons.location_city_outlined,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _obsController,
                                        maxLines: 1,
                                        decoration: const InputDecoration(
                                          labelText: 'Observações de Cobrança',
                                          prefixIcon: Icon(Icons.notes),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
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
                            _isSaving
                                ? 'Salvando...'
                                : (_isEditing
                                      ? 'Atualizar Cliente'
                                      : 'Salvar Cliente'),
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

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final client = PartnerEntity(
      id: _isEditing
          ? widget.partner!.id
          : (100000 + Random().nextInt(899999)).toString(),
      name: _nameController.text,
      document: _docMask.getUnmaskedText(), // Salva sem pontuação
      type: PartnerType.client,
      contact: _phoneController.text.isNotEmpty
          ? _phoneController.text
          : _emailController.text,
      city: _cityController.text,
      categoryId: null,
      isActive: _isEditing
          ? widget.partner!.isActive
          : true, // Preserva o status ao editar
    );

    if (_isEditing) {
      context.read<PartnerBloc>().add(UpdatePartner(client));
    } else {
      context.read<PartnerBloc>().add(AddPartner(client));
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
