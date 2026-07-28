import 'package:flutter/material.dart';
import 'package:wialog_erp/features/auth/presentation/pages/dashboard_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/document_form_page.dart';

class ReceivableListWidget extends StatefulWidget {
  const ReceivableListWidget({super.key});

  @override
  State<ReceivableListWidget> createState() => _ReceivableListWidgetState();
}

class _ReceivableListWidgetState extends State<ReceivableListWidget> {
  // Mock de dados focados em faturamento de fretes
  final List<Map<String, dynamic>> _mockReceivables = [
    {
      'id': '101',
      'description': 'Frete - Rota SP x RJ (Carga Seca)',
      'client': 'Indústrias ABC Ltda',
      'dueDate': '05/08/2026',
      'value': 4500.00,
      'status': 'Recebido',
    },
    {
      'id': '102',
      'description': 'Frete Fracionado - Sul',
      'client': 'Comércio Varejista XYZ',
      'dueDate': '18/08/2026',
      'value': 1850.75,
      'status': 'Pendente',
    },
    {
      'id': '103',
      'description': 'Contrato Logístico Mensal',
      'client': 'Supermercados Global',
      'dueDate': '01/08/2026',
      'value': 12000.00,
      'status': 'Atrasado',
    },
    {
      'id': '104',
      'description': 'Frete - Rota GO x PR (Refrigerada)',
      'client': 'Agropecuária Norte',
      'dueDate': '28/08/2026',
      'value': 8900.00,
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
          // Barra de Ferramentas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 300,
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar receita ou cliente...',
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

              ElevatedButton.icon(
                onPressed: () {
                  DashboardPage.of(context).openTab(
                    WorkspaceTab(
                      id: 'new_rec_${DateTime.now().millisecondsSinceEpoch}',
                      title: 'Nova Receita',
                      icon: Icons.add_circle_outline,
                      // NOVO: Passamos isReceivable como true!
                      content: const DocumentFormPage(isReceivable: true),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text(
                  'Nova Receita',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors
                      .success, // Verde para indicar entrada de dinheiro
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
                    showCheckboxColumn: false,
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
                          'Cliente',
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
                    ],
                    rows: _mockReceivables.map((receita) {
                      return DataRow(
                        onSelectChanged: (bool? selected) {
                          if (selected == true) {
                            _showDocumentDetails(receita);
                          }
                        },
                        cells: [
                          DataCell(Text(receita['id'])),
                          DataCell(
                            Text(
                              receita['description'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(Text(receita['client'])),
                          DataCell(Text(receita['dueDate'])),
                          DataCell(Text(receita['value'].toStringAsFixed(2))),
                          DataCell(_buildStatusChip(receita['status'])),
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
      case 'Recebido':
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        break;
      case 'Atrasado':
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        break;
      case 'Pendente':
      default:
        bgColor = AppColors.info.withValues(alpha: 0.1);
        textColor = AppColors.info;
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

  void _showDocumentDetails(Map<String, dynamic> conta) {
    final dashboardState = DashboardPage.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Faturamento #${conta['id']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textTitle,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                const Divider(height: 32),

                _buildDocumentField(
                  'Descrição do Faturamento',
                  conta['description'],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildDocumentField(
                        'Data de Vencimento',
                        conta['dueDate'],
                      ),
                    ),
                    Expanded(
                      child: _buildDocumentField(
                        'Valor a Receber',
                        'R\$ ${conta['value'].toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Atual',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusChip(conta['status']),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildDocumentField('Cliente', conta['client']),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        dashboardState.openTab(
                          WorkspaceTab(
                            id: 'rec_${conta['id']}',
                            title: 'Receita #${conta['id']}',
                            icon: Icons.request_quote,
                            content: DocumentFormPage(
                              document: conta,
                              isReceivable: true,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.fullscreen, size: 18),
                      label: const Text('Detalhes Completos'),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      icon: const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Dar Baixa (Receber)',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textBody,
          ),
        ),
      ],
    );
  }
}
