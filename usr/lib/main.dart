import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' as ui;
import 'models.dart';

void main() {
  runApp(const PCBRoutingApp());
}

class PCBRoutingApp extends StatelessWidget {
  const PCBRoutingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PCB Router',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E), // Estilo oscuro EDA
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueGrey,
          secondary: Colors.amber,
          surface: Color(0xFF2D2D2D),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PCBRoutingScreen(),
      },
    );
  }
}

class PCBRoutingScreen extends StatefulWidget {
  const PCBRoutingScreen({super.key});

  @override
  State<PCBRoutingScreen> createState() => _PCBRoutingScreenState();
}

enum ToolMode { select, placePad, route }

class _PCBRoutingScreenState extends State<PCBRoutingScreen> {
  // Estado del documento
  List<Pad> pads = [];
  List<Trace> traces = [];
  Layer activeLayer = Layer.top;
  ToolMode activeTool = ToolMode.route;

  // Estado interactivo del rutado
  Offset? _currentRouteStart;
  Offset? _currentRouteEnd;
  
  // Transformación del lienzo (pan/zoom)
  final TransformationController _transformationController = TransformationController();
  
  final double gridSize = 20.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Offset _snapToGrid(Offset position) {
    final double x = (position.dx / gridSize).roundToDouble() * gridSize;
    final double y = (position.dy / gridSize).roundToDouble() * gridSize;
    return Offset(x, y);
  }

  void _handleTapDown(TapDownDetails details) {
    // Convertir coordenadas de la pantalla a coordenadas del lienzo
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    final Matrix4 transform = _transformationController.value;
    final Offset canvasPosition = MatrixUtils.transformPoint(transform.clone()..invert(), localPosition);
    
    final snappedPosition = _snapToGrid(canvasPosition);

    setState(() {
      if (activeTool == ToolMode.placePad) {
        pads.add(Pad(position: snappedPosition));
      } else if (activeTool == ToolMode.route) {
        if (_currentRouteStart == null) {
          _currentRouteStart = snappedPosition;
          _currentRouteEnd = snappedPosition;
        } else {
          // Finalizar la ruta actual
          if (_currentRouteStart != snappedPosition) {
            traces.add(Trace(
              start: _currentRouteStart!,
              end: snappedPosition,
              layer: activeLayer,
            ));
          }
          // Continuar la ruta desde este nuevo punto
          _currentRouteStart = snappedPosition;
          _currentRouteEnd = snappedPosition;
        }
      }
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (activeTool == ToolMode.route && _currentRouteStart != null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
      final Matrix4 transform = _transformationController.value;
      final Offset canvasPosition = MatrixUtils.transformPoint(transform.clone()..invert(), localPosition);
      
      setState(() {
        _currentRouteEnd = _snapToGrid(canvasPosition);
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    // Opcionalmente terminar el trazo al levantar el dedo, pero es mejor el modo click-to-click.
  }

  void _clearCanvas() {
    setState(() {
      pads.clear();
      traces.clear();
      _currentRouteStart = null;
      _currentRouteEnd = null;
    });
  }
  
  void _escapeTool() {
    setState(() {
       _currentRouteStart = null;
       _currentRouteEnd = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCB Router'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpiar Todo',
            onPressed: _clearCanvas,
          ),
        ],
      ),
      body: Row(
        children: [
          // Panel de herramientas lateral
          Container(
            width: 70,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildToolButton(Icons.ads_click, ToolMode.select, 'Seleccionar'),
                _buildToolButton(Icons.radio_button_checked, ToolMode.placePad, 'Colocar Pad'),
                _buildToolButton(Icons.timeline, ToolMode.route, 'Trazar Ruta'),
                const Divider(height: 32),
                _buildLayerButton(Layer.top, 'Top Layer', Colors.red),
                _buildLayerButton(Layer.bottom, 'Bottom Layer', Colors.blue),
              ],
            ),
          ),
          // Área del Lienzo
          Expanded(
            child: MouseRegion(
              cursor: activeTool == ToolMode.route || activeTool == ToolMode.placePad 
                  ? SystemMouseCursors.precise 
                  : SystemMouseCursors.basic,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onPanUpdate: activeTool == ToolMode.route ? _handlePanUpdate : null,
                onPanEnd: activeTool == ToolMode.route ? _handlePanEnd : null,
                onSecondaryTapDown: (_) => _escapeTool(), // Click derecho cancela el trazo actual
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.1,
                  maxScale: 10.0,
                  // Deshabilitar pan/zoom con un solo dedo si estamos rutando para no interferir
                  panEnabled: activeTool == ToolMode.select,
                  scaleEnabled: true,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: PCBPainter(
                      pads: pads,
                      traces: traces,
                      activeLayer: activeLayer,
                      gridSize: gridSize,
                      currentRouteStart: _currentRouteStart,
                      currentRouteEnd: _currentRouteEnd,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, ToolMode mode, String tooltip) {
    final isSelected = activeTool == mode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        color: isSelected ? Colors.amber : Colors.white70,
        onPressed: () {
          setState(() {
            activeTool = mode;
            _currentRouteStart = null; // Reiniciar ruta en curso al cambiar de herramienta
          });
        },
      ),
    );
  }

  Widget _buildLayerButton(Layer layer, String tooltip, Color color) {
    final isSelected = activeLayer == layer;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () {
            setState(() {
              activeLayer = layer;
              _currentRouteStart = null; // Reiniciar ruta
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
              border: Border.all(color: color, width: isSelected ? 3 : 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                layer == Layer.top ? 'T' : 'B',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PCBPainter extends CustomPainter {
  final List<Pad> pads;
  final List<Trace> traces;
  final Layer activeLayer;
  final double gridSize;
  final Offset? currentRouteStart;
  final Offset? currentRouteEnd;

  PCBPainter({
    required this.pads,
    required this.traces,
    required this.activeLayer,
    required this.gridSize,
    this.currentRouteStart,
    this.currentRouteEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Dibujar el fondo oscuro y la cuadrícula
    final backgroundPaint = Paint()..color = const Color(0xFF1E1E1E);
    canvas.drawRect(rect, backgroundPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // 2. Dibujar las pistas (Traces)
    final topTracePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final bottomTracePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Dibujar primero la capa no activa (para que la activa quede por encima)
    for (var trace in traces) {
      if (trace.layer != activeLayer) {
        canvas.drawLine(
          trace.start, 
          trace.end, 
          trace.layer == Layer.top ? topTracePaint : bottomTracePaint
        );
      }
    }
    
    // Dibujar luego la capa activa
    for (var trace in traces) {
      if (trace.layer == activeLayer) {
        canvas.drawLine(
          trace.start, 
          trace.end, 
          trace.layer == Layer.top ? topTracePaint : bottomTracePaint
        );
      }
    }

    // 3. Dibujar la ruta en curso si la hay
    if (currentRouteStart != null && currentRouteEnd != null) {
      final routingPaint = Paint()
        ..color = activeLayer == Layer.top ? Colors.red.withOpacity(0.7) : Colors.blue.withOpacity(0.7)
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(currentRouteStart!, currentRouteEnd!, routingPaint);
    }

    // 4. Dibujar los Pads
    final padPaint = Paint()
      ..color = const Color(0xFFC0C0C0) // Plateado
      ..style = PaintingStyle.fill;
      
    final holePaint = Paint()
      ..color = const Color(0xFF1E1E1E) // Fondo oscuro para el agujero (Through-hole simulado)
      ..style = PaintingStyle.fill;

    for (var pad in pads) {
      canvas.drawCircle(pad.position, pad.radius, padPaint);
      canvas.drawCircle(pad.position, pad.radius * 0.4, holePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PCBPainter oldDelegate) {
    return true; // Simple approach, always repaint on change
  }
}
