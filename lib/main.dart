import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'screens/template_pool_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/colors.dart';
import 'widgets/bottom_nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: navyBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AnnounceApp());
}

class AnnounceApp extends StatelessWidget {
  const AnnounceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Announce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navyBg,
        colorScheme: const ColorScheme.dark(
          primary: accentBlue,
          surface: navyCard,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: navyCard,
          contentTextStyle: TextStyle(color: textPrimary),
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    TemplatePoolScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyBg,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
