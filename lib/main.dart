import 'package:flutter/material.dart';
import 'screens/categories_screen.dart';

void main() {
  runApp(const MealLabApp());
}

class MealLabApp extends StatelessWidget {
  const MealLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealLab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D32),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: const CategoriesScreen(),
    );
  }
}
