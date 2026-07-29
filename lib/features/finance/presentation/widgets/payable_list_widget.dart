import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/document_form_page.dart';

import '../../domain/entities/financial_document_entity.dart';
import '../bloc/document/document_bloc.dart';
import '../bloc/document/document_event.dart';
import '../bloc/document/document_state.dart';

class PayableListWidget extends StatefulWidget {
  const PayableListWidget({super.key});

  @override
  State<PayableListWidget> createState() => _PayableListWidgetState();
}

class _PayableListWidgetState extends State<PayableListWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dispara a busca das Contas a PAGAR ao iniciar a aba
    _loadDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDocuments() {
    context.read<DocumentBloc>().add(
      LoadDocuments(type: DocumentType.payable, query: _searchController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 300,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _loadDocuments(),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar conta ou fornecedor...',
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
                      id: 'new_doc_${DateTime.now().millisecondsSinceEpoch}',
                      title: 'Nova Despesa',
                      icon: Icons.remove_circle_outline,
                      content: const DocumentFormPage(isReceivable: false),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text(
                  'Nova Conta',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error, // Vermelho para saída
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
                child: BlocBuilder<DocumentBloc, DocumentState>(
                  builder: (context, state) {
                    if (state is DocumentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is DocumentError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    if (state is DocumentLoaded) {
                      if (state.documents.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhuma conta a pagar encontrada.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        );
                      }
                      return SingleChildScrollView(
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
                                'Fornecedor',
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
                          rows: state.documents.map((conta) {
                            // Formatação de data (DD/MM/YYYY)
                            final dateStr =
                                '${conta.dueDate.day.toString().padLeft(2, '0')}/${conta.dueDate.month.toString().padLeft(2, '0')}/${conta.dueDate.year}';

                            return DataRow(
                              onSelectChanged: (bool? selected) {
                                if (selected == true) {
                                  _showDocumentDetails(conta);
                                }
                              },
                              cells: [
                                DataCell(Text(conta.id)),
                                DataCell(
                                  Text(
                                    conta.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(conta.partnerName ?? 'N/A'),
                                ), // Puxou via SQL JOIN!
                                DataCell(Text(dateStr)),
                                DataCell(
                                  Text('R\$ ${conta.value.toStringAsFixed(2)}'),
                                ),
                                DataCell(
                                  _buildStatusChip(conta.status, conta.dueDate),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(DocumentStatus status, DateTime dueDate) {
    Color bgColor = AppColors.warning.withValues(alpha: 0.1);
    Color textColor = AppColors.warning;
    String label = 'Pendente';

    if (status == DocumentStatus.paid) {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
      label = 'Pago';
    } else if (status == DocumentStatus.canceled) {
      bgColor = Colors.grey.withValues(alpha: 0.1);
      textColor = Colors.grey;
      label = 'Cancelado';
    } else if (dueDate.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    )) {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      textColor = AppColors.error;
      label = 'Atrasado';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showDocumentDetails(FinancialDocumentEntity conta) {
    // Transforma a Entity em Map para aproveitar a tela atual de edição
    final mapDoc = {
      'id': conta.id,
      'description': conta.description,
      'value': conta.value,
      'balance': conta.balance,
      'due_date': conta.dueDate.toIso8601String(),
      'issue_date': conta.issueDate.toIso8601String(),
      'category_id': conta.categoryId,
      'partner_id': conta.partnerId,
      'status': conta.status.name,
      'notes': conta.notes,
    };

    DashboardPage.of(context).openTab(
      WorkspaceTab(
        id: 'edit_doc_${conta.id}',
        title: 'Despesa #${conta.id}',
        icon: Icons.description,
        content: DocumentFormPage(document: mapDoc, isReceivable: false),
      ),
    );
  }
}
