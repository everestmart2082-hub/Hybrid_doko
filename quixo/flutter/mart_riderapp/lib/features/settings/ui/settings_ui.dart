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
  static const themeOptions = [
    "orange-bluegray",
    "teal-blue",
    "amber-red",
    "orange-bluegray-dark",
    "teal-blue-dark",
    "amber-red-dark",
  ];

  Future<void> _pickThemeAndDispatch(SettingsState state) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          'Select Color Theme',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        children: themeOptions
            .map(
              (t) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, t),
                child: Text(
                  t,
                  style: TextStyle(color: Theme.of(context).primaryColor),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: buildAppDrawer(context),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Theme.of(context).primaryColorLight,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(state.theme),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickThemeAndDispatch(state),
                ),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Language',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const ListTile(
                  title: Text('English'),
                ),
                const ListTile(
                  title: Text('Nepali'),
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
            ),
          );
        },
      ),
    );
  }
}

