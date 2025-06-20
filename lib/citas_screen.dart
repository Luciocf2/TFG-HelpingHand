import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'app_localizations.dart';

class CitasScreen extends StatefulWidget {
  @override
  _CitasScreenState createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final List<String> citas = [
    'Consulta telefónica - 25 abril 10:00h',
    'Revisión mensual - 2 mayo 13:30h',
    'Vacunación - 9 mayo 09:15h',
  ];

  late FlutterTts flutterTts;
  late String languageCode;
  late AppLocalizations texts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _leerPantalla();
    });
  }

  Future<void> _leerPantalla() async {
    final prefs = await SharedPreferences.getInstance();
    final lectorActivado = prefs.getBool('lectorActivado') ?? false;

    if (!lectorActivado) return;

    final locale = Localizations.localeOf(context).languageCode;
    languageCode = locale;
    texts = AppLocalizations(languageCode);

    await flutterTts.setLanguage(languageCode == 'es' ? 'es-ES' : 'en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(
      languageCode == 'es'
          ? 'Estas son tus próximas citas'
          : 'These are your upcoming appointments',
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final texts = AppLocalizations(locale);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textStyle = theme.textTheme.bodyLarge;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          texts.get('scheduledAppointments'),
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: citas.length,
        itemBuilder: (context, index) {
          return Card(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                citas[index],
                style: textStyle?.copyWith(fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }
}
