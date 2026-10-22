import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../features/weather/presentation/screens/splash_screen.dart';

/// Root application widget. Kept intentionally thin — only wires up theme and
/// the initial route. Business logic lives in Riverpod providers.
class WeatherlyApp extends StatelessWidget {
  const WeatherlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weatherly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
