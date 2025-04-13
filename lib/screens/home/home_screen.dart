import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_management_app/config/constants.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;
  
  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/medicines')) {
      return 1;
    }
    if (location.startsWith('/records')) {
      return 2;
    }
    return 0; // Default to patients tab
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/medicines');
        break;
      case 2:
        context.go('/records');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'المرضى',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'الأدوية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'السجلات',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
