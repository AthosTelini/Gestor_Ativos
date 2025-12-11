import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../styles/app_theme.dart';
import 'dashboard_screen.dart';
import 'planning_screen.dart';
import 'about_screen.dart';
import '../widgets/add_transaction_modal.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1;

  final List<Widget> _screens = [
    const PlanningScreen(),
    const DashboardScreen(),
    const AboutScreen(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const AddTransactionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Navegação por Swipe
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _screens,
          ),

          // 2. Menu Circular
          CircularMenu(
            alignment: const Alignment(0.0, 0.85),

            // Ângulos do leque
            startingAngleInRadian: 1.1 * pi,
            endingAngleInRadian: 1.9 * pi,

            // --- PERSONALIZAÇÃO DO BOTÃO CENTRAL ---
            // Cor de fundo do botão (Agora Azul Royal, igual ao tema)
            toggleButtonColor: AppTheme.royalBlue,
            toggleButtonIconColor: Colors.white,
            toggleButtonSize: 45.0,

            // Adiciona Sombra Neon no botão central
            toggleButtonBoxShadow: [
              BoxShadow(
                color: AppTheme.cyanNeon.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],

            radius: 130,

            items: [
              // Planejamento
              CircularMenuItem(
                icon: Icons.show_chart,
                color: AppTheme.royalBlue,
                iconColor: Colors.white,
                onTap: () => _navigateToPage(0),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
              ),

              // Adicionar (+) - Destaque Neon
              CircularMenuItem(
                icon: Icons.add,
                color: AppTheme.cyanNeon, // Esse eu deixei Neon para chamar atenção
                iconColor: Colors.white,
                onTap: _openAddModal,
                boxShadow: [BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.4), blurRadius: 10)],
              ),

              // Home
              CircularMenuItem(
                icon: Icons.home,
                color: AppTheme.royalBlue,
                iconColor: Colors.white,
                onTap: () => _navigateToPage(1),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
              ),

              // Sobre
              CircularMenuItem(
                icon: Icons.info_outline,
                color: AppTheme.royalBlue,
                iconColor: Colors.white,
                onTap: () => _navigateToPage(2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
              ),

              // Sair
              CircularMenuItem(
                icon: Icons.close,
                color: Colors.redAccent,
                iconColor: Colors.white,
                onTap: () => SystemNavigator.pop(),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 10)],
              ),
            ],
          ),
        ],
      ),
    );
  }
}