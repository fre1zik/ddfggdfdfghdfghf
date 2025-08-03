import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/telegram_provider.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const TelegramClientApp());
}

class TelegramClientApp extends StatelessWidget {
  const TelegramClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TelegramProvider(),
      child: MaterialApp(
        title: 'Telegram Client',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF0088cc),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0088cc),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0088cc),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0088cc),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0088cc)),
            ),
          ),
        ),
        home: const AuthScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
