import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'app_localizations.dart';

class PerfilScreen extends StatefulWidget {
  final String languageCode;

  const PerfilScreen({super.key, required this.languageCode});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  late FlutterTts flutterTts;
  bool lectorActivado = false;
  File? _imagenPerfil;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _initLector();
    _loadImagenPerfil();
  }

  Future<void> _initLector() async {
    flutterTts = FlutterTts();
    final prefs = await SharedPreferences.getInstance();
    lectorActivado = prefs.getBool('lectorActivado') ?? false;

    if (lectorActivado) {
      await flutterTts.setLanguage(
        widget.languageCode == 'es' ? 'es-ES' : 'en-US',
      );
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(
        widget.languageCode == 'es'
            ? 'Has accedido a tu perfil personal.'
            : 'You have accessed your personal profile.',
      );
    }
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('profile_name') ?? '';
      _cardController.text = prefs.getString('profile_card') ?? '';
      _birthController.text = prefs.getString('profile_birth') ?? '';
      _phoneController.text = prefs.getString('profile_phone') ?? '';
      _addressController.text = prefs.getString('profile_address') ?? '';
    });
  }

  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameController.text);
    await prefs.setString('profile_card', _cardController.text);
    await prefs.setString('profile_birth', _birthController.text);
    await prefs.setString('profile_phone', _phoneController.text);
    await prefs.setString('profile_address', _addressController.text);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('✅ Guardado')));
  }

  Future<void> _loadImagenPerfil() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/perfil.jpg');
    if (await file.exists()) {
      setState(() {
        _imagenPerfil = file;
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      final dir = await getApplicationDocumentsDirectory();
      final fileDestino = File('${dir.path}/perfil.jpg');
      await File(imagen.path).copy(fileDestino.path);

      setState(() {
        _imagenPerfil = fileDestino;
      });
    }
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.camera);

    if (imagen != null) {
      final dir = await getApplicationDocumentsDirectory();
      final fileDestino = File('${dir.path}/perfil.jpg');
      await File(imagen.path).copy(fileDestino.path);

      setState(() {
        _imagenPerfil = fileDestino;
      });
    }
  }

  Future<void> _eliminarImagen() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/perfil.jpg');
    if (await file.exists()) {
      await file.delete();
    }
    setState(() {
      _imagenPerfil = null;
    });
  }

  Widget _buildCustomField(
    IconData icon,
    String hint,
    TextEditingController controller,
    String? Function(String?) validator,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              icon: Icon(icon, color: colorScheme.primary),
              hintText: hint,
              hintStyle: TextStyle(
                color: isDark ? Colors.white : colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations(widget.languageCode);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(texts.get('profile'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _seleccionarImagen,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _imagenPerfil != null
                          ? FileImage(_imagenPerfil!)
                          : AssetImage('assets/images/abuelita.jpg')
                              as ImageProvider,
                ),
              ),
              const SizedBox(height: 10),
              Text("Toca para cambiar foto", style: TextStyle(fontSize: 14)),
              TextButton(
                onPressed: _eliminarImagen,
                child: Text(texts.get('resetPhoto')),
              ),
              if (Platform.isAndroid || Platform.isIOS)
                TextButton.icon(
                  onPressed: _tomarFoto,
                  icon: Icon(Icons.camera_alt),
                  label: Text("Tomar foto con cámara"),
                ),
              const SizedBox(height: 30),
              _buildCustomField(
                Icons.person,
                texts.get('name'),
                _nameController,
                (value) {
                  return value == null || value.isEmpty
                      ? texts.get('requiredField')
                      : null;
                },
              ),
              _buildCustomField(
                Icons.credit_card,
                texts.get('cardNumber'),
                _cardController,
                (value) {
                  return value == null || value.isEmpty
                      ? texts.get('requiredField')
                      : null;
                },
              ),
              _buildCustomField(
                Icons.cake,
                texts.get('birthDate'),
                _birthController,
                (value) {
                  return !RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value ?? '')
                      ? texts.get('invalidDate')
                      : null;
                },
              ),
              _buildCustomField(
                Icons.phone,
                texts.get('phone'),
                _phoneController,
                (value) {
                  return value == null || value.length != 9
                      ? texts.get('invalidPhone')
                      : null;
                },
              ),
              _buildCustomField(
                Icons.location_on,
                texts.get('address'),
                _addressController,
                (value) {
                  return value == null || value.isEmpty
                      ? texts.get('requiredField')
                      : null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saveProfileData,
                icon: const Icon(Icons.save),
                label: Text(texts.get('save')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
