import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/client_form_page.dart';
import '../pages/supplier_form_page.dart';
import '../../domain/entities/partner_entity.dart';
import '../bloc/partner/partner_bloc.dart';
import '../bloc/partner/partner_state.dart';
import '../bloc/partner/partner_event.dart';

class PartnersListWidget extends StatefulWidget {
  const PartnersListWidget({super.key});

  @override
  State<PartnersListWidget> createState() => _PartnersListWidgetState();
}

class _PartnersListWidgetState extends State<PartnersListWidget> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final type = _selectedIndex == 0
        ? PartnerType.client
        : PartnerType.supplier;
    context.read<PartnerBloc>().add(
      LoadPartners(type: type, query: _searchController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isClientView = _selectedIndex == 0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==========================================
          // BARRA SUPERIOR: Filtros e Pesquisa
          // ==========================================
          Row(
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Meus Clientes')),
                  ButtonSegment(value: 1, label: Text('Meus Fornecedores')),
                ],
                selected: {_selectedIndex},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _selectedIndex = newSelection.first;
                    _searchController.clear();
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.primary
                        : Colors.white,
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.white
                        : AppColors.textTitle,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Campo de Busca
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _performSearch(),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar por nome, código ou CPF/CNPJ...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Botão Buscar Destaque
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text(
                    'Buscar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Botão Adicionar
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final dashboardState = DashboardPage.of(context);
                    if (isClientView) {
                      dashboardState.openTab(
                        WorkspaceTab(
                          id: 'new_client',
                          title: 'Novo Cliente',
                          icon: Icons.person_add,
                          content: const ClientFormPage(),
                        ),
                      );
                    } else {
                      dashboardState.openTab(
                        WorkspaceTab(
                          id: 'new_supplier',
                          title: 'Novo Fornecedor',
                          icon: Icons.domain_add,
                          content: const SupplierFormPage(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    isClientView ? 'Novo Cliente' : 'Novo Fornecedor',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
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
              child: BlocBuilder<PartnerBloc, PartnerState>(
                builder: (context, state) {
                  if (state is PartnerInitial) {
                    return const Center(
                      child: Text(
                        "Use o campo de busca acima para encontrar parceiros.",
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    );
                  }
                  if (state is PartnerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is PartnerError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  if (state is PartnerLoaded) {
                    if (state.partners.isEmpty) {
                      return const Center(
                        child: Text(
                          "Nenhum resultado encontrado.",
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: DataTable(
                        // MÁGICA 1: Isso esconde os checkboxes e permite clicar na linha toda
                        showCheckboxColumn: false,
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.background,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Código',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Nome',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'CPF/CNPJ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Contato',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Cidade/Cat.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: state.partners
                            .map(
                              (item) => DataRow(
                                // MÁGICA 2: O evento de clique na linha!
                                onSelectChanged: (selected) {
                                  if (selected == true) {
                                    final dashboardState = DashboardPage.of(
                                      context,
                                    );
                                    if (isClientView) {
                                      dashboardState.openTab(
                                        WorkspaceTab(
                                          id: 'edit_client_${item.id}',
                                          title: 'Editar Cliente',
                                          icon: Icons.edit,
                                          content: ClientFormPage(
                                            partner: item,
                                          ),
                                        ),
                                      );
                                    } else {
                                      dashboardState.openTab(
                                        WorkspaceTab(
                                          id: 'edit_supplier_${item.id}',
                                          title: 'Editar Fornecedor',
                                          icon: Icons.edit,
                                          content: SupplierFormPage(
                                            partner: item,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                cells: [
                                  DataCell(Text(item.id.toString())),
                                  DataCell(Text(item.name)),
                                  DataCell(Text(item.document)),
                                  DataCell(Text(item.contact)),
                                  DataCell(
                                    Text(
                                      item.city ??
                                          item.categoryId?.toString() ??
                                          '',
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
