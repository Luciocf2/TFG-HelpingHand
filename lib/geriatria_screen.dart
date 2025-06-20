import 'package:flutter/material.dart';
import 'widgets/especialidad_body.dart';
import 'app_localizations.dart';

class GeriatriaScreen extends StatelessWidget {
  final double textSize;

  GeriatriaScreen({this.textSize = 18.0});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final texts = AppLocalizations(languageCode);
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          texts.get('geriatria'),
          style: TextStyle(fontSize: textSize + 2),
        ),
      ),
      body: EspecialidadBody(
        especialidad: texts.get('geriatria'),
        controller: _controller,
        textSize: textSize,
        languageCode: languageCode,
      ),
    );
  }
}
