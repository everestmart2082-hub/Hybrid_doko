import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/drawer.dart';
import 'package:quickmartcustomer/features/settings/bloc/settings_bloc.dart';
import 'package:quickmartcustomer/features/settings/bloc/settings_event.dart';
import 'package:quickmartcustomer/features/settings/bloc/settings_state.dart';
import 'package:quickmartcustomer/widgets/customer_hub_bar_icons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const List<String> themeOptions = [
    'amberDark',
    'amberLight',
    'orangeDark',
    'orangeLight',
    'tealDark',
    'tealLight',
  ];

  static const _languages = ['English', 'Nepali'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      drawer: buildAppDrawer(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text('Settings', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColorLight)),
        elevation: 1,
        actions: const [CustomerHubBarIcons()],
      ),
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
                        Text(
                          'Theme',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: themeOptions.map((t) {
                            final selected = state.theme == t;
                            return ChoiceChip(
                              label: Text(t),
                              selected: selected,
                              onSelected: (_) {
                                context
                                    .read<SettingsBloc>()
                                    .add(ChangeTheme(t));
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Language',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          children: _languages.map((lang) {
                            final selected = state.language == lang;
                            return ChoiceChip(
                              label: Text(lang),
                              selected: selected,
                              onSelected: (_) => context
                                  .read<SettingsBloc>()
                                  .add(ChangeLanguage(lang)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'About',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'version: 0.1.0',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'developer: Quixo team',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'license: MIT',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
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
