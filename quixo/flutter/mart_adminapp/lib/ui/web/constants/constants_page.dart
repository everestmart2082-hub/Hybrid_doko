import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/settings/data/admin_constant_model.dart';
import 'package:mart_adminapp/features/settings/repository/admin_settings_remote.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

class AdminConstantsPage extends StatefulWidget {
  const AdminConstantsPage({super.key});

  @override
  State<AdminConstantsPage> createState() => _AdminConstantsPageState();
}

class _AdminConstantsPageState extends State<AdminConstantsPage> {
  List<AdminConstantModel> _list = [];
  bool _loading = true;
  String? _error;
  final Map<String, TextEditingController> _addCtrls = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _addCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrlFor(String name) {
    return _addCtrls.putIfAbsent(name, TextEditingController.new);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final remote = context.read<AdminSettingsRemote>();
      final list = await remote.fetchAllConstants();
      if (mounted) {
        setState(() {
          _list = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _addType(String constantName) async {
    final ctrl = _ctrlFor(constantName);
    final v = ctrl.text.trim();
    if (v.isEmpty) return;
    try {
      await context.read<AdminSettingsRemote>().changeConstants(
            AdminConstantUpdateRequest(
              name: constantName,
              typesList: [v],
              action: 'add',
            ),
          );
      ctrl.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removeType(String constantName, String item) async {
    try {
      await context.read<AdminSettingsRemote>().changeConstants(
            AdminConstantUpdateRequest(
              name: constantName,
              typesList: [item],
              action: 'remove',
            ),
          );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _addConstant() async {
    final nameCtrl = TextEditingController();
    final valuesCtrl = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add constant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: valuesCtrl,
              decoration: const InputDecoration(
                labelText: 'Values (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );
    if (submitted != true) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;
    final values = valuesCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    try {
      await context.read<AdminSettingsRemote>().changeConstants(
            AdminConstantUpdateRequest(name: name, typesList: values, action: 'update'),
          );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteConstant(String name) async {
    try {
      await context.read<AdminSettingsRemote>().deleteConstant(name);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editType(String constantName, String oldValue) async {
    final ctrl = TextEditingController(text: oldValue);
    final next = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit value'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Value',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (next == null || next.isEmpty || next == oldValue) return;
    try {
      final constant = _list.firstWhere((e) => e.name == constantName);
      final updated = constant.typesList.map((e) => e == oldValue ? next : e).toList();
      await context.read<AdminSettingsRemote>().changeConstants(
            AdminConstantUpdateRequest(
              name: constantName,
              typesList: updated,
              action: 'update',
            ),
          );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Constants',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _addConstant,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Constant'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lists such as Business type (used at vendor registration) and other shared options.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ..._list.map((c) {
                        final name = c.name;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Text(name.isEmpty ? '(unnamed)' : name),
                            initiallyExpanded: name == 'Business type',
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete constant',
                              onPressed: name.isEmpty ? null : () => _deleteConstant(name),
                            ),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final t in c.typesList)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InputChip(
                                            label: Text(t),
                                            onDeleted: () => _removeType(name, t),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 18),
                                            onPressed: () => _editType(name, t),
                                            tooltip: 'Edit',
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _ctrlFor(name),
                                        decoration: const InputDecoration(
                                          labelText: 'Add value',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        onSubmitted: (_) => _addType(name),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _addType(name),
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
