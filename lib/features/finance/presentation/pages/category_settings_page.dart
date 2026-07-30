import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../finance/domain/entities/category_entity.dart';
import '../../../finance/presentation/bloc/category/category_bloc.dart';
import '../../../finance/presentation/bloc/category/category_event.dart';
import '../../../finance/presentation/bloc/category/category_state.dart';

class CategorySettingsPage extends StatefulWidget {
  const CategorySettingsPage({super.key});

  @override
  State<CategorySettingsPage> createState() => _CategorySettingsPageState();
}

// O mixin TickerProvider é obrigatório para usar TabController
class _CategorySettingsPageState extends State<CategorySettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showInactive = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Escuta a troca de abas para recarregar as categorias correspondentes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(
          () {},
        ); // <--- CORREÇÃO: Força o botão e os textos a se atualizarem!
        _loadCategories();
      }
    });

    _loadCategories(); // Carrega a primeira aba logo de cara
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helpers para descobrir qual aba está ativa
  CategoryType get _currentType {
    if (_tabController.index == 0) return CategoryType.supplier;
    if (_tabController.index == 1) return CategoryType.receivable;
    return CategoryType.payable;
  }

  String get _typeLabel {
    if (_tabController.index == 0) return 'Fornecedor';
    if (_tabController.index == 1) return 'Receita';
    return 'Despesa';
  }

  void _loadCategories() {
    context.read<CategoryBloc>().add(
      LoadCategories(type: _currentType, includeInactive: _showInactive),
    );
  }

  void _showCategoryDialog({CategoryEntity? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final formKey = GlobalKey<FormState>();
    final typeToSave = _currentType; // Trava o tipo baseado na aba atual

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            isEditing
                ? 'Editar Categoria ($_typeLabel)'
                : 'Nova Categoria ($_typeLabel)',
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Categoria',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Obrigatório'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final entity = CategoryEntity(
                    id: category?.id ?? 0,
                    name: nameController.text.trim(),
                    type: typeToSave,
                    isActive: category?.isActive ?? true,
                  );

                  if (isEditing) {
                    context.read<CategoryBloc>().add(UpdateCategory(entity));
                  } else {
                    context.read<CategoryBloc>().add(AddCategory(entity));
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(CategoryEntity category) {
    final typeToSave = _currentType;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inativar Categoria?'),
        content: Text(
          'Tem certeza que deseja inativar a categoria "${category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<CategoryBloc>().add(
                DeleteCategory(category.id, typeToSave),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Sim, Inativar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CABEÇALHO E BOTÕES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gestão de Categorias',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textTitle,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Mostrar Inativas',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    Switch(
                      value: _showInactive,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _showInactive = val);
                        _loadCategories();
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showCategoryDialog(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        'Nova Categoria ($_typeLabel)',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ABAS DE NAVEGAÇÃO
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(
                    text: 'Fornecedores',
                    icon: Icon(Icons.local_shipping_outlined),
                  ),
                  Tab(text: 'Receitas', icon: Icon(Icons.arrow_upward)),
                  Tab(text: 'Despesas', icon: Icon(Icons.arrow_downward)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TABELA RESPONSIVA DA ABA ATIVA
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is CategoryError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    if (state is CategoryLoaded) {
                      if (state.categories.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhuma categoria encontrada.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        );
                      }
                      return SingleChildScrollView(
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
                                'Nome da Categoria',
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
                          rows: state.categories
                              .map(
                                (cat) => DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        cat.id.toString(),
                                        style: TextStyle(
                                          color: cat.isActive
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          Text(
                                            cat.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: cat.isActive
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                          if (!cat.isActive) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.error
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Inativa',
                                                style: TextStyle(
                                                  color: AppColors.error,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: AppColors.info,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _showCategoryDialog(
                                                  category: cat,
                                                ),
                                            tooltip: 'Editar',
                                          ),
                                          if (cat.isActive)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: AppColors.error,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _confirmDelete(cat),
                                              tooltip: 'Inativar',
                                            ),
                                        ],
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
      ),
    );
  }
}
