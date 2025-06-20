import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

class EmergenciaScreen extends StatefulWidget {
  final String languageCode;

  const EmergenciaScreen({Key? key, required this.languageCode})
    : super(key: key);

  @override
  State<EmergenciaScreen> createState() => _EmergenciaScreenState();
}

class _EmergenciaScreenState extends State<EmergenciaScreen> {
  late FlutterTts flutterTts;
  bool lectorActivado = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _leerSiNecesario();
  }

  Future<void> _leerSiNecesario() async {
    final prefs = await SharedPreferences.getInstance();
    lectorActivado = prefs.getBool('lectorActivado') ?? false;

    if (lectorActivado) {
      await flutterTts.setLanguage(
        widget.languageCode == 'es' ? 'es-ES' : 'en-US',
      );
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(
        widget.languageCode == 'es'
            ? "Has accedido a la sección de emergencias. Si tienes una urgencia médica, llama al 112."
            : "You’ve entered the emergency section. If you have a medical emergency, call 112.",
      );
    }
  }

  void _llamarUrgencias() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'No se pudo lanzar $phoneUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations(widget.languageCode);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(title: Text(texts.get('emergencyTitle'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning, size: 100, color: Colors.redAccent),
              const SizedBox(height: 20),
              Text(
                texts.get('emergencyQuestion'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _llamarUrgencias,
                icon: const Icon(Icons.call),
                label: Text(
                  texts.get('call112'),
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
