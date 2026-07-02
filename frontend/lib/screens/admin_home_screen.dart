import 'package:flutter/material';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'manage_documents_screen.dart';
import 'add_edit_document_screen.dart';
import 'role_selection_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final List<String> _zones = const [
    'Western Railway',
    'Central Railway',
    'Northern Railway',
    'Southern Railway',
  ];

  final List<Map<String, dynamic>> _sections = const [
    {
      'title': 'GR & SR',
      'subtitle': 'Manage General & Subsidiary Rules',
      'icon': Icons.gavel_rounded,
      'color': AppTheme.primaryBlue,
    },
    {
      'title': 'O.M',
      'subtitle': 'Manage Operating Manuals',
      'icon': Icons.settings_applications_rounded,
      'color': AppTheme.accentTeal,
    },
    {
      'title': 'A.M',
      'subtitle': 'Manage Accident Manuals',
      'icon': Icons.report_problem_rounded,
      'color': Colors.redAccent,
    },
    {
      'title': 'B.W.M',
      'subtitle': 'Manage Block Working Manuals',
      'icon': Icons.alt_route_rounded,
      'color': Colors.purple,
    },
    {
      'title': 'U.S.R',
      'subtitle': 'Manage Schedule of Rates',
      'icon': Icons.monetization_on_rounded,
      'color': AppTheme.secondaryAmber,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Set default zone if none selected
    if (appState.selectedZone == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.selectZone(_zones.first);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
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
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.secondaryAmber],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white30,
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
              ),
              accountName: Text(appState.currentUser?.name ?? 'Admin Officer'),
              accountEmail: Text(appState.currentUser?.email ?? 'admin@wr.gov.in'),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded, color: AppTheme.primaryBlue),
              title: const Text('Switch Role to User'),
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
              // Zone Selector Bar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Target Railway Zone Context:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: appState.selectedZone ?? _zones.first,
                          isExpanded: true,
                          dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                          items: _zones.map((zone) {
                            return DropdownMenuItem<String>(
                              value: zone,
                              child: Text(zone, style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              appState.selectZone(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Category Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Manage Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textLightPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Grid View for Sections
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: _sections.length,
                  itemBuilder: (context, index) {
                    final section = _sections[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ManageDocumentsScreen(
                              categoryName: section['title'] as String,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (section['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                section['icon'] as IconData,
                                color: section['color'] as Color,
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              section['title'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              section['subtitle'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary,
                              ),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditDocumentScreen(
                initialCategory: _sections.first['title'] as String,
              ),
            ),
          );
        },
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Document'),
      ),
    );
  }
}
