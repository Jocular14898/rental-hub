import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property.dart';
import '../services/api_service.dart';
import 'property_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _locationCtrl = TextEditingController();
  final _priceMinCtrl = TextEditingController();
  final _priceMaxCtrl = TextEditingController();
  int? _bedrooms;
  String? _houseType;
  List<Property> _results = [];
  bool _loading = false;
  bool _loadingMore = false;
  bool _searched = false;
  int _page = 1;
  int _totalPages = 1;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _priceMinCtrl.dispose();
    _priceMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final api = context.read<ApiService>();
    setState(() { _page = 1; _loading = true; _searched = true; });
    try {
      final res = await api.listProperties(
        location: _locationCtrl.text.isNotEmpty ? _locationCtrl.text : null,
        minPrice: _priceMinCtrl.text.isNotEmpty ? double.parse(_priceMinCtrl.text) : null,
        maxPrice: _priceMaxCtrl.text.isNotEmpty ? double.parse(_priceMaxCtrl.text) : null,
        bedrooms: _bedrooms,
        houseType: _houseType,
        page: 1,
      );
      setState(() {
        _results = (res['properties'] as List)
            .map((p) => Property.fromJson(p))
            .toList();
        _totalPages = res['pages'] ?? 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _page >= _totalPages) return;
    final api = context.read<ApiService>();
    setState(() => _loadingMore = true);
    try {
      final nextPage = _page + 1;
      final res = await api.listProperties(
        location: _locationCtrl.text.isNotEmpty ? _locationCtrl.text : null,
        minPrice: _priceMinCtrl.text.isNotEmpty ? double.parse(_priceMinCtrl.text) : null,
        maxPrice: _priceMaxCtrl.text.isNotEmpty ? double.parse(_priceMaxCtrl.text) : null,
        bedrooms: _bedrooms,
        houseType: _houseType,
        page: nextPage,
      );
      setState(() {
        _page = nextPage;
        _results.addAll((res['properties'] as List).map((p) => Property.fromJson(p)));
        _totalPages = res['pages'] ?? 1;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Houses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceMinCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Min Price',
                          border: OutlineInputBorder(),
                          prefixText: 'KSh ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _priceMaxCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Max Price',
                          border: OutlineInputBorder(),
                          prefixText: 'KSh ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    DropdownButton<int?>(
                      value: _bedrooms,
                      hint: const Text('Bedrooms'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Any')),
                        DropdownMenuItem(value: 1, child: Text('1br')),
                        DropdownMenuItem(value: 2, child: Text('2br')),
                        DropdownMenuItem(value: 3, child: Text('3br')),
                        DropdownMenuItem(value: 4, child: Text('4br+')),
                      ],
                      onChanged: (v) => setState(() => _bedrooms = v),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String?>(
                      value: _houseType,
                      hint: const Text('House Type'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                        DropdownMenuItem(value: 'maisonette', child: Text('Maisonette')),
                        DropdownMenuItem(value: 'bungalow', child: Text('Bungalow')),
                      ],
                      onChanged: (v) => setState(() => _houseType = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _search,
                    icon: _loading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.search),
                    label: Text(_loading ? 'Searching...' : 'Search'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_searched)
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('No properties found'))
                  : ListView(
                      children: [
                        ..._results.map((p) => ListTile(
                          leading: Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            child: p.photoUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(p.photoUrl, fit: BoxFit.cover),
                                  )
                                : const Icon(Icons.home),
                          ),
                          title: Text(p.title),
                          subtitle: Text('KSh ${p.price.toStringAsFixed(0)}/mo - ${p.bedrooms}br'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)),
                          ),
                        )),
                        if (_page < _totalPages)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: _loadingMore
                                  ? const CircularProgressIndicator()
                                  : OutlinedButton(
                                      onPressed: _loadMore,
                                      child: const Text('Load More'),
                                    ),
                            ),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
