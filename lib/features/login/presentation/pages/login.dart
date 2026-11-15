import 'package:flutter/material.dart';
import 'package:natyapp/core/di/injection.dart';
import 'package:natyapp/core/network/api_client.dart';
import 'package:natyapp/core/components/textFieldNaty.dart';
import 'package:natyapp/core/router/app_routes.dart';
import 'package:natyapp/core/widgets/gradient_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_email.text.trim().isEmpty || _senha.text.isEmpty) {
      setState(() => _erro = 'Informe seu e-mail e sua senha.');
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resposta = await getIt<ApiClient>().postJson(
        '/api/v1/sessoes',
        body: {'email': _email.text.trim(), 'senha': _senha.text},
      );
      getIt<ApiClient>().setSession(resposta);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoute.home.path);
      }
    } catch (error) {
      if (mounted) setState(() => _erro = error.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Text("LOGIN", style: TextStyle(fontSize: 25)),
            TextFieldNaty(
              onChanged: (value) => _email.text = value,
              label: "Usuario/Email",
            ),
            TextFieldNaty(
              onChanged: (value) => _senha.text = value,
              label: "Senha",
            ),
            if (_erro != null)
              Text(_erro!, style: const TextStyle(color: Colors.redAccent)),
            GradientButton(
              label: 'Iniciar Aprendizado!',
              isLoading: _carregando,
              onPressed: _entrar,
            ),
          ],
        ),
      ),
    );
  }
}
