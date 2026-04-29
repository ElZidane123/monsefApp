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
            'Flutter Demo Home Page',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold),
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
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
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
