import 'package:flutter/material.dart';
import 'package:niimbot_label_printer/niimbot_label_printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img_lib; // Para processar imagem

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NiimbotLabelPrinter _printer = NiimbotLabelPrinter();
  List<dynamic> _devices = []; // Lista de BluetoothDevice (dinâmico para compatibilidade)
  dynamic _selectedDevice; // BluetoothDevice selecionado
  bool _isConnected = false;
  String _status = "Desconectado";

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) => _loadPairedDevices());
  }

  Future<void> _requestPermissions() async {
    // Permissões para Bluetooth no desktop
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
  }

  Future<void> _loadPairedDevices() async {
    try {
      setState(() => _status = "Carregando dispositivos pareados...");
      final devices = await _printer.getPairedDevices();
      if (mounted) {
        setState(() {
          _devices = devices ?? [];
          _status = "${_devices.length} dispositivo(s) pareado(s) encontrado(s).";
        });
      }
    } catch (e) {
      setState(() => _status = "Erro ao carregar: $e");
    }
  }

  Future<void> _connect(dynamic device) async {
    try {
      setState(() => _status = "Conectando...");
      await _printer.connect(device);
      if (mounted) {
        setState(() {
          _selectedDevice = device;
          _isConnected = true;
          _status = "Conectado a ${_getDeviceName(device)}";
        });
      }
    } catch (e) {
      setState(() => _status = "Falha ao conectar: $e");
    }
  }

  Future<void> _disconnect() async {
    try {
      await _printer.disconnect();
      if (mounted) {
        setState(() {
          _isConnected = false;
          _selectedDevice = null;
          _status = "Desconectado";
        });
      }
    } catch (e) {
      setState(() => _status = "Erro ao desconectar: $e");
    }
  }

  String _getDeviceName(dynamic device) {
    // Acessa o nome do dispositivo (ajuste se o getter for diferente, ex: device.name)
    return device.toString().split(' ')[0]; // Fallback simples; verifique no debug
  }

  // Captura um widget como imagem PNG (para conteúdo personalizado)
  Future<Uint8List> _captureWidgetAsPng(GlobalKey key) async {
    final RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 2.0); // Ajuste DPI para qualidade
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // Função principal de impressão
  Future<void> _printLabel() async {
    if (!_isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Conecte a impressora primeiro!")),
        );
      }
      return;
    }

    try {
      setState(() => _status = "Gerando e enviando etiqueta...");

      // Captura o preview como imagem
      final Uint8List pngBytes = await _captureWidgetAsPng(_globalKey);

      // Decodifica para img.Image e converte para bitmap monocromático (formato Niimbot)
      final img_lib.Image? image = img_lib.decodePng(pngBytes);
      if (image == null) throw Exception("Falha ao processar imagem");

      // Redimensiona para tamanho típico de etiqueta Niimbot (ex: 100x50mm ~ 800x400 pixels a 203dpi)
      final img_lib.Image resized = img_lib.copyResize(image, width: 800, height: 400);

      // Converte para bytes raw (1-bit bitmap, threshold para B&W)
      final Uint8List bitmapBytes = _imageToBitmapBytes(resized);

      // Cria PrintData (ajuste width/height baseado no seu label; rotate/invert para orientação)
      final PrintData printData = PrintData(
        data: bitmapBytes,
        width: resized.width,
        height: resized.height,
        rotate: false, // Gire se necessário
        invertColor: false,
        density: 5, // 0-10; densidade de impressão
        labelType: 0, // 0 para label contínuo; ajuste conforme modelo (consulte manual Niimbot)
      );

      // Envia para impressão
      await _printer.send(printData);

      if (mounted) {
        setState(() => _status = "Etiqueta impressa com sucesso!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impressão enviada! Verifique a impressora.")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = "Erro ao imprimir: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e")),
        );
      }
    }
  }

  // Converte img.Image para bytes de bitmap 1-bit (formato raw para Niimbot)
  Uint8List _imageToBitmapBytes(img_lib.Image image) {
    final bytes = <int>[];
    final w = image.width;
    final h = image.height;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x += 8) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          final pixel = image.getPixel(x + bit, y);
          final gray = (img_lib.getLuminance(pixel) * 255).round();
          if (gray > 128) { // Threshold para B&W; <128 = preto (bit 1)
            byte |= (1 << (7 - bit));
          }
        }
        bytes.add(byte);
      }
    }
    return Uint8List.fromList(bytes);
  }

  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Niimbot Label Printer - Desktop")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("Status: $_status", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _loadPairedDevices,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Atualizar Pareados"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _isConnected ? _disconnect : null,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("Desconectar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Dispositivos Bluetooth Pareados:", style: TextStyle(fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    final isSelected = _selectedDevice == device;
                    return ListTile(
                      tileColor: isSelected ? Colors.green[100] : null,
                      leading: const Icon(Icons.print),
                      title: Text(_getDeviceName(device)),
                      subtitle: Text(device.toString()), // MAC ou detalhes
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                      onTap: () => _connect(device),
                    );
                  },
                ),
              ),
              const Divider(),
              ElevatedButton.icon(
                icon: const Icon(Icons.print, size: 30),
                label: const Text("IMPRIMIR ETIQUETA DE TESTE", style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isConnected ? _printLabel : null,
              ),
              const SizedBox(height: 20),

              // Preview da etiqueta (será capturado para impressão)
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  width: 300, // Largura simulada
                  height: 150, // Altura simulada
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Etiqueta Teste", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Produto: Caneta Azul", style: TextStyle(fontSize: 16)),
                      Text("Preço: R\$ 9,90", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Data: 23/11/2025", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isConnected) _printer.disconnect();
    super.dispose();
  }
}