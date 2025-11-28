import 'package:flutter/material.dart';
import 'package:music_player/music_player_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Music",
      home: MusicPlayerScreen(),
      theme: ThemeData(colorSchemeSeed: Colors.deepPurpleAccent),
    );
  }
}
