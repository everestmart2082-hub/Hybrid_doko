import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/features/settings/bloc/settings_bloc.dart';
import 'package:quickmartvender/features/settings/bloc/settings_event.dart';
import 'package:quickmartvender/features/settings/bloc/settings_state.dart';
import 'package:quickmartvender/core/constants/app_constants.dart';
import '../web_shell.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // theme key -> display label
  static const _themes = {
    'amberDark': 'Amber Dark',
    'amberLight': 'Amber Light (amber-red)',
    'orangeDark': 'Orange Dark (orange-bluegray-dark)',
    'orangeLight': 'Orange Light (orange-bluegray)',
    'tealDark': 'Teal Dark (teal-blue-dark)',
    'tealLight': 'Teal Light (teal-blue)',
  };

  static const _languages = ['English', 'Nepali'];

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Settings',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Theme ─────────────────────────────────────────
                  _SectionHeader('Theme'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _themes.entries.map((e) {
                      final selected = state.theme == e.key;
                      return ChoiceChip(
                        label: Text(e.value),
                        selected: selected,
                        onSelected: (_) =>
                            context.read<SettingsBloc>().add(ChangeTheme(e.key)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  // ── Language ──────────────────────────────────────
                  _SectionHeader('Language'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: _languages.map((lang) {
                      final selected = state.language == lang;
                      return ChoiceChip(
                        label: Text(lang),
                        selected: selected,
                        onSelected: (_) =>
                            context.read<SettingsBloc>().add(ChangeLanguage(lang)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  // ── About ─────────────────────────────────────────
                  _SectionHeader('About'),
                  const SizedBox(height: 10),
                  Card(
                    color: Theme.of(context).primaryColorLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Version'),
                          trailing: const Text('0.1.0'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('Developer'),
                          trailing: Text(AppConstants.appName),
                        ),
                        const Divider(height: 1),
                        const ListTile(
                          leading: Icon(Icons.gavel),
                          title: Text('License'),
                          trailing: Text('MIT'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold));
  }
}
