import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

class AyudaScreen extends StatefulWidget {
  final double textSize;

  AyudaScreen({required this.textSize});

  @override
  State<AyudaScreen> createState() => _AyudaScreenState();
}

class _AyudaScreenState extends State<AyudaScreen> {
  late FlutterTts flutterTts;
  bool lectorActivado = false;
  late String languageCode;
  late AppLocalizations texts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTTS();
  }

  Future<void> _initTTS() async {
    final prefs = await SharedPreferences.getInstance();
    lectorActivado = prefs.getBool('lectorActivado') ?? false;

    languageCode = Localizations.localeOf(context).languageCode;
    texts = AppLocalizations(languageCode);

    if (lectorActivado) {
      await flutterTts.setLanguage(languageCode == 'es' ? 'es-ES' : 'en-US');
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(
        languageCode == 'es'
            ? "Estás en la sección de ayuda. Aquí encontrarás preguntas frecuentes y respuestas."
            : "You are in the help section. Here you'll find frequently asked questions and answers.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Localizations.localeOf(context).languageCode;
    texts = AppLocalizations(languageCode);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          texts.get('help'),
          style: TextStyle(fontSize: widget.textSize + 2, color: textColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              texts.get('faq'),
              style: TextStyle(
                fontSize: widget.textSize + 4,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildPregunta(
              texts.get('howUse'),
              texts.get('howUseDesc'),
              textColor,
            ),
            _buildPregunta(
              texts.get('howBook'),
              texts.get('howBookDesc'),
              textColor,
            ),
            _buildPregunta(
              texts.get('howCancel'),
              texts.get('howCancelDesc'),
              textColor,
            ),
            _buildPregunta(
              texts.get('contactSupport'),
              texts.get('contactSupportDesc'),
              textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregunta(String pregunta, String respuesta, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $pregunta',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: widget.textSize,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            respuesta,
            style: TextStyle(
              fontSize: widget.textSize - 1,
              color: textColor.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}
