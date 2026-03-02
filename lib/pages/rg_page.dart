import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RgPage extends StatefulWidget {
  const RgPage({super.key});

  @override
  State<RgPage> createState() => _RgPageState();
}

class _RgPageState extends State<RgPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    final rg = _generateRG();
    _controller.text = rg;
  }

  String _generateRG() {
    final rnd = Random.secure();
    List<int> d = List.generate(9, (_) => rnd.nextInt(10));
    // Format: 12.345.678-9
    final s = d.join();
    return '${s.substring(0, 2)}.${s.substring(2, 5)}.${s.substring(5, 8)}-${s.substring(8)}';
  }

  Future<void> _copyToClipboard() async {
    if (_controller.text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _controller.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado para a área de transferência')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerar RG')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Use este RG fictício para agilizar entrega solicitando nome do recebedor.'),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              readOnly: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Resultado'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generate,
                    child: const Text('Gerar'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _copyToClipboard,
                  child: const Icon(Icons.copy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
