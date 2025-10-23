// lib/view/login_view.dart
import 'package:flutter/material.dart';
import 'package:kaia_app/model/auth.dart';
import 'package:kaia_app/utils/token_manager.dart';
import '../service/auth_service.dart';
// import '../view/project_view.dart';
import '../viewmodel/login_viewmodel.dart';
import 'signup_view.dart'; // necessário para a animação de navegação

class LoginView extends StatefulWidget {
  final String apiBaseUrl;
  final ImageProvider? logo;
  final Color buttonColor;
  const LoginView({
    super.key,
    this.apiBaseUrl = "http://0.0.0.0:8080", // URL base padrão
    this.logo,
    this.buttonColor = const Color(0xFF22C55E),
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel vm;
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // Injeção do AuthService com a base definida
    vm = LoginViewModel(AuthService(baseUrl: widget.apiBaseUrl));
    vm.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    vm.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final res = await vm.login(_email.text.trim(), _pass.text);
    
    if (res !=null && mounted)  {
      SesManager.setJWTToken(res['token']);
      SesManager.setPayload(User.fromJson(res['user']));  

      if (res["user"]["role"] == "admin") {
        Navigator.pushReplacementNamed(context, "/admin/dashboard");
        return;
      } else if (res["user"]["role"] == "user") {
        Navigator.pushReplacementNamed(context, '/investor/projects');
        return;
      }
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
                if (widget.logo != null)
                  Image(image: widget.logo!, height: 56)
                else
                  const Icon(Icons.blur_on, size: 48, color: black),

                const SizedBox(height: 24),

                SizedBox(
                  width: 320,
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: black),
                          decoration: _underline('Username', Icons.person_outline),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Informe o email';
                            }
                            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(v.trim());
                            return ok ? null : 'Email inválido';
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _pass,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(color: black),
                          decoration: _underline('Password', Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility : Icons.visibility_off,
                                color: black,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Informe a senha' : null,
                        ),
                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/forgot'),
                            child: const Text('Forgot your password ?', style: TextStyle(color: black)),
                          ),
                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: vm.loading ? null : _submit,
                          style: _greenButton(),
                          child: vm.loading
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 400),
                                  pageBuilder: (_, __, ___) => SignUpView(
                                    apiBaseUrl: widget.apiBaseUrl, // reaproveita a mesma base
                                    buttonColor: widget.buttonColor,
                                  ),
                                  transitionsBuilder: (_, animation, __, child) {
                                    const begin = Offset(0.0, 1.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeOutCubic;
                                    final tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    return SlideTransition(position: animation.drive(tween), child: child);
                                  },
                                ),
                              );
                            },
                            child: Text(
                              'SIGN UP',
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
                          Text(vm.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
