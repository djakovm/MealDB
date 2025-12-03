import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/categories_screen.dart';
import 'screens/meal_detail_screen.dart';
import 'services/favorites_store.dart';
import 'services/mealdb_api.dart';
import 'services/notification_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FavoritesStore.instance.init();

  await NotificationService.instance.init(
    onOpenRandom: () async {
      final meal = await MealDbApi().getRandomMeal();
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: meal.id)),
      );
    },
  );

  await NotificationService.instance.scheduleDailyReminder(hour: 20, minute: 0);

  runApp(const MealLabApp());
}

class MealLabApp extends StatelessWidget {
  const MealLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
