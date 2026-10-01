import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers.dart';
import '../../domain/models/category.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/empty_state.dart';
import '../providers/data_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (categories) {
          if (categories.isEmpty) {
            return EmptyState(
              icon: Icons.category_outlined,
              title: 'No Categories',
              message: 'Add categories to organize your transactions.',
              actionLabel: 'Add Category',
              onAction: () => _showAddCategorySheet(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(categoriesListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return AppCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(category.color ?? Colors.grey.value)
                              .withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          IconData(
                            int.tryParse(category.icon ?? '') ??
                                Icons.category.codePoint,
                            fontFamily: 'MaterialIcons',
                          ),
                          color: Color(category.color ?? Colors.grey.value),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: AppTheme.textSecondary,
                        ),
                        onSelected: (value) async {
                          if (value == 'delete') {
                            await ref
                                .read(categoryRepositoryProvider)
                                .deleteCategory(category.id);
                            ref.invalidate(categoriesListProvider);
                          } else if (value == 'edit') {
                            _showAddCategorySheet(
                              context,
                              ref,
                              existing: category,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategorySheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddCategorySheet(
    BuildContext context,
    WidgetRef ref, {
    Category? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCategorySheet(ref: ref, existing: existing),
    ).then((_) => ref.invalidate(categoriesListProvider));
  }
}

class _AddCategorySheet extends StatefulWidget {
  final WidgetRef ref;
  final Category? existing;

  const _AddCategorySheet({required this.ref, this.existing});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  late TextEditingController _nameController;
  int _selectedColor = Colors.blue.value;
  int _selectedIcon = Icons.category.codePoint;

  final List<int> _colors = [
    Colors.blue.value,
    Colors.red.value,
    Colors.green.value,
    Colors.orange.value,
    Colors.purple.value,
    Colors.teal.value,
    Colors.pink.value,
    Colors.indigo.value,
  ];

  final List<int> _icons = [
    Icons.category.codePoint,
    Icons.fastfood.codePoint,
    Icons.shopping_cart.codePoint,
    Icons.directions_car.codePoint,
    Icons.home.codePoint,
    Icons.flight.codePoint,
    Icons.local_hospital.codePoint,
    Icons.school.codePoint,
    Icons.movie.codePoint,
  ];

  CategoryType _selectedType = CategoryType.expense;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    if (widget.existing != null) {
      _selectedColor = widget.existing!.color ?? Colors.blue.value;
      _selectedIcon =
          int.tryParse(widget.existing!.icon ?? '') ?? Icons.category.codePoint;
      _selectedType = widget.existing!.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomInset,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.existing == null ? 'Add Category' : 'Edit Category',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),

            const Text('Type', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SegmentedButton<CategoryType>(
              segments: const [
                ButtonSegment(
                  value: CategoryType.expense,
                  label: Text('Expense'),
                ),
                ButtonSegment(
                  value: CategoryType.income,
                  label: Text('Income'),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<CategoryType> newSelection) {
                setState(() => _selectedType = newSelection.first);
              },
              style: SegmentedButton.styleFrom(
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: AppTheme.primaryAccent,
              ),
            ),
            const SizedBox(height: 16),

            const Text('Name', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'e.g. Groceries'),
              autofocus: widget.existing == null,
            ),
            const SizedBox(height: 16),

            const Text('Color', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors
                  .map(
                    (color) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            const Text('Icon', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _icons
                  .map(
                    (icon) => GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon
                              ? Color(_selectedColor).withAlpha(50)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: _selectedIcon == icon
                              ? Border.all(
                                  color: Color(_selectedColor),
                                  width: 2,
                                )
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(
                          IconData(icon, fontFamily: 'MaterialIcons'),
                          color: _selectedIcon == icon
                              ? Color(_selectedColor)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Category'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final category = Category(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: name,
      type: _selectedType,
      color: _selectedColor,
      icon: _selectedIcon.toString(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.existing == null) {
      await widget.ref
          .read(categoryRepositoryProvider)
          .createCategory(category);
    } else {
      await widget.ref
          .read(categoryRepositoryProvider)
          .updateCategory(category);
    }

    widget.ref.invalidate(categoriesListProvider);
    if (mounted) Navigator.pop(context);
  }
}
