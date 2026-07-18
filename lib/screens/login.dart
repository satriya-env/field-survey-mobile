import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _hidepass = true;

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
            color: Colors.blue,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60), // Memberi sedikit jarak dari atas layar
                const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Masuk untuk melanjutkan',
                  style: TextStyle(
                    color: Color.fromARGB(179, 255, 255, 255),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 320,
                  child: Card(
                    child: Padding(
                      // PERBAIKAN 1: Diganti jadi EdgeInsets.symmetric
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), 
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Nama',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            obscureText: _hidepass,
                            decoration: InputDecoration(
                              hintText: 'Password',
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
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {},
                              child: const Text('Masuk'),
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