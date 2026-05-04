import 'package:amicons/amicons.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // Handle search action
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                // Handle profile action
              },
            ),
          ],
          title: Text(
            'Monsef App',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Handle FAB action
          },
          child: Icon(Icons.add),
        ),

        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Amicons.iconly_home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Amicons.iconly_category),
              label: 'Settings',
            ),
          ],
        ),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hello, World!', style: TextStyle(fontSize: 24)),
              SizedBox(height: 16),
              Text('Welcome to Flutter.', style: TextStyle(fontSize: 18)),
            ],
          ),

        ),
      ),
    );
  }
}
