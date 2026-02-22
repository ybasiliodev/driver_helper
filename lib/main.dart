import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Helper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Helper')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GeneratorPage(type: GeneratorType.cpf)),
              ),
              child: const Text('Gerar CPF'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GeneratorPage(type: GeneratorType.rg)),
              ),
              child: const Text('Gerar RG'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CepPage()),
              ),
              child: const Text('Verificar CEP'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WhatsappPage()),
              ),
              child: const Text('Chamar no Whatsapp'),
            ),
          ],
        ),
      ),
    );
  }
}

enum GeneratorType { cpf, rg }

class GeneratorPage extends StatefulWidget {
  final GeneratorType type;
  const GeneratorPage({super.key, required this.type});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    if (widget.type == GeneratorType.cpf) {
      final cpf = _generateCPF();
      _controller.text = cpf;
    } else {
      final rg = _generateRG();
      _controller.text = rg;
    }
  }

  String _generateRG() {
    final rnd = Random.secure();
    List<int> d = List.generate(9, (_) => rnd.nextInt(10));
    // Format: 12.345.678-9
    final s = d.join();
    return '${s.substring(0, 2)}.${s.substring(2, 5)}.${s.substring(5, 8)}-${s.substring(8)}';
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado para a área de transferência')));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == GeneratorType.cpf ? 'Gerar CPF' : 'Gerar RG';
    final helper = widget.type == GeneratorType.cpf
        ? 'Use este CPF fictício para agilizar entrega solicitando nome do recebedor.'
        : 'Use este RG fictício para agilizar entrega solicitando nome do recebedor.';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(helper),
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

class CepPage extends StatefulWidget {
  const CepPage({super.key});

  @override
  State<CepPage> createState() => _CepPageState();
}

class _CepPageState extends State<CepPage> {
  final TextEditingController _cepController = TextEditingController();
  final MaskTextInputFormatter _cepMask = MaskTextInputFormatter(mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});
  String _logradouro = '';
  String _bairro = '';
  String _localidade = '';
  bool _loading = false;

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _searchCep() async {
    final cepRaw = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepRaw.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite um CEP válido com 8 dígitos')));
      return;
    }

    setState(() {
      _loading = true;
      _logradouro = '';
      _bairro = '';
      _localidade = '';
    });

    try {
      final url = 'https://viacep.com.br/ws/$cepRaw/json/';
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(resp.body);
        if (data.containsKey('erro') && data['erro'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CEP não encontrado')));
        } else {
          setState(() {
            _logradouro = data['logradouro'] ?? '';
            _bairro = data['bairro'] ?? '';
            _localidade = data['localidade'] ?? '';
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao consultar ViaCEP')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar CEP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Digite o CEP (somente números)'),
            const SizedBox(height: 8),
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              inputFormatters: [_cepMask],
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ex: 17026-320'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _searchCep,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Pesquisar'),
            ),
            const SizedBox(height: 20),
            if (_logradouro.isNotEmpty || _bairro.isNotEmpty || _localidade.isNotEmpty) ...[
              Text('Logradouro: $_logradouro'),
              Text('Bairro: $_bairro'),
              Text('Cidade: $_localidade'),
            ],
          ],
        ),
      ),
    );
  }
}

class WhatsappPage extends StatefulWidget {
  const WhatsappPage({super.key});

  @override
  State<WhatsappPage> createState() => _WhatsappPageState();
}

class _WhatsappPageState extends State<WhatsappPage> {
  final TextEditingController _phoneController = TextEditingController();
  final MaskTextInputFormatter _phoneMask = MaskTextInputFormatter(mask: '(##) 9####-####', filter: {"#": RegExp(r'[0-9]')});

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _openWhatsapp() async {
    final raw = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    // Expecting DDD + number (11 digits). Add Brazil code 55.
    if (raw.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite ao menos DDD + número (ex: 11999999999)')));
      return;
    }
    final full = '55$raw';
    final url = 'https://wa.me/$full';
    try {
      final launched = await launchUrlString(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível abrir o WhatsApp')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao abrir WhatsApp: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chamar no Whatsapp')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Digite o DDD + número (somente números)'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [_phoneMask],
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ex: (11) 99999-9999'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _openWhatsapp,
              child: const Text('Chamar'),
            ),
            const SizedBox(height: 12),
            const Text('Obs: será aberto o WhatsApp com o número informado usando https://wa.me/55<numero>'),
          ],
        ),
      ),
    );
  }
}
