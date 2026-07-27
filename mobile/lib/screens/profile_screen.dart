import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _subStatus;
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
      _profile = await api.getProfile();
      final sub = await api.getSubscriptionStatus();
      setState(() { _subStatus = sub; });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _subscribe(String plan) async {
    final api = context.read<ApiService>();
    try {
      final res = await api.initiateSubscription(planType: plan);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['mpesa']?['message'] ?? 'Subscription initiated')),
      );
      _loadSub();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = _profile ?? auth.currentUser;
    final isLandlord = user?['user_type'] == 'landlord';
    final isAgent = user?['user_type'] == 'agent';
    final needsSub = isLandlord || isAgent;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    child: Text((user?['name'] ?? '?').toString()[0].toUpperCase()),
                  ),
                  const SizedBox(height: 12),
                  Text(user?['name']?.toString() ?? '', style: Theme.of(context).textTheme.titleMedium),
                  Text(user?['email']?.toString() ?? ''),
                  Text('+${user?['phone']?.toString() ?? ''}'),
                  Chip(label: Text((user?['user_type']?.toString() ?? '').toUpperCase())),
                ],
              ),
            ),
          ),
          if (needsSub) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subscription', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_loadingSub)
                      const LinearProgressIndicator()
                    else ...[
                      if (_subStatus != null && _subStatus!['active'] == true)
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text('Active', style: TextStyle(color: Colors.green)),
                          ],
                        )
                      else ...[
                        const Text('No active subscription'),
                        const SizedBox(height: 8),
                        if (isLandlord)
                          FilledButton.icon(
                            onPressed: () => _subscribe('landlord'),
                            icon: const Icon(Icons.payment),
                            label: const Text('Subscribe KSh 1,000/mo'),
                          ),
                        if (isAgent)
                          FilledButton.icon(
                            onPressed: () => _subscribe('agent'),
                            icon: const Icon(Icons.payment),
                            label: const Text('Subscribe KSh 500/mo'),
                          ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              final auth = context.read<AuthService>();
              final api = context.read<ApiService>();
              await auth.logout();
              api.clearToken();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
