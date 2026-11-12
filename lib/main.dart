import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/database/database_helper.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/psalm_provider.dart';
import 'presentation/providers/memorization_provider.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred portrait orientation for serene reading experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pre-initialize local database & authentic Psalm content
  await DatabaseHelper.instance.init();

  runApp(const MyMezmureDawitApp());
}

class MyMezmureDawitApp extends StatelessWidget {
  const MyMezmureDawitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PsalmProvider()),
        ChangeNotifierProvider(create: (_) => MemorizationProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'my መዝሙረ ዳዊት',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(fontScale: settings.fontScale),
            darkTheme: AppTheme.darkTheme(fontScale: settings.fontScale),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
