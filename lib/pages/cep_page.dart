import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;

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
      if (!mounted) return;

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(resp.body);
        if (data.containsKey('erro') && data['erro'] == true) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CEP não encontrado')));
        } else {
          if (mounted) {
            setState(() {
              _logradouro = data['logradouro'] ?? '';
              _bairro = data['bairro'] ?? '';
              _localidade = data['localidade'] ?? '';
            });
          }
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao consultar ViaCEP')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
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
