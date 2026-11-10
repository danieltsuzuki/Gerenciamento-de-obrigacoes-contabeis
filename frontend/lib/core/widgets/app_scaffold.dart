import 'package:flutter/material.dart';
import '../../features/auth/presentation/controllers/auth_session_controller.dart';
import '../routing/app_routes.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final int currentNavIndex;
  final AuthSessionController? authController;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.currentNavIndex = 0,
    this.authController,
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

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: OutlinedButton.icon(
        key: const Key('auth-login-button'),
        icon: const Icon(Icons.login, size: 18, color: Colors.white),
        label: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.login);
        },
      ),
    );
  }

  Widget _buildAuthAction(BuildContext context) {
    if (authController == null) {
      return _buildLoginButton(context);
    }

    return AnimatedBuilder(
      animation: authController!,
      builder: (context, _) {
        if (authController!.isAuthenticated) {
          final user = authController!.currentUser;
          return PopupMenuButton<String>(
            key: const Key('auth-user-menu'),
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, size: 24, color: Colors.white),
                if (user?.name != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      user!.name.split(' ').first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            tooltip: 'Conta: ${user?.name ?? ""}',
            onSelected: (value) async {
              if (value == 'logout') {
                await authController!.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sessão encerrada com sucesso.')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  user?.name ?? 'Usuário',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              if (user?.email != null)
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    user!.email,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Color(0xFFDC2626)),
                    SizedBox(width: 8),
                    Text('Sair', style: TextStyle(color: Color(0xFFDC2626))),
                  ],
                ),
              ),
            ],
          );
        }

        return _buildLoginButton(context);
      },
    );
  }

  List<Widget>? _buildEffectiveActions(BuildContext context) {
    final authAction = _buildAuthAction(context);
    return [
      if (actions != null) ...actions!,
      authAction,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 768;
    final effectiveActions = _buildEffectiveActions(context);

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
          actions: effectiveActions,
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
        actions: effectiveActions,
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
