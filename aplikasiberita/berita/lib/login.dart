import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase.dart';
import 'register.dart';
import 'home.dart';

class LoginPage extends StatefulWidget { //definisi kelas LoginPage yang mengimplementasikan halaman login. Kelas ini adalah stateful widget, yang berarti dapat berubah dan merender ulang tampilan berdasarkan perubahan internalnya.
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> { //Ini adalah definisi kelas _LoginPageState yang merupakan state dari LoginPage. Kelas ini memperluas kelas State<LoginPage> dan berfungsi untuk mengatur dan memperbarui keadaan internal halaman login.
  final _formKey = GlobalKey<FormState>(); //deklarasi variabel _formKey yang digunakan untuk mengakses dan memvalidasi nilai dalam form. Ini menggunakan GlobalKey<FormState> yang memungkinkan kita mengakses form state secara global dalam widget.
  final _emailController = TextEditingController(); //deklarasi variabel _emailController yang digunakan untuk mengendalikan teks yang dimasukkan pengguna pada input email.
  final _passwordController = TextEditingController(); //deklarasi variabel _passwordController yang digunakan untuk mengendalikan teks yang dimasukkan pengguna pada input password.
  String? _errorMessage;

  @override
  void dispose() { //method yang dipanggil saat widget dihapus dari pohon widget. Di dalam method ini, _emailController dan _passwordController di-dispose untuk menghindari kebocoran memori.
    _emailController.dispose(); 
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { //method yang mendefinisikan tampilan halaman login. Di dalam method ini, widget Scaffold digunakan sebagai kerangka tampilan utama halaman, dengan tampilan latar belakang berupa gradient
    return Scaffold(
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
                  'Login',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
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
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final appState =
                                  Provider.of<ApplicationState>(context, listen: false);
                              if (_formKey.currentState!.validate()) {
                                final email = _emailController.text;
                                final password = _passwordController.text;
                                final success = await appState.signIn(email, password);
                                if (success) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                  Navigator.pushNamed(context, '/home');
                                } else {
                                  setState(() {
                                    _errorMessage = 'Email atau password tidak valid';
                                  });
                                }
                              }
                            },
                            child: Text('Login'),
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterPage()),
                              );
                            },
                            child: Text('Register'),
                          ),
                        ],
                      ),
                    ),
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
