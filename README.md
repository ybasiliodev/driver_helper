Driver Helper - Flutter app para auxiliar entregadores

Descrição

Aplicativo simples em Flutter com as seguintes funcionalidades:

- Gerar CPF fictício (formatado).
- Gerar RG fictício (formatado).
- Verificar CEP usando ViaCEP e exibir logradouro, bairro e cidade.
- Abrir conversa no WhatsApp com número fornecido (usa https://wa.me/55<numero>).

Observação: cpf/rg gerados são fictícios e a app deve ser usada apenas para agilizar processos com autorização do recebedor (solicitar o nome do recebedor de forma explícita).

Como rodar

1. Tenha o Flutter SDK instalado e disponível no PATH.
2. No terminal na pasta do projeto, execute:

```powershell
cd c:/Users/Administrator/Documents/projetos/driver_helper
flutter pub get
flutter run
```

Dependências importantes (no `pubspec.yaml`):
- http: para consultar ViaCEP
- url_launcher: para abrir WhatsApp

Notas de implementação

- A validação de CPF usa cálculo dos dígitos verificadores para gerar um CPF plausível.
- Para consultar o CEP, o app usa a API pública do ViaCEP: https://viacep.com.br/ws/<cep>/json/
- Para abrir um link de WhatsApp usa-se `https://wa.me/55<numero>`; o app adiciona o código do Brasil (55) automaticamente.

Próximos passos possíveis

- Adicionar testes unitários para os geradores.
- Melhorar UX, adicionar ícones e traduções.
- Validar formatos de entrada com máscaras (package:mask_text_input_formatter).
