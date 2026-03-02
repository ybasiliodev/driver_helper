import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite ao menos DDD + número (ex: 11999999999)')));
      return;
    }
    final full = '55$raw';
    final url = 'https://wa.me/$full';
    try {
      final launched = await launchUrlString(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível abrir o WhatsApp')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao abrir WhatsApp: $e')));
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
