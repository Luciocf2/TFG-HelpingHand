import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:diacritic/diacritic.dart';
import 'cita.dart';
import 'app_localizations.dart';

class OtrosScreen extends StatefulWidget {
  @override
  _OtrosScreenState createState() => _OtrosScreenState();
}

class _OtrosScreenState extends State<OtrosScreen> {
  Map<String, List<Cita>> _citasPorEspecialidad = {};
  late FlutterTts flutterTts;
  bool lectorActivado = false;
  late String languageCode;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _loadCitas();
    await _verificarLectorYLeer();
  }

  Future<void> _verificarLectorYLeer() async {
    final prefs = await SharedPreferences.getInstance();
    lectorActivado = prefs.getBool('lectorActivado') ?? false;

    if (lectorActivado) {
      await flutterTts.setLanguage(languageCode == 'es' ? 'es-ES' : 'en-US');
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(
        languageCode == 'es'
            ? 'Aquí puedes ver tus citas agendadas organizadas por especialidad.'
            : 'Here you can see your scheduled appointments, grouped by specialty.',
      );
    }
  }

  Future<void> _loadCitas() async {
    final prefs = await SharedPreferences.getInstance();
    final citasString = prefs.getString('citas_list') ?? '[]';
    final decoded = jsonDecode(citasString);

    List<Cita> citas =
        decoded.map<Cita>((json) => Cita.fromJson(json)).toList();

    citas.sort((a, b) {
      DateTime fechaA = _parseFechaHora(a.fecha, a.hora);
      DateTime fechaB = _parseFechaHora(b.fecha, b.hora);
      return fechaA.compareTo(fechaB);
    });

    final Map<String, List<Cita>> agrupadas = {};
    for (var cita in citas) {
      final esp = cita.especialidad ?? 'Otros';
      if (!agrupadas.containsKey(esp)) {
        agrupadas[esp] = [];
      }
      agrupadas[esp]!.add(cita);
    }

    setState(() {
      _citasPorEspecialidad = agrupadas;
    });
  }

  DateTime _parseFechaHora(String fecha, String hora) {
    final partesFecha = fecha.split('/');
    final partesHora = hora.split(':');

    return DateTime(
      int.parse(partesFecha[2]),
      int.parse(partesFecha[1]),
      int.parse(partesFecha[0]),
      int.parse(partesHora[0]),
      int.parse(partesHora[1]),
    );
  }

  Future<void> _cancelarCita(String especialidad, int index) async {
    final prefs = await SharedPreferences.getInstance();
    _citasPorEspecialidad[especialidad]?.removeAt(index);

    final todasLasCitas =
        _citasPorEspecialidad.values.expand((e) => e).toList();
    final encoded = jsonEncode(
      todasLasCitas.map((cita) => cita.toJson()).toList(),
    );

    await prefs.setString('citas_list', encoded);
    setState(() {});

    final texts = AppLocalizations(languageCode);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(texts.get('cancelled'))));
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Localizations.localeOf(context).languageCode;
    final texts = AppLocalizations(languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(texts.get('scheduledAppointments'))),
      body:
          _citasPorEspecialidad.isEmpty
              ? Center(child: Text(texts.get('noAppointments')))
              : ListView(
                padding: const EdgeInsets.all(16),
                children:
                    _citasPorEspecialidad.entries.map((entry) {
                      final especialidad = entry.key;
                      final citas = entry.value;
                      final especialidadNormalizada = removeDiacritics(
                        especialidad.toLowerCase(),
                      );
                      final especialidadTraducida =
                          texts.get(especialidadNormalizada) ?? especialidad;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            especialidadTraducida,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...citas.asMap().entries.map((entryCita) {
                            final index = entryCita.key;
                            final cita = entryCita.value;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text('📅 ${cita.fecha} - ${cita.hora}'),
                                subtitle: Text(
                                  '${texts.get('reason')}: ${cita.motivo}',
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed:
                                      () => _cancelarCita(especialidad, index),
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
              ),
    );
  }
}
