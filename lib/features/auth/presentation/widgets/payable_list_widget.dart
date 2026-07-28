import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PayableListWidget extends StatefulWidget {
  const PayableListWidget({super.key});

  @override
  State<PayableListWidget> createState() => _PayableListWidgetState();
}

class _PayableListWidgetState extends State<PayableListWidget> {
  // No futuro, isso virá do BLoC / Banco de Dados (PostgreSQL)
  final List<Map<String, dynamic>> _mockPayables = [
    {
      'id': '001',
      'description': 'Combustível - Posto Ipiranga',
      'dueDate': '15/08/2026',
      'value': 2500.00,
      'status': 'Pago',
    },
    {
      'id': '002',
      'description': 'Manutenção - Oficina do Zé (Placa ABC-1234)',
      'dueDate': '20/08/2026',
      'value': 1200.50,
      'status': 'Pendente',
    },
    {
      'id': '003',
      'description': 'Internet e Telefone',
      'dueDate': '10/08/2026',
      'value': 299.90,
      'status': 'Atrasado',
    },
    {
      'id': '004',
      'description': 'Seguro da Frota',
      'dueDate': '25/08/2026',
      'value': 4500.00,
      'status': 'Pendente',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de Ferramentas (Search e Botão Adicionar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Campo de Pesquisa
              SizedBox(
                width: 300,
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar conta...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              // Botão de Nova Conta
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Abrir formulário de cadastro (Issue futura)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abrindo formulário de nova conta...'),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text(
                  'Nova Conta',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tabela de Dados com fundo branco e sombra
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.background,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'ID',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Descrição',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Vencimento',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Valor (R\$)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Ações',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: _mockPayables.map((conta) {
                      return DataRow(
                        cells: [
                          DataCell(Text(conta['id'])),
                          DataCell(
                            Text(
                              conta['description'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(Text(conta['dueDate'])),
                          DataCell(Text(conta['value'].toStringAsFixed(2))),
                          DataCell(_buildStatusChip(conta['status'])),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: AppColors.info,
                                  ),
                                  tooltip: 'Editar',
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                    color: AppColors.success,
                                  ),
                                  tooltip: 'Marcar como Pago',
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Pago':
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        break;
      case 'Atrasado':
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        break;
      case 'Pendente':
      default:
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
