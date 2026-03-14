import 'package:flutter/material.dart';
import 'pages/mahasiswa_pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite 23106050024',
      home: MahasiswaPage(),
    );
  }
}