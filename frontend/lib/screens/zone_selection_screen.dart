import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'user_home_screen.dart';

class ZoneSelectionScreen extends StatefulWidget {
  const ZoneSelectionScreen({super.key});

  @override
  State<ZoneSelectionScreen> createState() => _ZoneSelectionScreenState();
}

class _ZoneSelectionScreenState extends State<ZoneSelectionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadZonesIfNeeded();
    });
  }

  Future<void> _loadZonesIfNeeded() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.useRemoteApi && appState.remoteZones.isEmpty) {
      setState(() {
        _isLoading = true;
      });
      await appState.loadRemoteCommonData();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context);

    // Hardcoded local zones
    final List<Map<String, dynamic>> localZones = const [
      {
        'name': 'Western Railway',
        'code': 'WR',
        'icon': Icons.explore_rounded,
        'color': Color(0xFF2E5B82),
      },
      {
        'name': 'Central Railway',
        'code': 'CR',
        'icon': Icons.adjust_rounded,
        'color': Color(0xFFC05656),
      },
      {
        'name': 'Northern Railway',
        'code': 'NR',
        'icon': Icons.north_rounded,
        'color': Color(0xFF4A8B82),
      },
      {
        'name': 'Southern Railway',
        'code': 'SR',
        'icon': Icons.south_rounded,
        'color': Color(0xFF6B5B95),
      },
    ];

    // Determine which zones to display (always use API zones first)
    final List<Map<String, dynamic>> displayZones = [];
    
    displayZones.add({
      'name': 'All Zones',
      'code': 'ALL',
      'icon': Icons.public_rounded,
      'color': const Color(0xFF4F46E5),
    });

    final zonesSource = appState.remoteZones.isNotEmpty ? appState.remoteZones : localZones;
    
    for (final z in zonesSource) {
      final String name = z['name']?.toString() ?? '';
      final String slug = z['slug']?.toString() ?? z['code']?.toString()?.toLowerCase() ?? '';
      
      IconData icon = Icons.train_rounded;
      Color color = AppTheme.primaryBlue;
      
      // Fallback for code extraction
      String code = slug.toUpperCase().split('-').map((s) => s.isNotEmpty ? s[0] : '').join();
      if (code.isEmpty) code = z['code']?.toString() ?? 'RLY';

      // Check if there is a local zone match for icon/color/code to keep beautiful styling
      final match = localZones.firstWhere(
        (lz) => lz['name'].toString().toLowerCase() == name.toLowerCase() ||
                name.toLowerCase().contains(lz['name'].toString().toLowerCase()) ||
                lz['name'].toString().toLowerCase().contains(name.toLowerCase()),
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        icon = match['icon'] as IconData;
        color = match['color'] as Color;
        code = match['code'] as String;
      }

      displayZones.add({
        'name': name,
        'code': code,
        'icon': icon,
        'color': color,
      });
    }

    final showLoading = _isLoading || appState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Railway Zone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await appState.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? [AppTheme.bgDark, const Color(0xFF1E293B)] 
                : [Colors.white, const Color(0xFFEFF6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose Your Zone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textLightPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your regional railway zone to load the corresponding rule books & slips.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: showLoading
                      ? const Center(child: CircularProgressIndicator())
                      : displayZones.isEmpty
                          ? Center(
                              child: Text(
                                'No zones loaded. Please check your internet connection.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: displayZones.length,
                              itemBuilder: (context, index) {
                                final zone = displayZones[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: InkWell(
                                    onTap: () async {
                                      await appState.selectZone(zone['name'] as String);
                                      if (context.mounted) {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (_) => const UserHomeScreen()),
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppTheme.cardDark : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.03),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                        border: Border.all(
                                          color: (zone['color'] as Color).withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: (zone['color'] as Color).withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              zone['icon'] as IconData,
                                              color: zone['color'] as Color,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  zone['name'] as String,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? Colors.white : AppTheme.textLightPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  'Division Code: ${zone['code']}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 16,
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
