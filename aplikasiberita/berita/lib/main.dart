import 'package:flutter/material.dart'; //library untuk menggunakan widget-widget dari Flutter
import 'package:firebase_core/firebase_core.dart'; // library untuk menginisialisasi Firebase,
import 'package:provider/provider.dart';//library untuk menggunakan state management dengan Provider.

import 'login.dart';// menginport halaman login
import 'firebase.dart';//menginport halaman app_state
import 'home.dart';// menginport halaman home_page
import 'register.dart'; // Tambahkan impor halaman RegisterPage

void main() async { //method utama yang dijalankan saat aplikasi dimulai. Di dalam method ini, WidgetsFlutterBinding.ensureInitialized() dipanggil untuk memastikan inisialisasi Flutter telah selesai. 
  WidgetsFlutterBinding.ensureInitialized(); //dipanggil untuk memastikan inisialisasi Flutter telah selesai

  try {
    await Firebase.initializeApp();  //dipanggil untuk menginisialisasi Firebase dalam aplikasi. Jika terjadi kesalahan selama inisialisasi, pesan kesalahan akan dicetak
  } catch (error) {
    print('Terjadi kesalahan saat menginisialisasi Firebase: $error'); 
  }

  runApp(ChangeNotifierProvider( //dipanggil untuk menjalankan aplikasi dengan menggunakan ChangeNotifierProvider untuk menyediakan ApplicationState sebagai state provider dalam aplikasi.
    create: (context) => ApplicationState(),
    builder: ((context, child) => const App()),
  ));
}

class App extends StatelessWidget { //definisi kelas App yang merupakan widget utama aplikasi. Kelas ini adalah stateless widget, yang berarti tidak dapat berubah setelah dibangun
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) { //method yang mendefinisikan tampilan utama aplikasi. Di dalam method ini, widget MaterialApp digunakan sebagai kerangka tampilan utama aplikasi
    return MaterialApp(  //terdapat konfigurasi seperti judul aplikasi dan tema. Juga terdapat definisi rute untuk halaman login, halaman beranda, dan halaman pendaftaran.
      title: 'Firebase Meetup',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => NewsApp(),
        '/register': (context) => RegisterPage(), // Tambahkan rute untuk RegisterPage
      },
    );
  }
}
