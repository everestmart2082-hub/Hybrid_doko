import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartrider/drawer.dart';
import 'package:quickmartrider/features/settings/bloc/settings_bloc.dart';
import 'package:quickmartrider/features/settings/bloc/settings_event.dart';
import 'package:quickmartrider/features/settings/bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
        backgroundColor: Theme.of(context).primaryColorLight,
        title: const Text('Theme'),
        children: themeOptions
            .map(
              (t) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, t),
                child: Text(
                  t,
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
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
        backgroundColor: Theme.of(context).primaryColorLight,
        title: const Text('Language'),
        children: languages
            .map(
              (l) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, l),
                child: Text(
                  l,
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
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
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text('Settings', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColorLight)),
        elevation: 1,
      ),
      drawer: buildAppDrawer(context),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: Text(
                  'Theme',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  state.theme,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                ),
                onTap: () => _pickTheme(context, state),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Language',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  state.language,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                ),
                onTap: () => _pickLanguage(context, state),
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'About',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(
                  'version',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  '0.1.0',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ListTile(
                title: Text(
                  'developer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Quixo team',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ListTile(
                title: Text(
                  'license',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'MIT',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
