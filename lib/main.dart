// MoneyBuddy
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/services/pin_service.dart';
import 'features/notifications/notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled:  true,
    cacheSizeBytes:      Settings.CACHE_SIZE_UNLIMITED,
  );

  await NotificationService.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:          Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Check if PIN lock is enabled
  final pinEnabled = await PinService.isPinEnabled();

  runApp(MoneyBuddyApp(showPinLock: pinEnabled));
}

class MoneyBuddyApp extends StatelessWidget {
  final bool showPinLock;
  const MoneyBuddyApp({super.key, required this.showPinLock});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title:                    'MoneyBuddy',
      debugShowCheckedModeBanner: false,
      theme:                    AppTheme.light,
      defaultTransition:        Transition.rightToLeft,
      transitionDuration:       const Duration(milliseconds: 280),
      initialRoute:             showPinLock
          ? AppRoutes.pinLock
          : AppRoutes.splash,
      getPages:                 AppPages.pages,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      ),
    );
  }
}