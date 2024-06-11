import 'package:flutter/material.dart';
import 'package:listview_test/future/home_future_page.dart';
import 'package:listview_test/provider/home_provider_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const HomeFuturePage(title: "Flutter Demo Home Page"), //** 使用 FutureBuilder */
      home: const HomeProviderPage(
          title: "Flutter Demo Home Page"), //** 使用 rxdart + provider */
    );
  }
}
