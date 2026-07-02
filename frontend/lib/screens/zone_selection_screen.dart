import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'user_home_screen.dart';

class ZoneSelectionScreen extends StatelessWidget {
  const ZoneSelectionScreen({super.key});

  final List<Map<String, dynamic>> _zones = const [
    {
      'name': 'Western Railway',
      'code': 'WR',
      'icon': Icons.explore_rounded,
      'color': Color(0xFF1E3A8A),
    },
    {
      'name': 'Central Railway',
      'code': 'CR',
      'icon': Icons.adjust_rounded,
      'color': Color(0xFFB91C1C),
    },
    {
      'name': 'Northern Railway',
      'code': 'NR',
      'icon': Icons.north_rounded,
      'color': Color(0xFF047857),
    },
    {
      'name': 'Southern Railway',
      'code': 'SR',
      'icon': Icons.south_rounded,
      'color': Color(0xFF7C3AED),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context);

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
                  child: ListView.builder(
                    itemCount: _zones.length,
                    itemBuilder: (context, index) {
                      final zone = _zones[index];
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
                                        'Division Division Code: ${zone['code']}',
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
