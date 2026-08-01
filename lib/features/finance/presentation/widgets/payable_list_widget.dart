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
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    // NOVO: Limpa a memória global ao entrar nesta aba
    context.read<DocumentBloc>().add(ClearDocuments());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDocuments() {
    context.read<DocumentBloc>().add(
      LoadDocuments(
        type: DocumentType.payable,
        query: _searchController.text,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: context.appColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _loadDocuments(),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar conta, ID ou fornecedor...',
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
              ),
              const SizedBox(width: 16),

              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: Icon(
                    Icons.calendar_month,
                    color: context.appColors.primary,
                  ),
                  label: Text(
                    _selectedDateRange == null
                        ? 'Filtrar Período'
                        : '${_selectedDateRange!.start.day.toString().padLeft(2, '0')}/${_selectedDateRange!.start.month.toString().padLeft(2, '0')} até ${_selectedDateRange!.end.day.toString().padLeft(2, '0')}/${_selectedDateRange!.end.month.toString().padLeft(2, '0')}',
                    style: TextStyle(color: context.appColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: context.appColors.primary),
                  ),
                ),
              ),

              if (_selectedDateRange != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.clear, color: context.appColors.error),
                    tooltip: 'Limpar Data',
                    onPressed: () => setState(() => _selectedDateRange = null),
                  ),
                ),

              const SizedBox(width: 16),

              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _loadDocuments,
                  icon: const Icon(Icons.manage_search),
                  label: const Text('Buscar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.appColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
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
                    backgroundColor: context.appColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                    // MUDANÇA: Se o BLoC tiver dados, mas forem da aba de Receitas, fingimos que estamos no estado Inicial!
                    if (state is DocumentInitial ||
                        (state is DocumentLoaded &&
                            state.type != DocumentType.payable)) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: context.appColors.textMuted,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Utilize os filtros acima e clique em "Buscar"',
                              style: TextStyle(
                                color: context.appColors.textMuted,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is DocumentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is DocumentError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: TextStyle(color: context.appColors.error),
                        ),
                      );
                    }
                    if (state is DocumentLoaded &&
                        state.type == DocumentType.payable) {
                      if (state.documents.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhuma conta a pagar encontrada.',
                            style: TextStyle(
                              color: context.appColors.textMuted,
                            ),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        child: DataTable(
                          showCheckboxColumn: false,
                          headingRowColor: WidgetStateProperty.all(
                            context.appColors.background,
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
                                DataCell(Text(conta.partnerName ?? 'N/A')),
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
    Color bgColor = context.appColors.warning.withValues(alpha: 0.1);
    Color textColor = context.appColors.warning;
    String label = 'Pendente';

    if (status == DocumentStatus.paid) {
      bgColor = context.appColors.success.withValues(alpha: 0.1);
      textColor = context.appColors.success;
      label = 'Pago';
    } else if (status == DocumentStatus.canceled) {
      bgColor = context.appColors.textMuted.withValues(alpha: 0.1);
      textColor = context.appColors.textMuted;
      label = 'Cancelado';
    } else if (dueDate.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    )) {
      bgColor = context.appColors.error.withValues(alpha: 0.1);
      textColor = context.appColors.error;
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
