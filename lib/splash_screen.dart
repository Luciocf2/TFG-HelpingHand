import 'package:flutter/material.dart';
import 'especialidades_screen.dart';
import 'configuracion_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  final String languageCode;
  final Function(String) onLanguageChanged;
  final double textSize;
  final Function(double) onTextSizeChanged;

  SplashScreen({
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.textSize,
    required this.onTextSizeChanged,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => EspecialidadesScreen(
                languageCode: widget.languageCode,
                textSize: widget.textSize,
                onOpenConfiguracion: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ConfiguracionScreen(
                            isDarkMode: widget.isDarkMode,
                            onThemeChanged: widget.onThemeChanged,
                            languageCode: widget.languageCode,
                            onLanguageChanged: widget.onLanguageChanged,
                            textSize: widget.textSize,
                            onTextSizeChanged: widget.onTextSizeChanged,
                          ),
                    ),
                  );
                },
              ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/helping_hand_logo.jpg'),
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
