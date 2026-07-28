import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:math'; // NOVO: Para gerar números aleatórios
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/partner_entity.dart';
import '../bloc/partner/partner_bloc.dart';
import '../bloc/partner/partner_event.dart';
import '../bloc/partner/partner_state.dart';

class ClientFormPage extends StatefulWidget {
  const ClientFormPage({super.key});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

// TUDO QUE MUDA (ESTADO) FICA AQUI DENTRO!
class _ClientFormPageState extends State<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controle de Pessoa Física ou Jurídica e Loading
  bool _isPF = false;
  bool _isSaving = false;

  // Definição das Máscaras
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

  // Controladores dos campos
  final _docController = TextEditingController();
  final _nameController = TextEditingController();
  final _fantasyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cepController = TextEditingController();
  final _cityController = TextEditingController();
  final _obsController = TextEditingController();

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
        title: const Text(
          'Cadastro de Cliente',
          style: TextStyle(
            color: AppColors.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // O BlocListener escuta as respostas do banco de dados
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
              const SnackBar(
                content: Text('Cliente salvo com sucesso!'),
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
                                  // Troca a máscara em tempo real
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
                                    inputFormatters: [
                                      _docMask,
                                    ], // Aplica a máscara
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
                                        inputFormatters: [
                                          _phoneMask,
                                        ], // Aplica a máscara
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
                                              inputFormatters: [
                                                _cepMask,
                                              ], // Aplica a máscara
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
                          onPressed: _isSaving
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _isSaving = true);

                                    final newClient = PartnerEntity(
                                      // Gera um número aleatório entre 100000 e 999999
                                      id: (100000 + Random().nextInt(899999))
                                          .toString(),
                                      name: _nameController.text,
                                      document: _docMask.getUnmaskedText(),
                                      type: PartnerType.client,
                                      contact: _phoneController.text.isNotEmpty
                                          ? _phoneController.text
                                          : _emailController.text,
                                      categoryOrCity: _cityController.text,
                                    );

                                    context.read<PartnerBloc>().add(
                                      AddPartner(newClient),
                                    );
                                  }
                                },
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _isSaving ? 'Salvando...' : 'Salvar Cliente',
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

  // NOVO: Adicionado inputFormatters para aceitar as máscaras!
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters, // Repassa para o Flutter
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
