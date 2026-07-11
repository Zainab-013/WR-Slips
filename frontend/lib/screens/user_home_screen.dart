import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'category_screen.dart';
import 'zone_selection_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'pdf_viewer_screen.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> localCategories = const [
      {
        'title': 'GR & SR',
        'subtitle': 'General Rules & Subsidiary Rules',
        'icon': Icons.gavel_rounded,
        'gradient': AppTheme.primaryGradient,
      },
      {
        'title': 'O.M',
        'subtitle': 'Operating Manual',
        'icon': Icons.settings_applications_rounded,
        'gradient': AppTheme.accentGradient,
      },
      {
        'title': 'A.M',
        'subtitle': 'Accident Manual',
        'icon': Icons.report_problem_rounded,
        'gradient': LinearGradient(
          colors: [Color(0xFFC05656), Color(0xFFD98383)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'B.W.M',
        'subtitle': 'Block Working Manual',
        'icon': Icons.alt_route_rounded,
        'gradient': LinearGradient(
          colors: [Color(0xFF6B5B95), Color(0xFF8D7FAD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'U.S.R',
        'subtitle': 'Unified Standard Schedule of Rates',
        'icon': Icons.monetization_on_rounded,
        'gradient': AppTheme.amberGradient,
      },
    ];

    final List<Map<String, dynamic>> categoriesToDisplay = List.from(localCategories);
    categoriesToDisplay.add({
      'title': 'Other',
      'subtitle': 'Other reference manuals & books',
      'icon': Icons.more_horiz_rounded,
      'gradient': const LinearGradient(
        colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    });

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
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync Offline Documents',
            onPressed: () => _showSyncProgressDialog(context, appState),
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () => appState.toggleThemeMode(),
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
              leading: const Icon(Icons.account_circle_outlined, color: AppTheme.primaryBlue),
              title: const Text('My Profile'),
              subtitle: const Text('View and manage account details'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppTheme.primaryBlue),
              title: const Text('Settings'),
              subtitle: const Text('Languages, Help, and Privacy policies'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
                            appState.useRemoteApi
                                ? 'Browse study material and regional manuals:'
                                : 'Please select a book category below:',
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

              const SizedBox(height: 10),

              // Categories Grid
              Expanded(
                child: categoriesToDisplay.isEmpty
                    ? Center(
                        child: Text(
                          'No categories found.',
                          style: TextStyle(
                            color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: categoriesToDisplay.length,
                        itemBuilder: (context, index) {
                          final section = categoriesToDisplay[index];
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

  void _showSyncProgressDialog(BuildContext context, AppState appState) {
    if (appState.isSyncing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync is already in progress...')),
      );
      return;
    }

    // Trigger sync operation asynchronously
    appState.syncAllDocuments();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer<AppState>(
          builder: (context, state, child) {
            // Automatically pop the dialog once sync completes
            if (!state.isSyncing && state.syncProgress >= 1.0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Offline sync completed successfully!'),
                      backgroundColor: AppTheme.accentTeal,
                    ),
                  );
                }
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.sync_rounded, color: AppTheme.primaryBlue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Syncing Documents',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.syncStatusText,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: state.syncProgress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Progress: ${(state.syncProgress * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
