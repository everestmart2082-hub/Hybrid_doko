import 'dart:convert';
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
  List<CategoryListItem> _categories = const [];

  @override
  void initState() {
    super.initState();
    context.read<AdminProductBloc>().add(AdminCategoryLoad());
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        title: 'Add Category',
        initialName: '',
        initialDeliveryType: 'quick',
        initialRequiredStr: '',
        initialOthersStr: '',
        onSave: (req) {
          context.read<AdminProductBloc>().add(AdminCategoryAdd(req));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _openEditDialog(CategoryListItem c) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        title: 'Edit Category',
        initialName: c.name,
        initialDeliveryType: c.deliveryType.isNotEmpty ? c.deliveryType : 'quick',
        initialRequiredStr: c.requiredFields,
        initialOthersStr: c.otherFields,
        onSave: (req) {
          context
              .read<AdminProductBloc>()
              .add(AdminCategoryEdit(categoryId: c.objectId, req: req));
          Navigator.of(context).pop();
        },
      ),
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
                    Text(
                      'Categories',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
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
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final c = _categories[index];
                          return Card(
                            color: Theme.of(context).primaryColorLight,
                            child: ListTile(
                              title: Text(c.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Text('id: ${c.id}',
                                  style: Theme.of(context).textTheme.bodySmall),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () => _openEditDialog(c),
                                    child: Text(
                                      'Edit',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
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

class _FieldData {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;

  _FieldData({String title = '', String desc = ''})
      : titleCtrl = TextEditingController(text: title),
        descCtrl = TextEditingController(text: desc);
}

class _CategoryDialog extends StatefulWidget {
  final String title;
  final String initialName;
  final String initialDeliveryType;
  final String initialRequiredStr;
  final String initialOthersStr;
  final void Function(AdminCategoryRequest req) onSave;

  const _CategoryDialog({
    required this.title,
    required this.initialName,
    required this.initialDeliveryType,
    required this.initialRequiredStr,
    required this.initialOthersStr,
    required this.onSave,
  });

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _delCtrl;

  final List<_FieldData> _reqFields = [];
  final List<_FieldData> _othFields = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _delCtrl = TextEditingController(text: widget.initialDeliveryType);
    _parseFields(widget.initialRequiredStr, _reqFields);
    _parseFields(widget.initialOthersStr, _othFields);
  }

  void _parseFields(String jsonStr, List<_FieldData> target) {
    if (jsonStr.isEmpty) return;
    try {
      final list = jsonDecode(jsonStr) as List;
      for (var e in list) {
        if (e is Map) {
          final entry = e.entries.first;
          target.add(_FieldData(title: entry.key.toString(), desc: entry.value.toString()));
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _delCtrl.dispose();
    for (var f in _reqFields) {
      f.titleCtrl.dispose();
      f.descCtrl.dispose();
    }
    for (var f in _othFields) {
      f.titleCtrl.dispose();
      f.descCtrl.dispose();
    }
    super.dispose();
  }

  String _encodeFields(List<_FieldData> list) {
    if (list.isEmpty) return "";
    final res = list
        .where((f) => f.titleCtrl.text.trim().isNotEmpty)
        .map((f) => {f.titleCtrl.text.trim(): f.descCtrl.text.trim()})
        .toList();
    if (res.isEmpty) return "";
    return jsonEncode(res);
  }

  Widget _buildFieldList(String label, List<_FieldData> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.add_circle,
                  color: Theme.of(context).primaryColorDark),
              onPressed: () => setState(() => list.add(_FieldData())),
            ),
          ],
        ),
        ...list.asMap().entries.map((e) {
          final i = e.key;
          final f = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: f.titleCtrl,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Key/Title',
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: f.descCtrl,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Description/Value',
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => setState(() => list.removeAt(i)),
                )
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColorLight,
      title: Text(widget.title),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: Theme.of(context).textTheme.bodyMedium,
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  labelText: 'name',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: Theme.of(context).textTheme.bodyMedium,
                controller: _delCtrl,
                decoration: InputDecoration(
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  labelText: 'quick/normal',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              _buildFieldList('Required Fields', _reqFields),
              const Divider(),
              _buildFieldList('Other Fields', _othFields),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium),
        ),
        ElevatedButton(
          onPressed: () {
            final req = AdminCategoryRequest(
              name: _nameCtrl.text.trim(),
              deliveryType: _delCtrl.text.trim(),
              requiredFields: _encodeFields(_reqFields),
              otherFields: _encodeFields(_othFields),
            );
            widget.onSave(req);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
