# Asistente Virtual con Rasa, TTS y STT

## Descripción
Este proyecto es un asistente virtual desarrollado en Flutter que interactúa con un servidor Rasa para procesar las solicitudes de los usuarios. El asistente utiliza reconocimiento de voz (STT - Speech-to-Text) para captar comandos y síntesis de voz (TTS - Text-to-Speech) para responder de manera hablada.

## Características
- Interfaz conversacional con chat visual.
- Integración con Rasa para procesamiento del lenguaje natural.
- Soporte para reconocimiento de voz (STT) mediante `speech_to_text`.
- Soporte para síntesis de voz (TTS) con `flutter_tts`.
- Soporte para múltiples idiomas (español e inglés).
- Persistencia de preferencias de idioma con `shared_preferences`.
- Manejo de errores y notificaciones al usuario.

## Tecnologías utilizadas
- **Flutter**: Framework principal para la interfaz de usuario.
- **Dart**: Lenguaje de programación para el desarrollo de la app.
- **Rasa**: Framework de procesamiento de lenguaje natural (NLP).
- **HTTP**: Comunicación con el servidor Rasa.
- **flutter_tts**: Biblioteca para síntesis de voz.
- **speech_to_text**: Biblioteca para reconocimiento de voz.
- **shared_preferences**: Para almacenar preferencias del usuario.

## Instalación y Configuración

### Requisitos previos
- Tener Flutter instalado en el sistema.
- Tener un servidor Rasa configurado y ejecutándose.

### Configuración de Rasa
1. Instalar Rasa:
   ```sh
   pip install rasa
   ```
2. Entrenar el modelo Rasa con:
   ```sh
   rasa train
   ```
3. Ejecutar el servidor Rasa:
   ```sh
   rasa run --enable-api
   ```

### Configuración de Flutter
1. Clonar el repositorio:
   ```sh
   git clone <URL_DEL_REPOSITORIO>
   cd <NOMBRE_DEL_PROYECTO>
   ```
2. Instalar dependencias:
   ```sh
   flutter pub get
   ```
3. Ejecutar la aplicación:
   ```sh
   flutter run
   ```

## Uso
1. El usuario puede escribir mensajes o utilizar el micrófono para hablar con el asistente.
2. La app enviará el mensaje a Rasa y recibirá una respuesta.
3. La respuesta se mostrará en la interfaz y se leerá en voz alta usando TTS.
4. Se puede cambiar el idioma en el menú de la aplicación.

## Configuración del Servidor Rasa
El servidor Rasa se configura en el archivo `domain.yml`, donde se definen los intents y respuestas predefinidas.

Ejemplo de intents en `domain.yml`:
```yaml
intents:
  - saludar
  - despedir
  - afirmar
  - negar
responses:
  utter_saludar:
    - text: "¡Hola! ¿Cómo estás?"
  utter_despedir:
    - text: "¡Hasta luego!"
```

## Contribución
Si deseas contribuir a este proyecto, puedes:
1. Hacer un fork del repositorio.
2. Crear una nueva rama (`git checkout -b nueva-funcionalidad`).
3. Hacer cambios y confirmarlos (`git commit -m 'Añadir nueva funcionalidad'`).
4. Subir la rama (`git push origin nueva-funcionalidad`).
5. Crear un Pull Request.

## Licencia
Este proyecto se distribuye bajo la licencia MIT. ¡Siéntete libre de usarlo y mejorarlo!

## Contacto
Para cualquier duda o sugerencia, contáctame en [tu correo o redes sociales].

