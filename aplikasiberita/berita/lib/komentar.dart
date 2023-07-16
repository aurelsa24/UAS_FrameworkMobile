import 'package:flutter/material.dart'; //impor yang mengimpor pustaka flutter/material.dart, yang merupakan bagian dari Flutter SDK. Pustaka ini berisi kelas-kelas yang digunakan untuk membangun antarmuka pengguna dengan menggunakan Material Design.
import 'package:cloud_firestore/cloud_firestore.dart'; //mengimpor pustaka cloud_firestore.dart dari paket cloud_firestore. Pustaka ini adalah bagian dari Firebase SDK untuk Flutter dan digunakan untuk berinteraksi dengan Firebase Cloud Firestore, layanan basis data NoSQL yang ditawarkan oleh Firebase.

class KomentarPage extends StatefulWidget { //definisi kelas KomentarPage yang mengimplementasikan sebuah halaman komentar. Kelas ini adalah stateful widget, yang berarti dapat berubah dan merender ulang tampilan berdasarkan perubahan internalnya.
  @override
  _KomentarPageState createState() => _KomentarPageState();
}

class _KomentarPageState extends State<KomentarPage> { //definisi kelas _KomentarPageState yang merupakan state dari KomentarPage. Kelas ini memperluas kelas State<KomentarPage> dan berfungsi untuk mengatur dan memperbarui keadaan internal halaman komentar.
  TextEditingController _textController = TextEditingController(); //pembuatan objek TextEditingController yang digunakan untuk mengendalikan teks yang dimasukkan pengguna dalam TextField pada baris berikutnya.
  late CollectionReference<Map<String, dynamic>> _commentsCollection; //deklarasi variabel _commentsCollection yang akan digunakan untuk menyimpan referensi ke koleksi 'comments' di Firebase Cloud Firestore. Variabel ini menggunakan tipe CollectionReference<Map<String, dynamic>> yang merupakan tipe Firebase untuk merepresentasikan koleksi dokumen dengan tipe data Map<String, dynamic>.

  @override
  void initState() { //method yang merupakan bagian dari siklus hidup widget. Method ini dipanggil saat widget diinisialisasi. Di dalam method ini, _commentsCollection diinisialisasi dengan referensi ke koleksi 'comments' di Firestore.
    super.initState(); 
    _commentsCollection = FirebaseFirestore.instance.collection('comments');
  }

  @override
  void dispose() { //method yang merupakan bagian dari siklus hidup widget. Method ini dipanggil saat widget dihapus dari pohon widget. Di dalam method ini, _textController dibersihkan agar tidak memori bocor.
    _textController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async { //method yang akan dipanggil ketika tombol "Tambah Komentar" ditekan. Method ini mengambil nilai teks dari _textController, memeriksa apakah komentar tidak kosong, dan kemudian menambahkan dokumen baru ke koleksi 'comments' di Firestore dengan menggunakan nilai komentar dan timestamp saat ini.
    final String comment = _textController.text.trim();

    if (comment.isNotEmpty) {
      try {
        await _commentsCollection.add({
          'comment': comment,
          'timestamp': DateTime.now(),
        });

        _textController.clear();
      } catch (error) {
        print('Terjadi kesalahan saat menambahkan komentar: $error');
      }
    }
  }

  Future<void> _editComment(String commentId, String currentComment) async { //method yang akan dipanggil ketika tombol edit pada setiap komentar ditekan. Method ini menampilkan dialog pengeditan yang memungkinkan pengguna mengubah komentar yang ada. Setelah pengguna menekan tombol "Simpan", komentar yang diperbarui akan diupdate di Firestore.
    final String? updatedComment = await showDialog<String>(
      context: context,
      builder: (context) {
        final TextEditingController textEditingController =
            TextEditingController(text: currentComment);

        return AlertDialog(
          title: Text('Edit Komentar'),
          content: TextField(
            controller: textEditingController,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final String updatedComment = textEditingController.text.trim();
                Navigator.pop(context, updatedComment);
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (updatedComment != null && updatedComment.isNotEmpty) {
      try {
        await _commentsCollection
            .doc(commentId)
            .update({'comment': updatedComment});
      } catch (error) {
        print('Terjadi kesalahan saat mengedit komentar: $error');
      }
    }
  }

  Future<void> _deleteComment(String commentId) async { //method yang akan dipanggil ketika tombol hapus pada setiap komentar ditekan. Method ini menghapus komentar dengan menggunakan commentId yang diberikan dari koleksi 'comments' di Firestore.
    try {
      await _commentsCollection.doc(commentId).delete();
    } catch (error) {
      print('Terjadi kesalahan saat menghapus komentar: $error');
    }
  }

  @override
  Widget build(BuildContext context) { //method yang mendefinisikan tampilan halaman komentar. Di dalam method ini, widget Scaffold digunakan sebagai kerangka tampilan utama halaman, termasuk AppBar dan body
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Komentar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Masukkan komentar...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addComment,
            child: Text('Tambah Komentar'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _commentsCollection
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan saat mengambil data'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('Belum ada komentar'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final document = snapshot.data!.docs[index];
                    final commentId = document.id;
                    final comment = document['comment'] as String;

                    return Card(
                      child: ListTile(
                        title: Text(comment),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editComment(commentId, comment),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteComment(commentId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
