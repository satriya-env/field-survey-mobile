import 'package:flutter/material.dart';

class Profil extends StatelessWidget {
  const Profil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50,),
              ),
              Text('data'),
              Card(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Nama'),
                  subtitle: Text('data'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email'),
                  subtitle: Text('data'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.call),
                  title: Text('Nomor Whatsapp'),
                  subtitle: Text('data'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.man),
                  title: Text('Gender'),
                  subtitle: Text('data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}