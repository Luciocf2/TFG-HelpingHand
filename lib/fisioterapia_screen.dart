import 'package:flutter/material.dart';
import 'widgets/especialidad_body.dart';
import 'app_localizations.dart';

class FisioterapiaScreen extends StatelessWidget {
  final double textSize;

  FisioterapiaScreen({this.textSize = 18.0});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final texts = AppLocalizations(languageCode);
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          texts.get('fisioterapia'),
          style: TextStyle(fontSize: textSize + 2),
        ),
      ),
      body: EspecialidadBody(
        especialidad: texts.get('fisioterapia'),
        controller: _controller,
        textSize: textSize,
        languageCode: languageCode,
      ),
    );
  }
}
