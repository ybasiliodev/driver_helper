import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CpfPage extends StatefulWidget {
  const CpfPage({super.key});

  @override
  State<CpfPage> createState() => _CpfPageState();
}

class _CpfPageState extends State<CpfPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    final cpf = _generateCPF();
    _controller.text = cpf;
  }

  String _generateCPF() {
    final rnd = Random.secure();
    List<int> n = List.generate(9, (_) => rnd.nextInt(10));

    int d1 = 0;
    for (int i = 0; i < 9; i++) {
      d1 += n[i] * (10 - i);
    }
    d1 = 11 - (d1 % 11);
    if (d1 >= 10) d1 = 0;

    int d2 = 0;
    for (int i = 0; i < 9; i++) {
      d2 += n[i] * (11 - i);
    }
    d2 += d1 * 2;
    d2 = 11 - (d2 % 11);
    if (d2 >= 10) d2 = 0;

    final full = '${n.join()}$d1$d2';
    // Format XXX.XXX.XXX-XX
    return '${full.substring(0, 3)}.${full.substring(3, 6)}.${full.substring(6, 9)}-${full.substring(9)}';
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
      appBar: AppBar(title: const Text('Gerar CPF')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Use este CPF fictício para agilizar entrega solicitando nome do recebedor.'),
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
