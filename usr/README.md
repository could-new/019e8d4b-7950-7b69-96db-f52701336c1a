# PCB Router - Flutter

Una aplicación de demostración interactiva construida con Flutter que simula el entorno de diseño de una Placa de Circuito Impreso (PCB). La aplicación proporciona un lienzo interactivo con cuadrícula donde los usuarios pueden colocar componentes (pads) y trazar pistas (rutas) de conexión en diferentes capas, al estilo de las herramientas EDA (Electronic Design Automation).

## Características

- **Lienzo con Cuadrícula Interactivo:** Área de dibujo infinita que permite desplazamiento panorámico y zoom. Ajuste magnético (snap-to-grid) para facilitar la alineación precisa.
- **Herramientas de Diseño:**
  - **Colocar Pads:** Agrega puntos de conexión "through-hole" (plataforma con orificio central).
  - **Trazar Rutas:** Dibuja pistas eléctricas continuas haciendo clic de un punto a otro. Haz clic derecho para finalizar una línea en curso.
  - **Seleccionar:** Cambia al modo de navegación libre (panorámica) para explorar el lienzo sin dibujar accidentalmente.
- **Soporte Multi-Capa:**
  - **Top Layer (Capa Superior):** Las pistas se dibujan en color rojo, simulando el estándar de la industria.
  - **Bottom Layer (Capa Inferior):** Las pistas se dibujan en color azul.
  - El dibujado prioriza visualmente la capa activa mostrándola por encima de las capas inactivas.
- **Estilo Visual EDA:** Tema de interfaz de usuario oscuro, diseñado para reducir la fatiga visual, típico en software de ingeniería (como KiCad o Altium).

## Plataformas Soportadas

Gracias al framework Flutter, esta aplicación está diseñada para funcionar de forma nativa en:
- Navegadores Web (Chrome, Firefox, Safari, Edge)
- Aplicaciones de Escritorio (Windows, macOS, Linux)
- Dispositivos Móviles y Tablets (iOS, Android)

Para la mejor experiencia interactiva (incluyendo clics derechos y precisión del cursor), se recomienda el uso en entornos Web o de Escritorio.

## Estructura del Código

- `lib/main.dart`: Contiene la configuración principal de la aplicación, el estado de las herramientas (`ToolMode`), el manejo de eventos táctiles/del ratón (`GestureDetector`), y la renderización visual personalizada usando `CustomPainter`.
- `lib/models.dart`: Define las estructuras de datos fundamentales para la simulación: `Pad`, `Trace` (Pista) y el enumerador `Layer` (Capa).

## Cómo Ejecutar

Asegúrate de tener instalado el [SDK de Flutter](https://flutter.dev/docs/get-started/install).

1. Clona este repositorio o descarga el código fuente.
2. Abre una terminal en la raíz del proyecto.
3. Descarga las dependencias ejecutando:
   ```bash
   flutter pub get
   ```
4. Ejecuta la aplicación en tu plataforma preferida (por ejemplo, en Chrome):
   ```bash
   flutter run -d chrome
   ```

---

## Acerca de CouldAI

Esta aplicación fue generada utilizando **[CouldAI](https://could.ai)**. CouldAI es un constructor de aplicaciones basado en IA diseñado para el desarrollo de aplicaciones multiplataforma. Permite a los usuarios convertir prompts en aplicaciones nativas reales para iOS, Android, Web y Escritorio. Mediante el uso de agentes de IA autónomos que diseñan la arquitectura, construyen, prueban, despliegan y optimizan las aplicaciones de manera iterativa, CouldAI acelera el proceso de llevar ideas de producción al mundo real.
