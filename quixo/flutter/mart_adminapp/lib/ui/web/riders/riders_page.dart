import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/rider/bloc/admin_rider_bloc.dart';
import 'package:mart_adminapp/features/rider/bloc/admin_rider_event.dart';
import 'package:mart_adminapp/features/rider/bloc/admin_rider_state.dart';
import 'package:mart_adminapp/features/rider/data/admin_rider_model.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

class AdminRidersPage extends StatefulWidget {
  const AdminRidersPage({super.key});

  @override
  State<AdminRidersPage> createState() => _AdminRidersPageState();
}

class _AdminRidersPageState extends State<AdminRidersPage> {
  static const int _perPage = 10;
  int _page = 0;
  List<AdminRiderItem> _riders = const [];

  @override
  void initState() {
    super.initState();
    context.read<AdminRiderBloc>().add(AdminRiderLoad());
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Riders',
      child: BlocConsumer<AdminRiderBloc, AdminRiderState>(
        listener: (context, state) {
          if (state is AdminRiderLoaded) {
            setState(() => _riders = state.riders);
          } else if (state is AdminRiderActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AdminRiderFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_riders.isEmpty && state is AdminRiderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalPages =
              (_riders.length / _perPage).ceil().clamp(1, 999999);
          final page = _page.clamp(0, totalPages - 1);
          final start = page * _perPage;
          final end = (start + _perPage).clamp(0, _riders.length);
          final items = _riders.sublist(start, end);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _RiderCard(rider: items[index]);
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

class _RiderCard extends StatefulWidget {
  final AdminRiderItem rider;
  const _RiderCard({required this.rider});

  @override
  State<_RiderCard> createState() => _RiderCardState();
}

class _RiderCardState extends State<_RiderCard> {
  final _violationCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _violationCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  List<String> get _violations =>
      widget.rider.violations.map((e) => e.toString()).toList();

  Widget _buildFilePreview(String label, String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ClipRRect(
          child: Image.network(
            '${ApiEndpoints.baseImageUrl}${url.startsWith('/') ? '' : '/'}$url',
            height: 80,
            width: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Chip(label: Text(label, style: const TextStyle(fontSize: 10))),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.rider;
    final violations = _violations;

    return Card(
      color: Theme.of(context).primaryColorLight,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text('${r.name} (${r.type.isEmpty ? "No Vehicle" : r.type})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text('ID: ${r.riderId} | Ph: ${r.number} | Rev: Rs. ${r.revenue} | Rate: ${r.rating}', style: Theme.of(context).textTheme.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (r.status == true) const Icon(Icons.verified, color: Colors.green, size: 18),
            if (r.status != true) const Icon(Icons.pending, color: Colors.orange, size: 18),
          ],
        ),
        onExpansionChanged: (v) => setState(() => _expanded = v),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Text('Email: ${r.email}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Address: ${r.address}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Verified: ${r.status}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Suspended: ${r.suspended}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Update Request: ${r.updateRequest}', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Vehicle: ${r.bikeColor} ${r.bikeModel} [${r.bikeNumber}]', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (r.citizenshipFile.isNotEmpty)
                      _buildFilePreview('Citizenship', r.citizenshipFile),
                    if (r.panCardFile.isNotEmpty)
                      _buildFilePreview('PAN Card', r.panCardFile),
                    if (r.rcBookFile.isNotEmpty)
                      _buildFilePreview('RC Book', r.rcBookFile),
                    if (r.bikeInsuranceFile.isNotEmpty)
                      _buildFilePreview('Insurance', r.bikeInsuranceFile),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Violations',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                ...violations.map(
                  (viol) => ListTile(
                    dense: true,
                    title: Text(viol, style: Theme.of(context).textTheme.bodyMedium),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, size: 18, color: Theme.of(context).primaryColorDark,),
                      onPressed: () {
                        final newList = List<String>.from(violations)
                          ..remove(viol);
                        context.read<AdminRiderBloc>().add(
                              AdminRiderUpdateViolations(
                                riderId: r.riderId,
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
                        onSubmitted: (_) {
                          final txt = _violationCtrl.text.trim();
                          if (txt.isEmpty) return;
                          final newList = List<String>.from(violations)..add(txt);
                          context.read<AdminRiderBloc>().add(
                                AdminRiderUpdateViolations(
                                  riderId: r.riderId,
                                  violations: newList,
                                ),
                              );
                          _violationCtrl.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final txt = _violationCtrl.text.trim();
                        if (txt.isEmpty) return;
                        final newList = List<String>.from(violations)..add(txt);
                        context.read<AdminRiderBloc>().add(
                              AdminRiderUpdateViolations(
                                riderId: r.riderId,
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
                      label: Text(r.status == true ? 'Unverify' : 'Verify'),
                      onPressed: () => context.read<AdminRiderBloc>().add(
                            AdminRiderApprove(
                              riderId: r.riderId,
                              approved: r.status == true ? false : true,
                            ),
                          ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.pause),
                      label: const Text('Suspend'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () => context.read<AdminRiderBloc>().add(
                            AdminRiderSuspend(
                              riderId: r.riderId,
                              suspended: true,
                            ),
                          ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Unsuspend'),
                      onPressed: () => context.read<AdminRiderBloc>().add(
                            AdminRiderSuspend(
                              riderId: r.riderId,
                              suspended: false,
                            ),
                          ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.block),
                      label: const Text('Blacklist'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => context.read<AdminRiderBloc>().add(
                            AdminRiderBlacklist(
                              riderId: r.riderId,
                              blacklisted: true,
                            ),
                          ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.verified),
                      label: const Text('Unblacklist'),
                      onPressed: () => context.read<AdminRiderBloc>().add(
                            AdminRiderBlacklist(
                              riderId: r.riderId,
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
                        context.read<AdminRiderBloc>().add(
                              AdminRiderNotify(
                                riderId: r.riderId,
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

