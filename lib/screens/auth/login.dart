import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _hidepass = true;
  bool isLoading = false;
  
  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future <void> login() async{
    if(!_formkey.currentState!.validate()){
      return;
    }

    setState(() {
      isLoading = true;
    });

    try{
      final response = await http.post(
        Uri.parse('https://sijala.biz.id/api/v1/login'),

        headers: {
          'Accept' : 'application/json',
          'Content-Type' : 'application/json',
        },
        body: jsonEncode({
            'email' : emailController.text.trim(),
            'password' : passwordController.text
        })
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200){
        final token = data['data']['token'];
        if (token == null){
          throw Exception('Token tidak ditemukan');  
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token.toString());

        if(data['data']['user'] != null){
          await prefs.setString('user', jsonEncode(data['data']['user']));
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Berhasil'),
            backgroundColor: Color.fromARGB(255, 56, 56, 56),
          )
        );

        context.go('/home');
      }
      else{
        final message =
          data['message']??'Email atau Password salah cuy';
        throw Exception(message);
      }
    }
    catch(e){
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', '')
          ),
          backgroundColor: Color.fromARGB(255, 56, 56, 56),
        ),
      );
    }
    finally{
      if (mounted){
        setState(() {
          isLoading = false;
        });
      }
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
            color: const Color.fromARGB(255, 255, 255, 255),
            image: DecorationImage(
              image: AssetImage('../../../assets/background.png'),
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
                    color: Color.fromARGB(255, 226, 226, 226),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Color.fromARGB(255, 0, 0, 0),
                        offset: Offset(1, 1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
               SizedBox(height: 12),
                SizedBox(
                  width: 320,
                  child: Card(
                    color: Color.fromARGB(162, 226, 226, 226),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Form(
                        key: _formkey, // Cek form saat diketik
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
                                onPressed: isLoading
                                    ? null
                                    : login,
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
