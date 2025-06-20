# Helping Hand 🩺📱

**Autor:** Lucio Augusto Camacho Flores  
**Tutora:** Marlene Arangú Lobig  
**Grado:** 2º DAM (Desarrollo de Aplicaciones Multiplataforma)
**Centro:** The Core School

---

## 📌 Descripción

Helping Hand es una aplicación móvil multiplataforma desarrollada con **Flutter** que tiene como objetivo facilitar la gestión de citas médicas para personas mayores. Está diseñada pensando en la accesibilidad, simplicidad y autonomía del usuario, incluso sin conexión a internet.

---

## 🎯 Objetivos

- Eliminar barreras digitales en el acceso a servicios médicos.
- Ofrecer una interfaz clara y accesible.
- Permitir agendar y gestionar citas médicas fácilmente.
- Adaptarse a necesidades como lectura por voz, idioma o tamaño de texto.

---

## 🛠️ Tecnologías utilizadas

- **Flutter** + **Dart**
- **Plugins**:
  - `flutter_tts`: lectura de texto por voz.
  - `shared_preferences`: almacenamiento local.
  - `table_calendar`: calendario interactivo.

---

## 📱 Funcionalidades principales

- Pantalla de perfil editable (con foto y datos).
- Gestión de citas por especialidad médica.
- Sección de emergencias con llamada al 112.
- Preferencias de accesibilidad (idioma, modo oscuro, tamaño de texto).
- Lectura automática por voz.
- Menú lateral simple y accesible.

---

## 📂 Estructura del proyecto

| Archivo                        | Rol en la app                      | Contenido                                              |
|-------------------------------|------------------------------------|--------------------------------------------------------|
| `main.dart`                   | Entrada principal                   | Inicializa la app, configuraciones iniciales.          |
| `cita.dart`                   | Modelo de datos                     | Estructura lógica de una cita médica.                  |
| `especialidad_body.dart`      | Widget reutilizable                 | Muestra vista de citas por especialidad.               |
| `*.screen.dart`               | Interfaz/pantallas                  | Distintas secciones (citas, perfil, ayuda, etc.).      |
| `app_localizations.dart`      | Traducciones                        | Soporte multilenguaje dinámico.                        |
| `theme.dart`                  | Estilo visual                       | Define colores, fuentes y apariencia general.          |
| `splash_screen.dart`          | Pantalla de bienvenida              | Imagen de presentación inicial.                        |

---

## 🧪 Instalación

### Android
1. Copia el archivo `app-release.apk` a tu móvil.
2. Ábrelo desde el administrador de archivos.
3. Acepta permisos para instalar.

### Windows
1. Ejecuta el `.exe` generado desde la carpeta `/build/windows/runner/Release`.
2. No requiere instalación.

---

## 🔗 Enlaces

- [Repositorio en GitHub](https://github.com/Luciocf2/TFG-HelpingHand)

---

## 🧠 Conclusiones

Helping Hand es una prueba de concepto funcional y accesible, ideal como base para un desarrollo más profesional. Resuelve un problema social real desde la inclusión digital.
