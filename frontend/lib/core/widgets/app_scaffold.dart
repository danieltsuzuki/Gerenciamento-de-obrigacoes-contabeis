import 'package:flutter/material.dart';
import '../routing/app_routes.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final int currentNavIndex;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.currentNavIndex = 0,
  });

  void _onNavigationItemTapped(BuildContext context, int index) {
    if (index == currentNavIndex) return;

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.obligations);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(AppRoutes.companies);
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(AppRoutes.responsibles);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 768;

    if (isWideScreen) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.account_balance, size: 24),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
          actions: actions,
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentNavIndex,
              onDestinationSelected: (index) => _onNavigationItemTapped(context, index),
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Player\nContabilidade',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: Text('Obrigações'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.business_outlined),
                  selectedIcon: Icon(Icons.business),
                  label: Text('Empresas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Responsáveis'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1E3A8A),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.account_balance, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Player Contabilidade',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Gestão de Obrigações Fiscais',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Obrigações'),
              selected: currentNavIndex == 0,
              onTap: () {
                Navigator.of(context).pop();
                _onNavigationItemTapped(context, 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text('Empresas'),
              selected: currentNavIndex == 1,
              onTap: () {
                Navigator.of(context).pop();
                _onNavigationItemTapped(context, 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Responsáveis'),
              selected: currentNavIndex == 2,
              onTap: () {
                Navigator.of(context).pop();
                _onNavigationItemTapped(context, 2);
              },
            ),
          ],
        ),
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentNavIndex,
        onDestinationSelected: (index) => _onNavigationItemTapped(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Obrigações',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Empresas',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Responsáveis',
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
