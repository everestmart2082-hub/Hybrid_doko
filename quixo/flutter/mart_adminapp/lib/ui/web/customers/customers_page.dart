import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/customer/bloc/admin_customer_bloc.dart';
import 'package:mart_adminapp/features/customer/bloc/admin_customer_event.dart';
import 'package:mart_adminapp/features/customer/bloc/admin_customer_state.dart';
import 'package:mart_adminapp/features/customer/data/admin_customer_model.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

class AdminCustomersPage extends StatefulWidget {
  const AdminCustomersPage({super.key});

  @override
  State<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends State<AdminCustomersPage> {
  static const int _perPage = 10;
  int _page = 0;
  List<AdminUserItem> _users = const [];

  @override
  void initState() {
    super.initState();
    context.read<AdminCustomerBloc>().add(AdminCustomerLoad());
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Customers',
      child: BlocConsumer<AdminCustomerBloc, AdminCustomerState>(
        listener: (context, state) {
          if (state is AdminCustomerLoaded) {
            setState(() => _users = state.users);
          } else if (state is AdminCustomerActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AdminCustomerFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_users.isEmpty && state is AdminCustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalPages =
              (_users.length / _perPage).ceil().clamp(1, 999999);
          final page = _page.clamp(0, totalPages - 1);
          final start = page * _perPage;
          final end = (start + _perPage).clamp(0, _users.length);
          final items = _users.sublist(start, end);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _CustomerCard(user: items[index]);
                  },
                ),
              ),
              _Pagination(
                page: page,
                totalPages: totalPages,
                onPrev: page > 0 ? () => setState(() => _page = page - 1) : null,
                onNext: page < totalPages - 1 ? () => setState(() => _page = page + 1) : null,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CustomerCard extends StatefulWidget {
  final AdminUserItem user;
  const _CustomerCard({required this.user});

  @override
  State<_CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<_CustomerCard> {
  final _violationCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _violationCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  List<String> get _violations =>
      widget.user.violations.map((e) => e.toString()).toList();

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final violations = _violations;
    final verified = u.status == true;

    return Card(
      color: Theme.of(context).primaryColorLight,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(u.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text('ID: ${u.userId}', style: Theme.of(context).textTheme.bodySmall),
        trailing: verified
            ? const Icon(Icons.verified, color: Colors.green, size: 18)
            : const Icon(Icons.pending, color: Colors.orange, size: 18),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('verified: ${u.status}', style: Theme.of(context).textTheme.bodyMedium),
                if (u.adminMessage.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Admin notify (stored message)',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    u.adminMessage,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 6),
                Text('updateRequest: ${u.updateRequest}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 14),
                Text(
                  'Violations',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ...violations.map(
                  (viol) => ListTile(
                    dense: true,
                    title: Text(viol, style: Theme.of(context).textTheme.bodyMedium),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () {
                        final newList = List<String>.from(violations)
                          ..remove(viol);
                        context.read<AdminCustomerBloc>().add(
                              AdminCustomerUpdateViolations(
                                userId: u.userId,
                                violations: newList,
                              ),
                            );
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        controller: _violationCtrl,
                        decoration: InputDecoration(
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                          hintText: 'Add violation',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final txt = _violationCtrl.text.trim();
                        if (txt.isEmpty) return;
                        final newList = List<String>.from(violations)..add(txt);
                        context.read<AdminCustomerBloc>().add(
                              AdminCustomerUpdateViolations(
                                userId: u.userId,
                                violations: newList,
                              ),
                            );
                        _violationCtrl.clear();
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  controller: _msgCtrl,
                  decoration: InputDecoration(
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    labelText: 'Send notification message',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text(verified ? 'Unverify' : 'Verify'),
                      onPressed: () => context.read<AdminCustomerBloc>().add(
                            AdminCustomerApprove(
                              userId: u.userId,
                              approved: verified ? false : true,
                            ),
                          ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.pause),
                      label: const Text('Suspend'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () => context.read<AdminCustomerBloc>().add(
                            AdminCustomerSuspend(
                              userId: u.userId,
                              suspended: true,
                            ),
                          ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Unsuspend'),
                      onPressed: () => context.read<AdminCustomerBloc>().add(
                            AdminCustomerSuspend(
                              userId: u.userId,
                              suspended: false,
                            ),
                          ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.block),
                      label: const Text('Blacklist'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => context.read<AdminCustomerBloc>().add(
                            AdminCustomerBlacklist(
                              userId: u.userId,
                              blacklisted: true,
                            ),
                          ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.verified),
                      label: const Text('Unblacklist'),
                      onPressed: () => context.read<AdminCustomerBloc>().add(
                            AdminCustomerBlacklist(
                              userId: u.userId,
                              blacklisted: false,
                            ),
                          ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.notifications),
                      label: const Text('Notify'),
                      onPressed: () {
                        final msg = _msgCtrl.text.trim();
                        if (msg.isEmpty) return;
                        context.read<AdminCustomerBloc>().add(
                              AdminCustomerNotify(
                                userId: u.userId,
                                message: msg,
                              ),
                            );
                        _msgCtrl.clear();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _Pagination({
    required this.page,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          TextButton(onPressed: onPrev, child: const Text('Prev')),
          const SizedBox(width: 10),
          Text('${page + 1} / $totalPages', style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          TextButton(onPressed: onNext, child: const Text('Next')),
        ],
      ),
    );
  }
}

