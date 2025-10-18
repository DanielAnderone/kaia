// lib/view/signup_view.dart
import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../viewmodel/signup_viewmodel.dart';

class SignUpView extends StatefulWidget {
  final String apiBaseUrl;
  final Color buttonColor;
  const SignUpView({
    super.key,
    required this.apiBaseUrl,
    this.buttonColor = const Color(0xFF22C55E),
  });

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  late final SignUpViewModel vm;
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();
  final _senha = TextEditingController();
  final _confirmarSenha = TextEditingController();
  bool _obscure = true;
  bool _obscure2 = true;

  @override
  void initState() {
    super.initState();
    vm = SignUpViewModel(AuthService(baseUrl: widget.apiBaseUrl));
    vm.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    vm.dispose();
    _nome.dispose();
    _email.dispose();
    _telefone.dispose();
    _senha.dispose();
    _confirmarSenha.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    if (_senha.text != _confirmarSenha.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem')),
      );
      return;
    }

    final ok = await vm.signup(
      username: _nome.text,
      email: _email.text,
      password: _senha.text,
      // status: 'active', // opcional (envie 'inactive' se quiser criar bloqueado)
    );

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  InputDecoration _underline(String hint, IconData icon) {
    const black = Colors.black;
    return const InputDecoration().copyWith(
      hintText: hint,
      hintStyle: const TextStyle(color: black),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      prefixIcon: Icon(icon, color: black, size: 18),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: black, width: 1),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: black, width: 1),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: black, width: 1.2),
      ),
    );
  }

  ButtonStyle _greenButton() {
    return ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(widget.buttonColor),
      foregroundColor: const MaterialStatePropertyAll(Colors.white),
      shadowColor: MaterialStatePropertyAll(widget.buttonColor),
      elevation: const MaterialStatePropertyAll(4),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const black = Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Icon(Icons.person_add_alt_1, size: 48, color: black),
                const SizedBox(height: 24),
                SizedBox(
                  width: 320,
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nome,
                          style: const TextStyle(color: black),
                          decoration: _underline('Nome de usuário', Icons.person_outline),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Informe o nome de usuário' : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: black),
                          decoration: _underline('Email', Icons.email_outlined),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Informe o email';
                            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
                            return ok ? null : 'Email inválido';
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _telefone,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: black),
                          decoration: _underline('Telefone (opcional)', Icons.phone),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _senha,
                          obscureText: _obscure,
                          style: const TextStyle(color: black),
                          decoration: _underline('Senha', Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility : Icons.visibility_off,
                                color: black,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'A senha deve ter pelo menos 6 caracteres'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _confirmarSenha,
                          obscureText: _obscure2,
                          style: const TextStyle(color: black),
                          decoration: _underline('Confirmar senha', Icons.lock_open).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure2 ? Icons.visibility : Icons.visibility_off,
                                color: black,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _obscure2 = !_obscure2),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Confirme a senha'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: vm.loading ? null : _submit,
                          style: _greenButton(),
                          child: vm.loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'CRIAR CONTA',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                            child: Text(
                              'Já tem conta? Entrar',
                              style: TextStyle(
                                color: widget.buttonColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        if (vm.error != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            vm.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
