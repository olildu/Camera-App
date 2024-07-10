import 'package:flutter/material.dart';
import 'package:flutter_assignment/main_pages/record_video.dart';
import 'package:flutter_assignment/main_pages/view_videos.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int bottomBarIndex = 0;
  
  final List<Widget> _pages = [
    const ViewVideos(),
  ];

  Future<void> changePages(int index) async {
    switch (index){
      case 0:
        setState(() {
          bottomBarIndex = index;
        });
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraApp()),
        );
        break;
      case 2:
              setState(() {
          bottomBarIndex = 0;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AppName"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
      ),
      body: _pages[bottomBarIndex],
 
      bottomNavigationBar: GNav(
        onTabChange: (index) {
          changePages(index);
        },
        selectedIndex: 0,
        tabs: const [
          GButton(
            icon: Icons.explore,
          ),
          GButton(
            icon: Icons.add,
          ),
          GButton(
            icon: Icons.library_books,
          ),
        ],
      ),
    );
  }
}
