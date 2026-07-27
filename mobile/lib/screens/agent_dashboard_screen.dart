import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../services/api_service.dart';
import 'reminder_form_screen.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  List<Reminder> _reminders = [];
  bool _loading = true;
  String? _filter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<ApiService>();
    setState(() => _loading = true);
    try {
      final res = await api.listReminders(status: _filter);
      setState(() {
        _reminders = res.map((r) => Reminder.fromJson(r)).toList();
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setFilter(String? value) {
    setState(() => _filter = value);
    _load();
  }

  Future<void> _markPaid(Reminder r) async {
    final api = context.read<ApiService>();
    try {
      await api.updateReminder(r.id, status: 'paid');
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final overdue = _reminders.where((r) => r.status == 'unpaid' && _parseDate(r.dueDate).isBefore(now)).length;
    final unpaid = _reminders.where((r) => r.status == 'unpaid').length;
    final paid = _reminders.where((r) => r.status == 'paid').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ReminderFormScreen()));
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Column(
                children: [
                  // Summary cards
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _SummaryCard(label: 'Overdue', count: overdue, color: Colors.red),
                        const SizedBox(width: 8),
                        _SummaryCard(label: 'Unpaid', count: unpaid, color: Colors.orange),
                        const SizedBox(width: 8),
                        _SummaryCard(label: 'Paid', count: paid, color: Colors.green),
                      ],
                    ),
                  ),
                  // Filter tabs
                  Row(
                    children: [
                      _FilterChip('All', null, _filter == null, _setFilter),
                      _FilterChip('Unpaid', 'unpaid', _filter == 'unpaid', _setFilter),
                      _FilterChip('Paid', 'paid', _filter == 'paid', _setFilter),
                      _FilterChip('Overdue', 'overdue', _filter == 'overdue', _setFilter),
                    ].map((w) => Expanded(child: w)).toList(),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _reminders.isEmpty
                        ? const Center(child: Text('No reminders'))
                        : ListView.builder(
                            itemCount: _reminders.length,
                            itemBuilder: (ctx, i) {
                              final r = _reminders[i];
                              final isOverdue = r.status == 'unpaid' && _parseDate(r.dueDate).isBefore(now);
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isOverdue
                                        ? Colors.red.shade50
                                        : r.status == 'paid'
                                            ? Colors.green.shade50
                                            : Colors.orange.shade50,
                                    child: Icon(
                                      isOverdue
                                          ? Icons.warning
                                          : r.status == 'paid'
                                              ? Icons.check_circle
                                              : Icons.pending,
                                      color: isOverdue
                                          ? Colors.red
                                          : r.status == 'paid'
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                  ),
                                  title: Text(r.tenantName),
                                  subtitle: Text(
                                    '${r.unitNumber != null ? '${r.unitNumber} - ' : ''}Due: ${r.dueDate}'
                                    '${r.rentAmount != null ? ' | KSh ${r.rentAmount!.toStringAsFixed(0)}' : ''}',
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (action) async {
                                      if (action == 'paid') {
                                        _markPaid(r);
                                      } else if (action == 'edit') {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ReminderFormScreen(reminder: r),
                                          ),
                                        );
                                        _load();
                                      } else if (action == 'delete') {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Reminder'),
                                            content: Text('Delete reminder for ${r.tenantName}?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          try {
                                            final api = context.read<ApiService>();
                                            await api.deleteReminder(r.id);
                                            _load();
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed: $e')),
                                              );
                                            }
                                          }
                                        }
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      if (r.status != 'paid')
                                        const PopupMenuItem(value: 'paid', child: Text('Mark Paid')),
                                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

DateTime _parseDate(String iso) {
  try {
    return DateTime.parse(iso);
  } catch (_) {
    return DateTime.now();
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryCard({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final bool selected;
  final void Function(String?) onSelected;
  const _FilterChip(this.label, this.value, this.selected, this.onSelected);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(value),
      ),
    );
  }
}
