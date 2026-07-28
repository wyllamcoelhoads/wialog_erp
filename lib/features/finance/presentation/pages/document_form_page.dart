import 'package:flutter/material.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';

class DocumentFormPage extends StatefulWidget {
  final Map<String, dynamic>? document;

  // NOVO: Essa flag define se a tela é de Receita ou de Despesa.
  // Colocamos o padrão false para não quebrar a tela de Contas a Pagar que já existe!
  final bool isReceivable;

  const DocumentFormPage({super.key, this.document, this.isReceivable = false});

  @override
  State<DocumentFormPage> createState() => _DocumentFormPageState();
}

class _DocumentFormPageState extends State<DocumentFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descriptionController;
  late TextEditingController _valueController;
  late TextEditingController _dueDateController;
  late TextEditingController _supplierController;
  late TextEditingController _notesController;

  late String
  _selectedCategory; // NOVO: late para iniciarmos de acordo com o tipo

  @override
  void initState() {
    super.initState();
    final doc = widget.document;

    // Inicia a categoria padrão baseada no tipo de documento
    _selectedCategory = widget.isReceivable
        ? 'Frete Lotação'
        : 'Despesa Operacional';

    _descriptionController = TextEditingController(
      text: doc?['description'] ?? '',
    );
    _valueController = TextEditingController(
      text: doc != null ? doc['value'].toStringAsFixed(2) : '',
    );
    _dueDateController = TextEditingController(text: doc?['dueDate'] ?? '');
    _supplierController = TextEditingController(
      text: doc != null ? 'Fornecedor Exemplo' : '',
    );
    _notesController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    _dueDateController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.document != null;

    // Título dinâmico
    final String pageTitle = isEditing
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
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Excluir',
              onPressed: () {
                // TODO: Lógica de exclusão
              },
            ),
          const SizedBox(width: 16),
        ],
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
                  // Descomentamos a função e usamos ela aqui!
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
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Descrição do Lançamento',
                            icon: Icons.description_outlined,
                            isRequired: true,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: const InputDecoration(
                                    labelText: 'Categoria',
                                    prefixIcon: Icon(Icons.category_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  // LISTA DINÂMICA DE CATEGORIAS
                                  items:
                                      (widget.isReceivable
                                              ? [
                                                  'Frete Lotação',
                                                  'Frete Fracionado',
                                                  'Contrato Mensal',
                                                  'Outras Receitas',
                                                ]
                                              : [
                                                  'Despesa Operacional',
                                                  'Impostos',
                                                  'Folha de Pagamento',
                                                  'Manutenção da Frota',
                                                ])
                                          .map(
                                            (cat) => DropdownMenuItem(
                                              value: cat,
                                              child: Text(cat),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedCategory = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildTextField(
                                  controller: _supplierController,
                                  // LABEL DINÂMICO
                                  label: widget.isReceivable
                                      ? 'Cliente / Remetente'
                                      : 'Fornecedor / Favorecido',
                                  icon: Icons.business_outlined,
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // NOVO: Mais uma seção usando a função que estava sobrando!
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
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText:
                              'Digite aqui os detalhes, centro de custo, ou informações extras do documento...',
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
                        onPressed: () {
                          // NOVO: Fecha a aba atual
                          try {
                            DashboardPage.of(context).closeCurrentTab();
                          } catch (_) {
                            Navigator.of(
                              context,
                            ).pop(); // Fallback de segurança
                          }
                        },
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
                            // TODO: Salvar no BLoC / Banco de Dados
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Documento salvo com sucesso!'),
                                backgroundColor: AppColors.success,
                              ),
                            );

                            // NOVO: Fecha a aba ao salvar
                            try {
                              DashboardPage.of(context).closeCurrentTab();
                            } catch (_) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar Documento'),
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            }
          : null,
    );
  }
}
