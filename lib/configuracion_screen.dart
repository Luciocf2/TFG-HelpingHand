import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'especialidades_screen.dart';
import 'app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ConfiguracionScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<double> onTextSizeChanged;
  final double textSize;

  ConfiguracionScreen({
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onTextSizeChanged,
    required this.textSize,
  });

  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  late bool _modoOscuro;
  late String _idiomaSeleccionado;
  bool _lectorActivado = false;
  late double _tamanoTexto;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    _modoOscuro = widget.isDarkMode;
    _idiomaSeleccionado = widget.languageCode;
    _tamanoTexto = widget.textSize;
    flutterTts = FlutterTts();
    _loadLectorEstado();
  }

  Future<void> _loadLectorEstado() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lectorActivado = prefs.getBool('lectorActivado') ?? false;
    });
  }

  Future<void> leerTexto(String texto) async {
    await flutterTts.setLanguage(
      _idiomaSeleccionado == 'es' ? "es-ES" : "en-US",
    );
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(texto);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations(_idiomaSeleccionado);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textStyle = theme.textTheme.bodyLarge?.copyWith(color: textColor);
    final subTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: textColor.withOpacity(0.7),
    );

    return Scaffold(
      appBar: AppBar(title: Text(texts.get('settings'))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: Text(texts.get('darkMode'), style: textStyle),
              value: _modoOscuro,
              onChanged: (bool value) {
                setState(() {
                  _modoOscuro = value;
                });
                widget.onThemeChanged(value);
              },
            ),
            const SizedBox(height: 20),
            Text('${texts.get('language')}:', style: textStyle),
            DropdownButton<String>(
              value: _idiomaSeleccionado,
              dropdownColor: theme.cardColor,
              style: textStyle,
              items: [
                DropdownMenuItem(
                  value: 'es',
                  child: Text('Español', style: textStyle),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English', style: textStyle),
                ),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _idiomaSeleccionado = value;
                  });
                  widget.onLanguageChanged(value);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EspecialidadesScreen(
                            languageCode: value,
                            textSize: _tamanoTexto,
                            onOpenConfiguracion: (context) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ConfiguracionScreen(
                                        isDarkMode: _modoOscuro,
                                        onThemeChanged: widget.onThemeChanged,
                                        languageCode: value,
                                        onLanguageChanged:
                                            widget.onLanguageChanged,
                                        onTextSizeChanged:
                                            widget.onTextSizeChanged,
                                        textSize: _tamanoTexto,
                                      ),
                                ),
                              );
                            },
                          ),
                    ),
                  );
                }
              },
            ),
            const Divider(height: 40),
            Text(texts.get('textSize'), style: textStyle),
            Slider(
              value: _tamanoTexto,
              min: 12,
              max: 24,
              divisions: 6,
              label: '${_tamanoTexto.toInt()} pt',
              onChanged: (value) async {
                setState(() {
                  _tamanoTexto = value;
                });
                widget.onTextSizeChanged(value);

                final prefs = await SharedPreferences.getInstance();
                await prefs.setDouble('textSize', value);
              },
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: Text(texts.get('screenReader'), style: textStyle),
              subtitle: Text(
                texts.get('screenReaderDesc'),
                style: subTextStyle,
              ),
              value: _lectorActivado,
              onChanged: (value) async {
                setState(() {
                  _lectorActivado = value;
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('lectorActivado', value);
                if (value) await leerTexto(texts.get('screenReaderDesc'));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up),
              label: Text("Probar voz", style: textStyle),
              onPressed: () {
                leerTexto(
                  _idiomaSeleccionado == 'es'
                      ? 'Esta es una prueba de lectura en voz alta.'
                      : 'This is a voice reading test.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
