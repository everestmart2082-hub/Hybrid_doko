import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/settings/bloc/settings_bloc.dart';
import 'package:quickmartcustomer/features/settings/bloc/settings_event.dart';
import 'package:quickmartcustomer/features/settings/bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _themes = <String, String>{
    // UI names -> internal theme strings used by `themeDataFromColors`.
    'amberDark': 'amber-red-dark',
    'amberLight': 'amber-red',
    'orangeDark': 'orange-bluegray-dark',
    'orangeLight': 'orange-bluegray',
  };

  final _languageOptions = const ['English', 'Nepali'];
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: null,
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Theme',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: _themes.entries.map((e) {
                            final uiName = e.key;
                            final internal = e.value;
                            final selected = state.theme == internal;
                            return ChoiceChip(
                              label: Text(uiName),
                              selected: selected,
                              onSelected: (_) {
                                context
                                    .read<SettingsBloc>()
                                    .add(ChangeTheme(internal));
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Language',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedLanguage,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _languageOptions
                              .map((lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _selectedLanguage = v);
                          },
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'About',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('version: 0.1.0'),
                                SizedBox(height: 8),
                                Text('developer: quickmart'),
                                SizedBox(height: 8),
                                Text('license: MIT'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

