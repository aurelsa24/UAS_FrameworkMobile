import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'dart:async';

class ApplicationState extends ChangeNotifier { //konstruktor untuk kelas ApplicationState. Konstruktor ini dipanggil saat objek ApplicationState dibuat. Di dalam konstruktor ini, method init() dipanggil untuk menginisialisasi Firebase dan konfigurasi otentikasi.
  ApplicationState() {
    init();
  }

  Future<void> init() async { //method yang digunakan untuk menginisialisasi Firebase dan konfigurasi otentikasi. Di dalam method ini, Firebase.initializeApp dipanggil untuk menginisialisasi Firebase menggunakan opsi konfigurasi yang diberikan
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseUIAuth.configureProviders([ //dipanggil untuk mengonfigurasi penyedia otentikasi yang akan digunakan dalam antarmuka pengguna FirebaseUI.
      EmailAuthProvider(),
    ]);
  }

  Future<bool> signIn(String email, String password) async { //method yang digunakan untuk melakukan proses otentikasi masuk menggunakan email dan password
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      await auth.signInWithEmailAndPassword( //dipanggil untuk melakukan proses otentikasi masuk dengan email dan password yang diberikan. Jika proses otentikasi berhasil, method akan mengembalikan nilai true, dan jika gagal, akan mengembalikan nilai false.
        email: email,
        password: password,
      );

      return auth.currentUser != null;
    } catch (error) {
      print('Terjadi kesalahan saat proses otentikasi: $error');
      return false;
    }
  }

  Future<void> register(String email, String password) async { //method yang digunakan untuk melakukan proses pendaftaran pengguna baru menggunakan email dan password
    bool isValidEmail(String email) { 
      final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
      return emailRegex.hasMatch(email);
    }

    if (!isValidEmail(email)) {
      print('Format alamat email tidak valid');
      return;
    }

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      final UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      print('Terjadi kesalahan saat proses pendaftaran: $error');
    }
  }

  Future<void> addComment(String comment) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      if (userId != null) {
        final commentData = {
          'userId': userId,
          'comment': comment,
          'timestamp': DateTime.now(),
        };

        await FirebaseFirestore.instance
            .collection('comments')
            .add(commentData);
      } else {
        print('User tidak ditemukan');
      }
    } catch (error) {
      print('Terjadi kesalahan saat menambahkan komentar: $error');
    }
  }

  Future<List<dynamic>> fetchComments() async { //method yang digunakan untuk mengambil komentar dari koleksi 'comments' di Firebase Cloud Firestore. Di dalam method ini, FirebaseFirestore.collection('comments').get digunakan untuk mendapatkan QuerySnapshot dari Firestore. Kemudian, data komentar diekstrak dari QuerySnapshot dan dikembalikan sebagai daftar komentar.
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('comments').get();

      final List<dynamic> comments = querySnapshot.docs.map((doc) {
        final Map<String, dynamic>? data = doc.data() as Map<String,
            dynamic>?; // Ubah tipe data menjadi Map<String, dynamic>?
        final comment =
            data?['comment']; // Tambahkan tanda '?' sebelum ['comment']
        return comment;
      }).toList();

      return comments;
    } catch (error) {
      print('Terjadi kesalahan saat mengambil komentar: $error');
      return [];
    }
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
}
