import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import '../cita.dart';
import '../app_localizations.dart';

class EspecialidadBody extends StatefulWidget {
  final String especialidad;
  final TextEditingController controller;
  final double textSize;
  final String languageCode;

  EspecialidadBody({
    required this.especialidad,
    required this.controller,
    required this.languageCode,
    this.textSize = 18.0,
  });

  @override
  _EspecialidadBodyState createState() => _EspecialidadBodyState();
}

class _EspecialidadBodyState extends State<EspecialidadBody> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? _selectedHour;
  List<String> _horasDisponibles = [];
  Map<DateTime, List<Cita>> _eventos = {};

  late FlutterTts flutterTts;
  bool lectorActivado = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _loadLector();
    _generarHoras();
    _cargarEventos();
  }

  Future<void> _loadLector() async {
    final prefs = await SharedPreferences.getInstance();
    lectorActivado = prefs.getBool('lectorActivado') ?? false;

    if (lectorActivado) {
      await flutterTts.setLanguage(
        widget.languageCode == 'es' ? 'es-ES' : 'en-US',
      );
      await flutterTts.speak(
        widget.languageCode == 'es'
            ? "Has entrado a ${widget.especialidad}"
            : "You entered ${widget.especialidad}",
      );
    }
  }

  void _generarHoras() {
    final inicio = TimeOfDay(hour: 8, minute: 0);
    final fin = TimeOfDay(hour: 20, minute: 0);
    List<String> lista = [];
    TimeOfDay actual = inicio;

    while (actual.hour < fin.hour ||
        (actual.hour == fin.hour && actual.minute < fin.minute)) {
      final horaTexto =
          '${actual.hour.toString().padLeft(2, '0')}:${actual.minute.toString().padLeft(2, '0')}';
      lista.add(horaTexto);

      int siguienteMinuto = actual.minute + 15;
      int siguienteHora = actual.hour + (siguienteMinuto ~/ 60);
      siguienteMinuto = siguienteMinuto % 60;
      actual = TimeOfDay(hour: siguienteHora, minute: siguienteMinuto);
    }

    setState(() {
      _horasDisponibles = lista;
    });
  }

  Future<void> _cargarEventos() async {
    final prefs = await SharedPreferences.getInstance();
    final citasString = prefs.getString('citas_list') ?? '[]';
    final List decoded = jsonDecode(citasString);

    final eventos = <DateTime, List<Cita>>{};
    for (var item in decoded) {
      final cita = Cita.fromJson(item);
      if (cita.especialidad == widget.especialidad) {
        final partesFecha = cita.fecha.split('/');
        final fecha = DateTime(
          int.parse(partesFecha[2]),
          int.parse(partesFecha[1]),
          int.parse(partesFecha[0]),
        );
        eventos.putIfAbsent(fecha, () => []).add(cita);
      }
    }

    setState(() {
      _eventos = eventos;
    });
  }

  List<Cita> _getEventosDelDia(DateTime day) {
    return _eventos[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _guardarCita() async {
    if (_selectedDay == null ||
        widget.controller.text.isEmpty ||
        _selectedHour == null)
      return;

    final nuevaCita = Cita(
      fecha:
          '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
      hora: _selectedHour!,
      motivo: widget.controller.text,
      especialidad: widget.especialidad,
    );

    final prefs = await SharedPreferences.getInstance();
    final citasString = prefs.getString('citas_list') ?? '[]';
    final List decoded = jsonDecode(citasString);
    decoded.add(nuevaCita.toJson());
    await prefs.setString('citas_list', jsonEncode(decoded));

    widget.controller.clear();
    setState(() {
      _selectedHour = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Cita guardada')));
    await _cargarEventos();
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations(widget.languageCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            widget.especialidad.toUpperCase(),
            style: TextStyle(
              fontSize: widget.textSize + 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            texts.get('consultInstruction'),
            style: TextStyle(fontSize: widget.textSize, color: textColor),
          ),
          const SizedBox(height: 20),
          TableCalendar(
            locale: widget.languageCode,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            enabledDayPredicate: (day) {
              final today = DateTime.now();
              return day.isAfter(today.subtract(const Duration(days: 1))) &&
                  day.weekday != DateTime.saturday &&
                  day.weekday != DateTime.sunday;
            },
            eventLoader: _getEventosDelDia,
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(
                fontSize: widget.textSize,
                color: textColor,
              ),
              weekendTextStyle: TextStyle(
                fontSize: widget.textSize,
                color: Colors.redAccent,
              ),
              todayTextStyle: TextStyle(
                fontSize: widget.textSize,
                color: Colors.white,
              ),
              selectedTextStyle: TextStyle(
                fontSize: widget.textSize,
                color: Colors.white,
              ),
              todayDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
            daysOfWeekHeight: 40,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: widget.textSize - 2,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              weekendStyle: TextStyle(
                fontSize: widget.textSize - 2,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(
                fontSize: widget.textSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              formatButtonTextStyle: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              formatButtonDecoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: texts.get('hour'),
              labelStyle: TextStyle(
                fontSize: widget.textSize,
                color: textColor,
              ),
            ),
            dropdownColor: backgroundColor,
            value: _selectedHour,
            items:
                _horasDisponibles
                    .map(
                      (hora) => DropdownMenuItem(
                        value: hora,
                        child: Text(
                          hora,
                          style: TextStyle(
                            fontSize: widget.textSize,
                            color: textColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                _selectedHour = value;
              });
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: widget.controller,
            maxLines: 5,
            style: TextStyle(fontSize: widget.textSize, color: textColor),
            decoration: InputDecoration(
              hintText: texts.get('formHint'),
              hintStyle: TextStyle(
                fontSize: widget.textSize,
                color: textColor.withOpacity(0.6),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _guardarCita,
            child: Text(
              texts.get('formSend'),
              style: TextStyle(fontSize: widget.textSize),
            ),
          ),
        ],
      ),
    );
  }
}
