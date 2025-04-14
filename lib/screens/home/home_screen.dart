import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_management_app/config/constants.dart';
import 'package:patient_management_app/screens/medicines/medicines_screen.dart';
import 'package:patient_management_app/screens/records/records_screen.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Track the current index
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index); // Jump to the selected page
    switch (index) {
      case 0:
        context.pushReplacement('/');
        break;
      case 1:
        context.pushReplacement('/medicines');
        break;
      case 2:
        context.pushReplacement('/records');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final int selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          widget.child,
          const MedicinesScreen(),
          const RecordsScreen(),
        ],
      ),
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
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
