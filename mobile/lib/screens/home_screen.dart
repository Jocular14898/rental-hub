import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'search_screen.dart';
import 'property_detail_screen.dart';
import 'post_property_screen.dart';
import 'agent_dashboard_screen.dart';
import 'favorites_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Property> _properties = [];
  List<Property> _featured = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  int _totalPages = 1;
  String? _error;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<ApiService>();
    setState(() { _page = 1; _loading = true; _error = null; });
    try {
      final res = await api.listProperties(page: 1);
      final list = (res['properties'] as List)
          .map((p) => Property.fromJson(p))
          .toList();
      setState(() {
        _properties = list;
        _featured = list.take(5).toList();
        _totalPages = res['pages'] ?? 1;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Could not load properties');
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
      final res = await api.listProperties(page: nextPage);
      final list = (res['properties'] as List)
          .map((p) => Property.fromJson(p))
          .toList();
      setState(() {
        _page = nextPage;
        _properties.addAll(list);
        _totalPages = res['pages'] ?? 1;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final isLandlord = user?.userType == 'landlord';
    final isAgent = user?.userType == 'agent';
    final isTenant = user?.userType == 'tenant';

    if (isTenant) {
      final tabs = <Widget>[
        _buildBrowseTab(),
        const FavoritesScreen(),
        const BookingsScreen(),
      ];
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rental Hub'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
          ],
        ),
        body: tabs[_tabIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (i) => setState(() => _tabIndex = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.explore), label: 'Browse'),
            NavigationDestination(icon: Icon(Icons.favorite), label: 'Saved'),
            NavigationDestination(icon: Icon(Icons.bookmark), label: 'Bookings'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: _buildBrowseTab(),
    );
  }

  Widget _buildBrowseTab() {
    final user = context.watch<AuthService>().currentUser;
    final isLandlord = user?.userType == 'landlord';
    final isAgent = user?.userType == 'agent';

    return RefreshIndicator(
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SearchScreen()),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 12),
                                    Text('Search houses...', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _ActionCard(
                                    icon: Icons.search,
                                    label: 'Search',
                                    onTap: () => Navigator.push(
                                      context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                                  ),
                                ),
                                if (isLandlord) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _ActionCard(
                                      icon: Icons.add_home,
                                      label: 'Post House',
                                      onTap: () => Navigator.push(
                                        context, MaterialPageRoute(builder: (_) => const PostPropertyScreen())),
                                    ),
                                  ),
                                ],
                                if (isAgent) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _ActionCard(
                                      icon: Icons.notifications,
                                      label: 'Reminders',
                                      onTap: () => Navigator.push(
                                        context, MaterialPageRoute(builder: (_) => const AgentDashboardScreen())),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (_featured.isNotEmpty) ...[
                              Text('Featured Houses', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 200,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _featured.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (ctx, i) => _FeaturedCard(
                                    property: _featured[i],
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PropertyDetailScreen(property: _featured[i]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Text('Latest Houses', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final p = _properties[i];
                          return _PropertyListItem(
                            property: p,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)),
                            ),
                          );
                        },
                        childCount: _properties.length,
                      ),
                    ),
                    if (_page < _totalPages)
                      SliverToBoxAdapter(
                        child: Padding(
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
                      ),
                  ],
                ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  const _FeaturedCard({required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: property.photoUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(property.photoUrl),
                  fit: BoxFit.cover,
                )
              : null,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withAlpha(180)],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(property.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('KSh ${property.price.toStringAsFixed(0)}/mo', style: const TextStyle(color: Colors.white70)),
              Text('${property.bedrooms}br ${property.location}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyListItem extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  const _PropertyListItem({required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  image: property.photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(property.photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: property.photoUrl.isEmpty
                    ? Icon(Icons.home, color: Theme.of(context).colorScheme.onSurfaceVariant)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text('KSh ${property.price.toStringAsFixed(0)}/mo', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    Row(
                      children: [
                        const Icon(Icons.bed, size: 14),
                        const SizedBox(width: 4),
                        Text('${property.bedrooms}br', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Expanded(child: Text(property.location, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
