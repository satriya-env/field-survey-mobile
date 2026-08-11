import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _hidepass = true;
  bool _isFormValid = false; // 1. Tambahan status untuk mengontrol tombol masuk
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formkey = GlobalKey<FormState>(); // 2. Ditambahkan <FormState> agar bisa validasi

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // 3. Fungsi untuk mengecek validasi setiap kali user mengetik
  void _validateForm() {
    final isValid = formkey.currentState?.validate() ?? false;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
            image: DecorationImage(
              image: AssetImage('../../../assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               SizedBox(height: 60),
               Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 5,
                    shadows: [
                      Shadow(
                        color: Color.fromARGB(255, 53, 53, 53),
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
               SizedBox(height: 5),
               Text(
                  'Masuk untuk melanjutkan',
                  style: TextStyle(
                    color: Color.fromARGB(179, 255, 255, 255),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
               SizedBox(height: 12),
                SizedBox(
                  width: 320,
                  child: Card(
                    color: Color.fromARGB(136, 255, 255, 255),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      // 5. Dibungkus dengan Widget Form
                      child: Form(
                        key: formkey,
                        onChanged: _validateForm, // Cek form saat diketik
                        child: Column(
                          children: [
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              // Aturan validasi email
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                return null; // Valid
                              },
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: passwordController,
                              obscureText: _hidepass,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _hidepass = !_hidepass;
                                    });
                                  },
                                  icon: Icon(
                                    _hidepass
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                              // Aturan validasi password
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Password tidak boleh kosong';
                                }
                                return null; // Valid
                              },
                            ),
                            SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 83, 83, 83),
                                  foregroundColor: Colors.white,
                                ),
                                // 6. Tombol hanya aktif (bisa diklik) jika _isFormValid = true
                                onPressed: _isFormValid
                                    ? () {
                                        context.go('/home');
                                      }
                                    : null,
                                child: Text('Masuk'),
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Belum punya akun?'),
                                TextButton(
                                  onPressed: () {
                                    context.go('/register');
                                  },
                                  child: Text('Daftar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}