import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'category_screen.dart';
import 'zone_selection_screen.dart';
import 'role_selection_screen.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  final List<Map<String, dynamic>> _sections = const [
    {
      'title': 'GR & SR',
      'subtitle': 'General Rules & Subsidiary Rules',
      'icon': Icons.gavel_rounded,
      'gradient': LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'O.M',
      'subtitle': 'Operating Manual',
      'icon': Icons.settings_applications_rounded,
      'gradient': LinearGradient(
        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'A.M',
      'subtitle': 'Accident Manual',
      'icon': Icons.report_problem_rounded,
      'gradient': LinearGradient(
        colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'B.W.M',
      'subtitle': 'Block Working Manual',
      'icon': Icons.alt_route_rounded,
      'gradient': LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'U.S.R',
      'subtitle': 'Unified Standard Schedule of Rates',
      'icon': Icons.monetization_on_rounded,
      'gradient': LinearGradient(
        colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'WR & SLIPS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            Text(
              appState.selectedZone ?? 'No Zone Selected',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () => appState.toggleThemeMode(),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Switch Role',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              accountName: Text(appState.currentUser?.name ?? 'Guest User'),
              accountEmail: Text(appState.currentUser?.email ?? 'No email associated'),
            ),
            ListTile(
              leading: const Icon(Icons.pin_drop_rounded, color: AppTheme.primaryBlue),
              title: const Text('Change Railway Zone'),
              subtitle: Text(appState.selectedZone ?? 'Select your zone'),
              onTap: () {
                Navigator.of(context).pop(); // close drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ZoneSelectionScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.secondaryAmber),
              title: const Text('Manage System (Admin)'),
              subtitle: const Text('Access upload and document management controls'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                );
              },
            ),
            const Divider(),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Sign Out'),
              onTap: () async {
                Navigator.of(context).pop();
                await appState.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Welcome Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${appState.currentUser?.name ?? "Officer"}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please select a book category below:',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Categories Grid
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _sections.length,
                  itemBuilder: (context, index) {
                    final section = _sections[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CategoryScreen(
                                categoryName: section['title'] as String,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: section['gradient'] as LinearGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (section['gradient'] as LinearGradient).colors[0].withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Opacity(
                                  opacity: 0.15,
                                  child: Icon(
                                    section['icon'] as IconData,
                                    size: 140,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        section['icon'] as IconData,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            section['title'] as String,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            section['subtitle'] as String,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  ],
                                ),
                              ),
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
    );
  }
}
