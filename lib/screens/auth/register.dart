import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _hidepass = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // Menggunakan BoxConstraints agar background biru selalu memenuhi tinggi layar penuh
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 56, 56, 56),
            image: DecorationImage(
              image: AssetImage('../assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60), // Memberi sedikit jarak dari atas layar
                const Text(
                  'DAFTAR',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Buat akun untuk melanjutkan',
                  style: TextStyle(
                    color: Color.fromARGB(179, 231, 231, 231),
                    shadows: [Shadow(
                      color: Color.fromARGB(255, 53, 53, 53),
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    )]
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 320,
                  child: Card(
                    color: const Color.fromARGB(136, 255, 255, 255),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), 
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
                          ),
                          const SizedBox(height: 12),
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
                                  _hidepass ? Icons.visibility_off : Icons.visibility,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 77, 77, 77),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                context.go('/home'); // Navigasi ke halaman dashboard
                              },
                              child: const Text('Buat Akun'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60), // Memberi sedikit jarak di bawah agar bisa di-scroll dengan nyaman
              ],
            ),
          ),
        ),
      ),
    );
  }
}