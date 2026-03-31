import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/products/bloc/admin_product_bloc.dart';
import 'package:mart_adminapp/features/products/bloc/admin_product_event.dart';
import 'package:mart_adminapp/features/products/bloc/admin_product_state.dart';
import 'package:mart_adminapp/features/products/data/admin_category_model.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final _nameController = TextEditingController();
  final _deliveryTypeController = TextEditingController(text: 'quick');
  final _requiredController = TextEditingController();
  final _othersController = TextEditingController();

  List<CategoryListItem> _categories = const [];

  @override
  void initState() {
    super.initState();
    context.read<AdminProductBloc>().add(AdminCategoryLoad());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deliveryTypeController.dispose();
    _requiredController.dispose();
    _othersController.dispose();
    super.dispose();
  }

  void _openAddDialog() {
    _nameController.clear();
    _deliveryTypeController.text = 'quick';
    _requiredController.clear();
    _othersController.clear();
    _openCategoryDialog(
      title: 'Add Category',
      onSave: () {
        final req = AdminCategoryRequest(
          name: _nameController.text.trim(),
          deliveryType: _deliveryTypeController.text.trim(),
          requiredFields: _requiredController.text.trim(),
          otherFields: _othersController.text.trim(),
        );
        context.read<AdminProductBloc>().add(AdminCategoryAdd(req));
        Navigator.of(context).pop();
      },
    );
  }

  void _openEditDialog(CategoryListItem c) {
    _nameController.text = c.name;
    _deliveryTypeController.text = 'quick';
    _requiredController.clear();
    _othersController.clear();
    _openCategoryDialog(
      title: 'Edit Category',
      onSave: () {
        final req = AdminCategoryRequest(
          name: _nameController.text.trim(),
          deliveryType: _deliveryTypeController.text.trim(),
          requiredFields: _requiredController.text.trim(),
          otherFields: _othersController.text.trim(),
        );
        context
            .read<AdminProductBloc>()
            .add(AdminCategoryEdit(categoryId: c.objectId, req: req));
        Navigator.of(context).pop();
      },
    );
  }

  void _openCategoryDialog({
    required String title,
    required VoidCallback onSave,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _deliveryTypeController,
                  decoration: const InputDecoration(
                    labelText: 'quick/normal',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _requiredController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'required fields',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _othersController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'other fields',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: onSave,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Categories',
      child: BlocConsumer<AdminProductBloc, AdminProductState>(
        listener: (context, state) {
          if (state is AdminCategoryLoaded) {
            setState(() => _categories = state.categories);
          } else if (state is AdminProductActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<AdminProductBloc>().add(AdminCategoryLoad());
          } else if (state is AdminProductFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _openAddDialog,
                      child: const Text('Add Category'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _categories.isEmpty
                    ? const Center(child: Text('No categories found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final c = _categories[index];
                          return Card(
                            child: ListTile(
                              title: Text(c.name),
                              subtitle: Text('id: ${c.id}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () => _openEditDialog(c),
                                    child: const Text('Edit'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

