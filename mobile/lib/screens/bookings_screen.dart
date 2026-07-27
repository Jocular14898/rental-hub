import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import 'property_detail_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Booking> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<ApiService>();
    setState(() => _loading = true);
    try {
      final res = await api.listMyBookings();
      setState(() {
        _bookings = res.map((b) => Booking.fromJson(b)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel(Booking b) async {
    final api = context.read<ApiService>();
    try {
      await api.updateBooking(b.id, status: 'cancelled');
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _bookings.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No bookings yet',
                                  style: TextStyle(color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _bookings.length,
                      itemBuilder: (ctx, i) {
                        final b = _bookings[i];
                        final p = b.property;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                              child: p != null && p.photoUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(p.photoUrl, fit: BoxFit.cover),
                                    )
                                  : const Icon(Icons.home),
                            ),
                            title: Text(p?.title ?? 'Property'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (b.message != null && b.message!.isNotEmpty)
                                  Text(b.message!, maxLines: 1, overflow: TextOverflow.ellipsis),
                                Row(
                                  children: [
                                    Icon(_statusIcon(b.status), size: 14, color: _statusColor(b.status)),
                                    const SizedBox(width: 4),
                                    Text(b.status, style: TextStyle(color: _statusColor(b.status), fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            trailing: b.status == 'pending'
                                ? TextButton(
                                    onPressed: () => _cancel(b),
                                    child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                  )
                                : null,
                            onTap: p != null
                                ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PropertyDetailScreen(property: p),
                                      ),
                                    )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
