import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/vendor/bloc/admin_vendor_bloc.dart';
import 'package:mart_adminapp/features/vendor/bloc/admin_vendor_event.dart';
import 'package:mart_adminapp/features/vendor/bloc/admin_vendor_state.dart';
import 'package:mart_adminapp/features/vendor/data/admin_vendor_model.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

class AdminVendorPage extends StatefulWidget {
  const AdminVendorPage({super.key});

  @override
  State<AdminVendorPage> createState() => _AdminVendorPageState();
}

class _AdminVendorPageState extends State<AdminVendorPage> {
  static const int _perPage = 10;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    context.read<AdminVendorBloc>().add(AdminVendorLoad());
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Vendors',
      child: BlocConsumer<AdminVendorBloc, AdminVendorState>(
        listener: (ctx, state) {
          if (state is AdminVendorActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green));
          } else if (state is AdminVendorFailed) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red));
          }
        },
        builder: (ctx, state) {
          if (state is AdminVendorLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminVendorLoaded) {
            final all = state.vendors;
            final pages = (all.length / _perPage).ceil().clamp(1, 9999);
            final start = _page * _perPage;
            final end = (start + _perPage).clamp(0, all.length);
            final items = all.sublist(start, end);

            return Column(children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _VendorCard(vendor: items[i]),
                ),
              ),
              _Pagination(
                current: _page,
                total: pages,
                onPrev: _page > 0 ? () => setState(() => _page--) : null,
                onNext: _page < pages - 1 ? () => setState(() => _page++) : null,
                onPage: (p) => setState(() => _page = p),
              ),
            ]);
          }
          if (state is AdminVendorFailed) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Press load to fetch vendors.'));
        },
      ),
    );
  }
}

class _VendorCard extends StatefulWidget {
  final AdminVendorItem vendor;
  const _VendorCard({required this.vendor});
  @override
  State<_VendorCard> createState() => _VendorCardState();
}

class _VendorCardState extends State<_VendorCard> {
  bool _expanded = false;
  final _violationCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _violationCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {                  
    final v = widget.vendor;
                    return Card(
                      color: Theme.of(context).primaryColorLight,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ExpansionTile(
                        title: Text('${v.name} (${v.storeName.isEmpty ? "No Store" : v.storeName})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: ${v.venderId} | Ph: ${v.number} | Rev: Rs. ${v.revenue}', style: Theme.of(context).textTheme.bodySmall),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          if (v.status == true) const Icon(Icons.verified, color: Colors.green, size: 18),
                          if (v.status != true) const Icon(Icons.pending, color: Colors.orange, size: 18),
                          const SizedBox(width: 8),
                          Icon(Icons.expand_more, color: Theme.of(context).textTheme.bodyLarge?.color,),
                        ]),
                        onExpansionChanged: (v) => setState(() => _expanded = v),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _InfoRow('Email', v.email),
                                _InfoRow('Address', v.address),
                                _InfoRow('Business', v.businessType),
                                _InfoRow('Verified', v.status?.toString() ?? 'null'),
                                _InfoRow('Suspended', v.suspended.toString()),
                                _InfoRow('Update Request', v.updateRequest?.toString() ?? 'null'),
                                if (v.adminMessage.isNotEmpty) ...[
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
                                    v.adminMessage,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text('Description: ${v.description}', style: Theme.of(context).textTheme.bodyMedium),
                                ),
                                if (v.panFile.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('PAN File:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          child: Image.network(
                                            '${ApiEndpoints.baseImageUrl}${v.panFile.startsWith('/') ? '' : '/'}${v.panFile}',
                                            height: 100,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Chip(label: Text('PAN: ${v.panFile}')),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Text('Violations',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                ...v.violations.map((viol) =>
                                    ListTile(dense: true, title: Text(viol.toString(), style: Theme.of(context).textTheme.bodyMedium),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete, size: 18, color: Theme.of(context).primaryColorDark,),
                                        onPressed: () {
                                          final newList = List<String>.from(
                                              v.violations.map((e) => e.toString()))
                                            ..remove(viol.toString());
                                          context.read<AdminVendorBloc>().add(
                                              AdminVendorUpdateViolations(
                                                  AdminViolationsRequest(
                                                      targetId: v.venderId,
                                                      violations: newList)));
                                        },
                                      ))),
                Row(children: [
                  Expanded(
                    child: TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      controller: _violationCtrl,
                      decoration: InputDecoration(
                          hintText: 'Add violation',
                          isDense: true,
                          border: OutlineInputBorder(),
                          hintStyle: Theme.of(context).textTheme.bodyMedium
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_violationCtrl.text.trim().isNotEmpty) {
                        final newList = List<String>.from(
                            v.violations.map((e) => e.toString()))
                          ..add(_violationCtrl.text.trim());
                        context.read<AdminVendorBloc>().add(
                            AdminVendorUpdateViolations(
                                AdminViolationsRequest(
                                    targetId: v.venderId,
                                    violations: newList)));
                        _violationCtrl.clear();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ]),
                const SizedBox(height: 10),
                TextField(
                  controller: _msgCtrl,
                  decoration: InputDecoration(
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                      labelText: 'Send notification message',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text(v.status == true ? 'Unapprove' : 'Approve'),
                    onPressed: () => context.read<AdminVendorBloc>().add(
                        AdminVendorApprove(
                            venderId: v.venderId, approved: v.status == true ? false : true)),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.pause),
                    label: const Text('Suspend'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    onPressed: () => context.read<AdminVendorBloc>().add(
                        AdminVendorSuspend(
                            venderId: v.venderId, suspended: true)),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Unsuspend'),
                    onPressed: () => context.read<AdminVendorBloc>().add(
                        AdminVendorSuspend(
                            venderId: v.venderId, suspended: false)),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.block),
                    label: const Text('Blacklist'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    onPressed: () => context.read<AdminVendorBloc>().add(
                        AdminVendorBlacklist(
                            venderId: v.venderId, blacklisted: true)),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.verified),
                    label: const Text('Unblacklist'),
                    onPressed: () => context.read<AdminVendorBloc>().add(
                        AdminVendorBlacklist(
                            venderId: v.venderId, blacklisted: false)),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.notifications),
                    label: const Text('Notify'),
                    onPressed: () {
                      if (_msgCtrl.text.trim().isNotEmpty) {
                        context.read<AdminVendorBloc>().add(AdminVendorNotify(
                            AdminNotificationRequest(
                                targetId: v.venderId,
                                message: _msgCtrl.text.trim())));
                        _msgCtrl.clear();
                      }
                    },
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Text('$label: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      );
}

class _Pagination extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final void Function(int) onPage;
  const _Pagination({
    required this.current,
    required this.total,
    required this.onPrev,
    required this.onNext,
    required this.onPage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(onPressed: onPrev, child: const Text('Prev')),
          ...List.generate(total, (i) => TextButton(
                onPressed: () => onPage(i),
                child: Text(
                  '${i + 1}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: i == current
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
              )),
          TextButton(onPressed: onNext, child: const Text('Next')),
        ],
      ),
    );
  }
}
