import 'package:flutter/material.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/client_form_page.dart';
import '../pages/supplier_form_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/partner_entity.dart';
import '../bloc/partner/partner_bloc.dart';
import '../bloc/partner/partner_state.dart';

class PartnersListWidget extends StatefulWidget {
  const PartnersListWidget({super.key});

  @override
  State<PartnersListWidget> createState() => _PartnersListWidgetState();
}

class _PartnersListWidgetState extends State<PartnersListWidget> {
  // 0 = Clientes | 1 = Fornecedores
  int _selectedIndex = 0;

  // REMOVEMOS OS MOCKS! O BLoC fará todo o trabalho agora.

  @override
  Widget build(BuildContext context) {
    final isClientView = _selectedIndex == 0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==========================================
          // BARRA SUPERIOR (Seletor e Botão Novo)
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Seletor Clientes / Fornecedores
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.group),
                    // Removemos a cor fixa daqui
                    label: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Meus Clientes'),
                    ),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.local_shipping),
                    // Removemos a cor fixa daqui
                    label: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Meus Fornecedores'),
                    ),
                  ),
                ],
                selected: {_selectedIndex},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _selectedIndex = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return Colors.white;
                  }),
                  // ADICIONAMOS O CONTROLE DE COR DO TEXTO/ÍCONE AQUI!
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white; // Fica branco quando selecionado
                    }
                    return AppColors
                        .textTitle; // Fica escuro quando não selecionado
                  }),
                ),
              ),

              // Campo de Pesquisa
              SizedBox(
                width: 250,
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Botão Dinâmico (Novo Cliente ou Novo Fornecedor)
              ElevatedButton.icon(
                onPressed: () {
                  final dashboardState = DashboardPage.of(context);
                  final stamp = DateTime.now().millisecondsSinceEpoch;

                  if (isClientView) {
                    dashboardState.openTab(
                      WorkspaceTab(
                        id: 'new_client_$stamp',
                        title: 'Novo Cliente',
                        icon: Icons.person_add,
                        content: const ClientFormPage(),
                      ),
                    );
                  } else {
                    dashboardState.openTab(
                      WorkspaceTab(
                        id: 'new_supplier_$stamp',
                        title: 'Novo Fornecedor',
                        icon: Icons.domain_add,
                        content: const SupplierFormPage(),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: Text(
                  isClientView ? 'Novo Cliente' : 'Novo Fornecedor',
                  style: const TextStyle(color: Colors.white),
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

          // ==========================================
          // TABELA DE DADOS
          // ==========================================
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                // NOVO: BlocBuilder! A tela se redesenha sozinha dependendo do Estado do Banco.
                child: BlocBuilder<PartnerBloc, PartnerState>(
                  builder: (context, state) {
                    if (state is PartnerLoading || state is PartnerInitial) {
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
                      // Filtra a lista do banco de acordo com a aba selecionada
                      final currentList = state.partners.where((p) {
                        return isClientView
                            ? p.type == PartnerType.client
                            : p.type == PartnerType.supplier;
                      }).toList();

                      if (currentList.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhum parceiro encontrado.',
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
                          columns: [
                            const DataColumn(
                              label: Text(
                                'Código',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                isClientView
                                    ? 'Razão Social / Nome'
                                    : 'Fornecedor',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'CPF / CNPJ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'Contato',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                isClientView ? 'Cidade' : 'Categoria',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: currentList.map((item) {
                            return DataRow(
                              onSelectChanged: (selected) {
                                if (selected == true) {
                                  // TODO: Abrir tela de edição
                                }
                              },
                              cells: [
                                DataCell(
                                  Text(item.id.substring(0, 8)),
                                ), // Mostra só o começo do ID
                                DataCell(
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DataCell(Text(item.document)),
                                DataCell(Text(item.contact)),
                                DataCell(Text(item.categoryOrCity)),
                                DataCell(
                                  _buildStatusChip(
                                    item.isActive ? 'Ativo' : 'Inativo',
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

  Widget _buildStatusChip(String status) {
    final bool isActive = status == 'Ativo';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
