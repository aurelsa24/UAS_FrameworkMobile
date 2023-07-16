import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase.dart';

class RegisterPage extends StatefulWidget { //definisi kelas RegisterPage yang mengimplementasikan halaman pendaftaran pengguna. Kelas ini adalah stateful widget, yang berarti dapat berubah dan merender ulang tampilan berdasarkan perubahan internalnya.
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState(); //definisi kelas _RegisterPageState yang merupakan state dari RegisterPage. Kelas ini memperluas kelas State<RegisterPage> dan berfungsi untuk mengatur dan memperbarui keadaan internal halaman pendaftaran.
}

class _RegisterPageState extends State<RegisterPage> { //berfungsi untuk mengatur dan memperbarui keadaan internal halaman pendaftaran.
  final _formKey = GlobalKey<FormState>(); //deklarasi variabel _formKey yang digunakan untuk mengakses dan memvalidasi nilai dalam form. Ini menggunakan GlobalKey<FormState> yang memungkinkan kita mengakses form state secara global dalam widget.
  final _emailController = TextEditingController(); //deklarasi variabel _emailController yang digunakan untuk mengendalikan teks yang dimasukkan pengguna pada input email.
  final _passwordController = TextEditingController(); //deklarasi variabel _passwordController yang digunakan untuk mengendalikan teks yang dimasukkan pengguna pada input password.

  @override
  void dispose() { //method yang dipanggil saat widget dihapus dari pohon widget. Di dalam method ini, _emailController dan _passwordController di-dispose untuk menghindari kebocoran memori.
    _emailController.dispose(); 
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { //method yang mendefinisikan tampilan halaman pendaftaran pengguna. Di dalam method ini, widget Scaffold digunakan sebagai kerangka tampilan utama halaman, dengan memiliki judul "Register" pada AppBar
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFF6BA7)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Register',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan password';
                          }
                          return null;
                        },
                        obscureText: true,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final appState =
                              Provider.of<ApplicationState>(context, listen: false);
                          if (_formKey.currentState!.validate()) {
                            final email = _emailController.text;
                            final password = _passwordController.text;
                            appState.register(email, password);
                          }
                        },
                        child: Text('Register'),
                      ),
                    ],
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
