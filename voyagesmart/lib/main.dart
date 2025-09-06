import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/bus_search_screen.dart';
import 'screens/hotel_screen.dart';
import 'screens/taxi_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const VoyageSmartApp());
}

class VoyageSmartApp extends StatelessWidget {
  const VoyageSmartApp({super.key});

  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFA5D6A7);
  static const Color backgroundColor = Color(0xFFF9FFF9);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voyage Smart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryGreen,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryGreen,
          secondary: lightGreen,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: primaryGreen),
          ),
          prefixIconColor: primaryGreen,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  // ❗ Ajouter ici le userId courant pour l'utiliser dans TaxiScreen
  final String currentUserId = '123'; // 🔑 Remplace par l'ID réel de l'utilisateur

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      const HomeScreen(userName: 'Fahaddoul YOUSSOUFA'),
      const BusSearchScreen(),
      TaxiScreen(userId: currentUserId), // ✅ On fournit le userId obligatoire
      const HotelSearchScreen(),
      const ProfileScreen(userName: 'Fahaddoul YOUSSOUFA'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: VoyageSmartApp.primaryGreen,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Bus'),
          BottomNavigationBarItem(icon: Icon(Icons.local_taxi), label: 'Taxi'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel), label: 'Hôtel'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
