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
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final t in c.typesList)
                                      InputChip(
                                        label: Text(t),
                                        onDeleted: () =>
                                            _removeType(name, t),
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
