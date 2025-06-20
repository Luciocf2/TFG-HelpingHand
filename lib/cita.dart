class Cita {
  final String fecha;
  final String hora;
  final String motivo;
  final String especialidad;

  Cita({
    required this.fecha,
    required this.hora,
    required this.motivo,
    required this.especialidad,
  });

  Map<String, dynamic> toJson() => {
    'fecha': fecha,
    'hora': hora,
    'motivo': motivo,
    'especialidad': especialidad,
  };

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      fecha: json['fecha'],
      hora: json['hora'],
      motivo: json['motivo'],
      especialidad: json['especialidad'],
    );
  }
}
