import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/document_form_page.dart';

import '../../domain/entities/financial_document_entity.dart';
import '../bloc/document/document_bloc.dart';
import '../bloc/document/document_event.dart';
import '../bloc/document/document_state.dart';

class ReceivableListWidget extends StatefulWidget {
  const ReceivableListWidget({super.key});

  @override
  State<ReceivableListWidget> createState() => _ReceivableListWidgetState();
}

class _ReceivableListWidgetState extends State<ReceivableListWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDocuments() {
    context.read<DocumentBloc>().add(
      LoadDocuments(
        type: DocumentType.receivable,
        query: _searchController.text,
      ),
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
                  backgroundColor: AppColors.success, // Verde para Entrada
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
                            'Nenhuma conta a receber encontrada.',
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
                          rows: state.documents.map((receita) {
                            final dateStr =
                                '${receita.dueDate.day.toString().padLeft(2, '0')}/${receita.dueDate.month.toString().padLeft(2, '0')}/${receita.dueDate.year}';

                            return DataRow(
                              onSelectChanged: (bool? selected) {
                                if (selected == true) {
                                  _showDocumentDetails(receita);
                                }
                              },
                              cells: [
                                DataCell(Text(receita.id)),
                                DataCell(
                                  Text(
                                    receita.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DataCell(Text(receita.partnerName ?? 'N/A')),
                                DataCell(Text(dateStr)),
                                DataCell(
                                  Text(
                                    'R\$ ${receita.value.toStringAsFixed(2)}',
                                  ),
                                ),
                                DataCell(
                                  _buildStatusChip(
                                    receita.status,
                                    receita.dueDate,
                                  ),
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
    Color bgColor = AppColors.info.withValues(alpha: 0.1);
    Color textColor = AppColors.info;
    String label = 'A Receber';

    if (status == DocumentStatus.paid) {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
      label = 'Recebido';
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

  void _showDocumentDetails(FinancialDocumentEntity receita) {
    final mapDoc = {
      'id': receita.id,
      'description': receita.description,
      'value': receita.value,
      'balance': receita.balance,
      'due_date': receita.dueDate.toIso8601String(),
      'issue_date': receita.issueDate.toIso8601String(),
      'category_id': receita.categoryId,
      'partner_id': receita.partnerId,
      'status': receita.status.name,
      'notes': receita.notes,
    };

    DashboardPage.of(context).openTab(
      WorkspaceTab(
        id: 'edit_rec_${receita.id}',
        title: 'Receita #${receita.id}',
        icon: Icons.request_quote,
        content: DocumentFormPage(document: mapDoc, isReceivable: true),
      ),
    );
  }
}
