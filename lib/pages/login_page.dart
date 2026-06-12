import 'package:flutter/material.dart';
import 'package:pertemuan10_2306039/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscure = true;
  String? _usernameError;
  String? _passwordError;

  Future<void> login() async {
    final usr = usernameController.text;
    final usernameValidation = _validateUsername(usr);
    if (usernameValidation != null) {
      setState(() => _usernameError = usernameValidation);
      return;
    }

    final pwd = passwordController.text;
    final validation = _validatePassword(pwd);
    if (validation != null) {
      setState(() => _passwordError = validation);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', true);
    await prefs.setString('username', usernameController.text);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  String? _validateUsername(String usr) {
    if (usr.isEmpty) return 'Username wajib diisi';
    if (usr.length < 8) return 'Username minimal 8 karakter';
    return null;
  }

  String? _validatePassword(String pwd) {
    if (pwd.isEmpty) return 'Password wajib diisi';
    if (pwd.length < 6) return 'Password minimal 6 karakter';
    if (pwd.length > 12) return 'Password maksimal 12 karakter';
    // require at least one digit and ensure digits are unique
    final seen = <String>{};
    var hasDigit = false;
    for (final ch in pwd.split('')) {
      if (RegExp(r"\d").hasMatch(ch)) {
        hasDigit = true;
        if (seen.contains(ch))
          return 'Angka dalam password harus unik (tidak boleh berulang)';
        seen.add(ch);
      }
    }
    if (!hasDigit) return 'Password harus mengandung setidaknya satu angka';
    return null;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 80, color: Colors.blue),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    onChanged: (v) {
                      setState(() => _usernameError = _validateUsername(v));
                    },
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      helperText: 'Minimal 8 karakter',
                      errorText: _usernameError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: passwordController,
                    obscureText: _obscure,
                    maxLength: 12,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      helperText:
                          '6-12 karakter, harus ada angka, angka tidak boleh berulang',
                      errorText: _passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (v) {
                      setState(() => _passwordError = _validatePassword(v));
                    },
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_validateUsername(usernameController.text) == null &&
                              _validatePassword(passwordController.text) ==
                                  null)
                          ? login
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
