import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _hidepass = true;
  String _nama = "";
  String _pass = "";

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
            image: DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80'),
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
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    // color: Colors.white,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Masuk untuk melanjutkan',
                  style: TextStyle(
                    color: Color.fromARGB(179, 51, 51, 51),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 320,
                  child: Card(
                    color: const Color.fromARGB(136, 255, 255, 255),
                    child: Padding(
                      // PERBAIKAN 1: Diganti jadi EdgeInsets.symmetric
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), 
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (value) {
                              _nama = value;
                            },
                            decoration: InputDecoration(
                              hintText: 'Nama',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            onChanged: (value) {
                              _pass = value;
                            },
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