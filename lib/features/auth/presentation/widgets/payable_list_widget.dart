import 'package:flutter/material.dart';
import 'package:wialog_erp/features/auth/presentation/pages/dashboard_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/document_form_page.dart';

// O ERRO ESTAVA AQUI: Faltou a declaração da classe!
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
                  // NOVO: Abre como uma Aba!
                  DashboardPage.of(context).openTab(
                    WorkspaceTab(
                      id: 'new_doc_${DateTime.now().millisecondsSinceEpoch}', // ID único
                      title: 'Nova Conta',
                      icon: Icons.add_circle_outline,
                      content: const DocumentFormPage(),
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
                    showCheckboxColumn:
                        false, // Oculta o checkbox nativo para usarmos o clique na linha inteira
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
                        // Torna a linha interativa (clicável)
                        onSelectChanged: (bool? selected) {
                          if (selected == true) {
                            _showDocumentDetails(conta);
                          }
                        },
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

  // ==========================================
  // MODAL DE VISUALIZAÇÃO DO DOCUMENTO
  // ==========================================
  void _showDocumentDetails(Map<String, dynamic> conta) {
    // NOVO: Capturamos o estado do Dashboard ANTES de abrir o modal!
    // Como o modal fica numa camada superior, ele não "enxergaria" o Dashboard diretamente.
    final dashboardState = DashboardPage.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Renomeamos para dialogContext para não confundir
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
                // Cabeçalho do Documento
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Documento #${conta['id']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textTitle,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(
                        dialogContext,
                      ).pop(), // Usa o dialogContext
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Corpo do Documento (Detalhes)
                _buildDocumentField(
                  'Descrição do Lançamento',
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
                        'Valor Original',
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
                      child: _buildDocumentField(
                        'Categoria',
                        'Despesa Operacional',
                      ),
                    ), // Campo Mockado extra
                  ],
                ),

                const SizedBox(height: 32),

                // Área de Anexos Fictícia
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: AppColors.error),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'boleto_vencimento.pdf',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Icon(Icons.download, color: AppColors.textMuted),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Botões de Ação
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // NOVO BOTÃO: Redireciona para a tela completa passando o documento
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(
                          dialogContext,
                        ).pop(); // Fecha o modal primeiro
                        // Usa o estado do Dashboard que salvamos lá em cima!
                        dashboardState.openTab(
                          WorkspaceTab(
                            id: 'doc_${conta['id']}',
                            title: 'Documento #${conta['id']}',
                            icon: Icons.description,
                            content: DocumentFormPage(document: conta),
                          ),
                        );
                      },
                      icon: const Icon(Icons.fullscreen, size: 18),
                      label: const Text('Detalhes Completos'),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Imprimir
                      },
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('Imprimir'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Lógica de Baixa/Pagamento
                        Navigator.of(
                          dialogContext,
                        ).pop(); // Usa o dialogContext
                      },
                      icon: const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Pagar Agora',
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

  // Auxiliar para desenhar os campos do documento
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
