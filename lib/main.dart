import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';

import 'splash_screen.dart';
import 'app_localizations.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Helping Hand');
    setWindowMinSize(const Size(800, 900));
    setWindowMaxSize(const Size(800, 900));
    setWindowFrame(const Rect.fromLTWH(200, 100, 1280, 900));
  }

  final prefs = await SharedPreferences.getInstance();
  final savedTextSize = prefs.getDouble('textSize') ?? 18.0;
  final savedDarkMode = prefs.getBool('isDarkMode') ?? false;
  final savedLanguageCode = prefs.getString('languageCode') ?? 'es';

  runApp(
    HelpingHandApp(
      initialTextSize: savedTextSize,
      initialDarkMode: savedDarkMode,
      initialLanguageCode: savedLanguageCode,
    ),
  );
}

class HelpingHandApp extends StatefulWidget {
  final double initialTextSize;
  final bool initialDarkMode;
  final String initialLanguageCode;

  HelpingHandApp({
    required this.initialTextSize,
    required this.initialDarkMode,
    required this.initialLanguageCode,
  });

  @override
  _HelpingHandAppState createState() => _HelpingHandAppState();
}

class _HelpingHandAppState extends State<HelpingHandApp> {
  late bool _isDarkMode;
  late String _languageCode;
  late double _textSize;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
    _textSize = widget.initialTextSize;
    _languageCode = widget.initialLanguageCode;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme(
      bodyLarge: TextStyle(fontSize: _textSize + 2),
      bodyMedium: TextStyle(fontSize: _textSize),
      titleLarge: TextStyle(
        fontSize: _textSize + 10,
        fontWeight: FontWeight.bold,
      ),
    );

    final lightTheme = AppTheme.lightTheme.copyWith(textTheme: textTheme);
    final darkTheme = AppTheme.darkTheme.copyWith(textTheme: textTheme);

    return MaterialApp(
      key: ValueKey(_textSize),
      title: 'HelpingHand',
      debugShowCheckedModeBanner: false,
      locale: Locale(_languageCode),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
        languageCode: _languageCode,
        onLanguageChanged: _changeLanguage,
        textSize: _textSize,
        onTextSizeChanged: _changeTextSize,
      ),
    );
  }

  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void _changeLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
    setState(() {
      _languageCode = code;
    });
  }

  void _changeTextSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', size);
    setState(() {
      _textSize = size;
    });
  }
}
