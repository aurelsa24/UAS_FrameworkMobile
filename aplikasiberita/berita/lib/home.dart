import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'komentar.dart'; // Import halaman komentar
void main() { //fungsi utama saat aplikasi flutter akan dijalankan 
  runApp(NewsApp()); //fungsi yang digunakan untuk menjalankan aplikasi NewsApp
}

class NewsApp extends StatefulWidget { //class yang digunakan untuk mengelola state dari NewsApp
  @override
  _NewsAppState createState() => _NewsAppState(); 
}

class _NewsAppState extends State<NewsApp> {
  List<dynamic> _articles = []; //aftar artikel yang diambil dari API berita. Tipe datanya adalah List<dynamic>, yang berarti daftar ini dapat berisi objek dengan tipe data apa pun.
  List<dynamic> _filteredArticles = []; //daftar artikel yang telah difilter berdasarkan pencarian pengguna. Awalnya, daftar ini sama dengan _articles (daftar lengkap artikel) karena belum ada filter yang diterapkan. Tipe datanya juga List<dynamic>.

  TextEditingController _searchController = TextEditingController();//digunakan untuk mengontrol teks yang dimasukkan ke dalam sebuah TextField.

  Future<void> _fetchNews() async {//sebuah fungsi yang digunakan untuk mengambil data berita dari API menggunakan HTTP request.
    final String url =
        'https://newsapi.org/v2/top-headlines?country=id&apiKey=8267b111ac554a7483295538b966f9f3';//URL API berita ditentukan sebagai string yang disimpan dalam variabel url
    final response = await http.get(Uri.parse(url)); //digunakan untuk menunggu hingga permintaan selesai dan responsenya diterima.
    final responseData = json.decode(response.body); //response.body berisi data berita dalam format JSON. Data JSON ini di-decode menggunakan json.decode() sehingga menjadi objek atau tipe data Dart yang dapat digunakan.

    setState(() { //digunakan untuk memperbarui state aplikasi dengan nilai baru
      _articles = responseData['articles']; //objek hasil dekodean JSON yang mengandung data berita yang diperoleh dari API.
      _filteredArticles = _articles; //diisi dengan semua artikel yang diperoleh dari API tanpa filter, sehingga sama dengan _articles.
    });
  }

  @override
  void initState() { //Metode ini dipanggil oleh framework Flutter saat widget pertama kali dibuat dan diinisialisasi.
    super.initState(); //memanggil metode initState() dari superclass State untuk menjalankan kode yang diperlukan oleh State yang sedang diinisialisasi.
    _fetchNews(); //mengambil data berita dari API dan memperbarui state aplikasi. Ini dilakukan saat widget pertama kali dibuat agar data berita tersedia sejak awal.
  }

  void _launchURL(String url) async { // sebuah fungsi yang digunakan untuk meluncurkan (launch) URL menggunakan package url_launcher
    if (await canLaunch(url)) { //untuk memeriksa apakah aplikasi dapat meluncurkan URL tersebut. Fungsi canLaunch() dari url_launcher mengembalikan true jika aplikasi dapat meluncurkan URL, dan false jika tidak.
      await launch(url); //digunakan untuk meluncurkan URL ke aplikasi eksternal yang sesuai.
    } else { 
      throw 'Could not launch $url'; //Jika aplikasi tidak dapat meluncurkan URL, kita melemparkan (throw) sebuah error dengan pesan "Could not launch $url".
    }
  }

  void _filterArticles(String searchText) { //sebuah fungsi yang digunakan untuk melakukan filter pada daftar artikel berdasarkan teks pencarian yang diberikan.
    setState(() { //digunakan untuk memperbarui state aplikasi sehingga perubahan tersebut akan direfleksikan di tampilan
      _filteredArticles = _articles.where((article) { //untuk memfilter artikel-artikel tersebut berdasarkan kriteria yang ditentukan dalam fungsi yang diberikan sebagai parameter.
        //memeriksa apakah teks pencarian (searchText) ada dalam judul artikel (title), nama sumber artikel (sourceName), atau penulis artikel (author). 
        //Variabel title, sourceName, dan author diubah menjadi lowercase untuk memastikan pencarian bersifat case-insensitive.
        final title = article['title'].toString().toLowerCase();
        final sourceName = article['source']['name'].toString().toLowerCase();
        final author = article['author'].toString().toLowerCase();
        //Jika salah satu dari kondisi pencarian terpenuhi, artikel akan tetap disertakan dalam hasil filter.
        return title.contains(searchText.toLowerCase()) ||
            sourceName.contains(searchText.toLowerCase()) ||
            author.contains(searchText.toLowerCase());
      }).toList(); //Hasil filter kemudian dikonversi menjadi daftar (List)
    });
  }

  void _openNewPage(BuildContext context) {//sebuah fungsi yang digunakan untuk membuka halaman baru atau rute baru dalam aplikasi.
    Navigator.push(//menggunakan navigator untuk melakukan perpindahan ke halaman baru
      context,
      MaterialPageRoute(
        builder: (context) => KomentarPage(),//aplikasi akan berpindah ke halaman baru yang ditentukan oleh KomentarPage().
      ),
    );
  }

  @override
   Widget build(BuildContext context) { //metode yang diperlukan dalam setiap widget yang ingin dirender ke layar dalam aplikasi Flutter.
    return MaterialApp( 
      title: 'Aplikasi Berita', //memberikan judul "Aplikasi Berita" untuk aplikasi.
      theme: ThemeData(primarySwatch: Colors.pink), //memberikan tema yang digunakan dalam aplikasi
      home: Scaffold( //kita memberikan widget Scaffold sebagai halaman utama aplikasi.
        appBar: AppBar( //adalah bilah atas yang menampilkan judul aplikasi.
          title: Text('Aplikasi Berita'), //menampilkan teks "Aplikasi Berita" sebagai judul aplikasi.
        ),
        body: Column( //digunakan untuk menentukan konten utama yang akan ditampilkan di dalam Scaffold.
          children: [ //beberapa children widgets yang ditampilkan dalam bentuk array.
            Padding( //digunakan untuk memberikan jarak atau padding di sekitar TextField.
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _filterArticles(value); //dipanggil untuk melakukan filter pada artikel berdasarkan teks pencarian yang dimasukkan.
                },
                decoration: InputDecoration(
                  hintText: 'Cari berita...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = _filteredArticles[index];
                  return Column(
                    children: [
                      Card(
                        margin: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(article['title'] ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Source: ${article['source']['name'] ?? ''}',
                                  ),
                                  Text('Author: ${article['author'] ?? ''}'),
                                  Text(
                                    'Published At: ${article['publishedAt'] ?? ''}',
                                  ),
                                  SizedBox(height: 8.0),
                                  TextButton(
                                    onPressed: () {
                                      String url = article['url'];
                                      _launchURL(url);
                                    },
                                    child: Text(
                                      'Read More',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(
                                  'Komentar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    _openNewPage(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.pink,
                                  ),
                                  child: Text(
                                    'Add',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


