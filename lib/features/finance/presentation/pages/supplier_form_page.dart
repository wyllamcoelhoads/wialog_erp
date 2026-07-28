import 'package:flutter/material.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/partner_entity.dart';
import '../bloc/partner/partner_bloc.dart';
import '../bloc/partner/partner_event.dart';

class SupplierFormPage extends StatefulWidget {
  const SupplierFormPage({super.key});

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _cnpjController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _obsController = TextEditingController();

  String _selectedCategory = 'Combustível';

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
        title: const Text(
          'Cadastro de Fornecedor',
          style: TextStyle(
            color: AppColors.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('Identificação do Fornecedor'),
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
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 4,
                                child: _buildTextField(
                                  controller: _nameController,
                                  label: 'Razão Social / Nome',
                                  icon: Icons.business,
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: const InputDecoration(
                                    labelText: 'Categoria do Fornecedor',
                                    prefixIcon: Icon(Icons.category_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      [
                                            'Combustível',
                                            'Manutenção/Peças',
                                            'Seguros',
                                            'Impostos/Taxas',
                                            'Outros',
                                          ]
                                          .map(
                                            (cat) => DropdownMenuItem(
                                              value: cat,
                                              child: Text(cat),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedCategory = val!),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildTextField(
                                  controller: _phoneController,
                                  label: 'Telefone Principal',
                                  icon: Icons.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _emailController,
                            label: 'E-mail para Contato',
                            icon: Icons.email_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

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
                        controller: _obsController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Detalhes sobre condições de pagamento, prazos de entrega...',
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // NOVO: Instancia a Entidade do Fornecedor
                            final newSupplier = PartnerEntity(
                              id: 'FOR-${DateTime.now().millisecondsSinceEpoch}',
                              name: _nameController.text,
                              document: _cnpjController.text,
                              type: PartnerType.supplier,
                              contact: _phoneController.text.isNotEmpty
                                  ? _phoneController.text
                                  : _emailController.text,
                              categoryOrCity: _selectedCategory,
                            );

                            // Dispara pro PostgreSQL
                            context.read<PartnerBloc>().add(
                              AddPartner(newSupplier),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fornecedor salvo com sucesso!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            _closeTab(context);
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar Fornecedor'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
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
