import 'package:flutter/material.dart';
import 'screens/minesweeper_home_page.dart'; // Import home page

void main() {
  runApp(MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mayın Tarlası',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MinesweeperHomePage(), // Set home page
    );
  }
}
