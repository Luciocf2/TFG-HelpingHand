import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'geriatria_screen.dart';
import 'enfermeria_screen.dart';
import 'cardiologia_screen.dart';
import 'fisioterapia_screen.dart';
import 'emergencia_screen.dart';
import 'perfil_screen.dart';
import 'app_localizations.dart';
import 'otros_screen.dart';
import 'ayuda_screen.dart';

class EspecialidadesScreen extends StatefulWidget {
  final void Function(BuildContext context) onOpenConfiguracion;
  final String languageCode;
  final double textSize;

  EspecialidadesScreen({
    required this.onOpenConfiguracion,
    required this.languageCode,
    required this.textSize,
  });

  @override
  State<EspecialidadesScreen> createState() => _EspecialidadesScreenState();
}

class _EspecialidadesScreenState extends State<EspecialidadesScreen> {
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _leerPantalla();
  }

  Future<void> _leerPantalla() async {
    final prefs = await SharedPreferences.getInstance();
    final lectorActivado = prefs.getBool('lectorActivado') ?? false;

    if (lectorActivado) {
      await flutterTts.setLanguage(
        widget.languageCode == 'es' ? 'es-ES' : 'en-US',
      );
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(
        widget.languageCode == 'es'
            ? 'Estás en el menú principal. Selecciona una especialidad o accede a otras opciones.'
            : 'You are on the main menu. Select a specialty or access other options.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations(widget.languageCode);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primary),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/helping_hand_logo.jpg',
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      texts.get('menu'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.textSize + 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                texts.get('profile'),
                style: TextStyle(fontSize: widget.textSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PerfilScreen(languageCode: widget.languageCode),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                texts.get('settings'),
                style: TextStyle(fontSize: widget.textSize),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onOpenConfiguracion(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(
                texts.get('help'),
                style: TextStyle(fontSize: widget.textSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AyudaScreen(textSize: widget.textSize),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/helping_hand_logo.jpg',
              width: 60,
              height: 60,
            ),
            SizedBox(width: 16),
            Text(
              texts.get('title'),
              style: TextStyle(
                fontSize: widget.textSize + 6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
        child: Column(
          children: [
            _buildEspecialidadTile(
              context,
              Icons.elderly,
              texts.get('geriatria'),
              GeriatriaScreen(textSize: widget.textSize),
            ),
            _buildEspecialidadTile(
              context,
              Icons.add,
              texts.get('enfermeria'),
              EnfermeriaScreen(textSize: widget.textSize),
            ),
            _buildEspecialidadTile(
              context,
              Icons.monitor_heart,
              texts.get('cardiologia'),
              CardiologiaScreen(textSize: widget.textSize),
            ),
            _buildEspecialidadTile(
              context,
              Icons.accessibility_new,
              texts.get('fisioterapia'),
              FisioterapiaScreen(textSize: widget.textSize),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OtrosScreen()),
                );
              },
              icon: Icon(Icons.add),
              label: Text(
                texts.get('others'),
                style: TextStyle(fontSize: widget.textSize),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            EmergenciaScreen(languageCode: widget.languageCode),
                  ),
                );
              },
              icon: Icon(Icons.favorite, color: colorScheme.error),
              label: Text(
                texts.get('emergency'),
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: widget.textSize,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                side: BorderSide(color: colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEspecialidadTile(
    BuildContext context,
    IconData icon,
    String label,
    Widget screen,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            ),
        icon: Icon(icon, color: textColor),
        label: Text(
          '- $label',
          style: TextStyle(color: textColor, fontSize: widget.textSize),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          minimumSize: Size(double.infinity, 50),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
