import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorite.dart';
import '../services/api_service.dart';
import 'property_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Favorite> _favorites = [];
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
      final res = await api.listFavorites();
      setState(() {
        _favorites = res.map((f) => Favorite.fromJson(f)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Properties')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _favorites.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No saved properties yet',
                                  style: TextStyle(color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _favorites.length,
                      itemBuilder: (ctx, i) {
                        final f = _favorites[i];
                        final p = f.property;
                        if (p == null) return const SizedBox.shrink();
                        return ListTile(
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
                          subtitle: Text('KSh ${p.price.toStringAsFixed(0)}/mo'),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () async {
                              try {
                                final api = context.read<ApiService>();
                                await api.removeFavorite(p.id);
                                _load();
                              } catch (_) {}
                            },
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PropertyDetailScreen(property: p),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
