import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final namaCont = TextEditingController();
  final emailCont = TextEditingController();
  final waCont = TextEditingController();
  String? gender;

  @override
  void dispose() {
    namaCont.dispose();
    emailCont.dispose();
    waCont.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://sijala.biz.id/api/v1/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': namaCont.text.trim(),
          'email': emailCont.text.trim(),
          'phone': waCont.text.trim(),
          'gender': gender,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Registrasi Berhasil!'),
            backgroundColor: const Color.fromARGB(255, 56, 56, 56),
          ),
        );

        context.go('/home');
      } else {
        final message = data['message'] ?? 'Gagal mendaftar, periksa kembali data Anda';
        throw Exception(message);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: const Color.fromARGB(255, 56, 56, 56),
        ),
      );
    } finally {
      if (mounted) {
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
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            image: DecorationImage(
              image: AssetImage('../../../assets/background.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color.fromARGB(126, 0, 0, 0), 
                BlendMode.darken)
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'DAFTAR',
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
                const SizedBox(height: 5),
                const Text(
                  'Buat akun baru untuk melanjutkan',
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
                const SizedBox(height: 12),
                SizedBox(
                  width: 320,
                  child: Card(
                    color: const Color.fromARGB(162, 226, 226, 226),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // 1. Nama Lengkap
                            TextFormField(
                              controller: namaCont,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                labelText: 'Nama Lengkap',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // 2. Email
                            TextFormField(
                              controller: emailCont,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // 3. WhatsApp
                            TextFormField(
                              controller: waCont,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Nomor WhatsApp',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nomor WhatsApp tidak boleh kosong';
                                }
                                if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                                  return 'Nomor WhatsApp harus berupa angka';
                                }
                                if (value.trim().length < 10) {
                                  return 'Nomor WhatsApp terlalu pendek';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // 4. Jenis Kelamin
                            DropdownButtonFormField<String>(
                              value: gender,
                              decoration: InputDecoration(
                                labelText: 'Jenis Kelamin',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              hint: const Text('Pilih Jenis Kelamin'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'L',
                                  child: Text('Laki-laki'),
                                ),
                                DropdownMenuItem(
                                  value: 'P',
                                  child: Text('Perempuan'),
                                ),
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  gender = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Jenis kelamin harus dipilih';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Tombol Daftar
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 83, 83, 83),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: isLoading 
                                            ? null 
                                            : register,
                                child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Daftar'),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Link Navigasi Ke Login
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Sudah punya akun?'),
                                TextButton(
                                  onPressed: () {
                                    context.go('/login');
                                  },
                                  child: const Text('Masuk'),
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