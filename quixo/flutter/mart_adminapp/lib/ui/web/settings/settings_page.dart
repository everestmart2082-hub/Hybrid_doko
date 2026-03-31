import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/settings/bloc/settings_bloc.dart';
import 'package:mart_adminapp/features/settings/bloc/settings_event.dart';
import 'package:mart_adminapp/features/settings/bloc/settings_state.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  static const List<String> themeOptions = [
    'amberDark',
    'amberLight',
    'orangeDark',
    'orangeLight',
    'tealDark',
    'tealLight',
  ];

  Future<void> _pickTheme(BuildContext context, SettingsState state) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme'),
        children: themeOptions
            .map(
              (t) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, t),
                child: Text(
                  t,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null && selected.isNotEmpty) {
      context.read<SettingsBloc>().add(ChangeTheme(selected));
    }
  }

  Future<void> _pickLanguage(BuildContext context, SettingsState state) async {
    const languages = ['English', 'Nepali'];
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Language'),
        children: languages
            .map(
              (l) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, l),
                child: Text(l),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null && selected.isNotEmpty) {
      context.read<SettingsBloc>().add(ChangeLanguage(selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Settings',
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(state.theme),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickTheme(context, state),
              ),
              const Divider(),
              ListTile(
                title: const Text('Language'),
                subtitle: Text(state.language),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickLanguage(context, state),
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'About',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const ListTile(
                title: Text('version'),
                subtitle: Text('0.1.0'),
              ),
              const ListTile(
                title: Text('developer'),
                subtitle: Text('Quixo team'),
              ),
              const ListTile(
                title: Text('license'),
                subtitle: Text('MIT'),
              ),
            ],
          );
        },
      ),
    );
  }
}

