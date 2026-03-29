import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/drawer.dart';
import 'package:quickmartvender/features/settings/bloc/settings_bloc.dart';
import 'package:quickmartvender/features/settings/bloc/settings_event.dart';
import 'package:quickmartvender/features/settings/bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    const themeOptions = [
      "orange-bluegray",
      "teal-blue",
      "amber-red",
      "orange-bluegray-dark",
      "teal-blue-dark",
      "amber-red-dark",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: buildAppDrawer(context),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Theme.of(context).primaryColorLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              children: [
                // Theme selector
                ListTile(
                  title: const Text('Color Theme'),
                  subtitle: Text(state.theme),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final selected = await showDialog<String>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: Text(
                          'Select Color Theme',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
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

                    if (selected != null) {
                      context.read<SettingsBloc>().add(ChangeTheme(selected));
                    }
                  },
                ),

                const Divider(),

                // App version info
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('App Version'),
                  subtitle: Text('EverestMart v1.0.0'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
