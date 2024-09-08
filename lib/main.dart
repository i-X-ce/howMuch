import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:namer_app/coin_manager.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

const String appTitle = 'お支払い技術検定ソルバー';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CoinState(),
      child: MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.yuseiMagicTextTheme(),
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 0, 119, 255)),
        ),
        title: appTitle,
        home: myHomePage(),
      ),
    );
  }
}

class myHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle, style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ListView(
          children: [
            InputContent(),
            CoinDisplayContent(),
            CoinManipulatorContent(),
          ],
        ),
      ),
    );
  }
}
