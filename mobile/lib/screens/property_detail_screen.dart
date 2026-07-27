import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property.dart';
import '../config.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'post_property_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late Property _property;
  bool _isFavorited = false;
  bool _bookingLoading = false;

  @override
  void initState() {
    super.initState();
    _property = widget.property;
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    try {
      final api = context.read<ApiService>();
      final favs = await api.listFavorites();
      if (!mounted) return;
      setState(() {
        _isFavorited = favs.any((f) => f['property_id'] == _property.id);
      });
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final api = context.read<ApiService>();
    try {
      if (_isFavorited) {
        await api.removeFavorite(_property.id);
        setState(() => _isFavorited = false);
      } else {
        await api.addFavorite(_property.id);
        setState(() => _isFavorited = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _bookProperty() async {
    final messageCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inquire about this property'),
        content: TextField(
          controller: messageCtrl,
          decoration: const InputDecoration(
            hintText: 'Add a message (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send Inquiry'),
          ),
        ],
      ),
    );
    if (result != true) return;
    final api = context.read<ApiService>();
    setState(() => _bookingLoading = true);
    try {
      await api.createBooking(
        _property.id,
        message: messageCtrl.text.isNotEmpty ? messageCtrl.text : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inquiry sent!')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      messageCtrl.dispose();
      if (mounted) setState(() => _bookingLoading = false);
    }
  }

  void _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _whatsapp(String phone) async {
    final uri = Uri.parse('https://wa.me/$phone?text=Hi, I am interested in ${_property.title}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openMap(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _delete() async {
    final api = context.read<ApiService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Delete "${_property.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await api.deleteProperty(_property.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property deleted')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = context.watch<AuthService>().currentUser?.id == _property.landlordId;
    return Scaffold(
      appBar: AppBar(
        title: Text(_property.title),
        actions: [
          if (!isOwner)
            IconButton(
              icon: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: _isFavorited ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostPropertyScreen(property: _property),
                  ),
                );
                if (!mounted) return;
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _delete,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo gallery area
            SizedBox(
              height: 240,
              width: double.infinity,
              child: _property.photos.isNotEmpty
                  ? PageView.builder(
                      itemCount: _property.photos.length,
                      itemBuilder: (ctx, i) => Image.network(
                        _property.photos[i].url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Center(child: Icon(Icons.broken_image, size: 48)),
                        ),
                      ),
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(child: Icon(Icons.home, size: 64)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_property.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.monetization_on, size: 18,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('KSh ${_property.price.toStringAsFixed(0)}/month',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(_property.location)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _Chip(icon: Icons.bed, label: '${_property.bedrooms} Bedroom${_property.bedrooms > 1 ? 's' : ''}'),
                      if (_property.houseType != null) _Chip(icon: Icons.home, label: _property.houseType!),
                      _Chip(
                        icon: _property.parking ? Icons.check_circle : Icons.cancel,
                        label: 'Parking',
                        color: _property.parking ? Colors.green : Colors.red,
                      ),
                      _Chip(
                        icon: _property.waterAvailable ? Icons.check_circle : Icons.cancel,
                        label: 'Water',
                        color: _property.waterAvailable ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  if (_property.description != null && _property.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Description', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(_property.description!),
                  ],
                  if (_property.securityDetails != null && _property.securityDetails!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Security', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(_property.securityDetails!),
                  ],
                  if (_property.latitude != null && _property.longitude != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _openMap(_property.latitude!, _property.longitude!),
                      icon: const Icon(Icons.map),
                      label: const Text('View on Map'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _call(_property.contactPhone),
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 12),
              if (!isOwner) ...[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _bookingLoading ? null : _bookProperty,
                    icon: _bookingLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                    label: const Text('Inquire'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _whatsapp(_property.contactPhone),
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _Chip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
