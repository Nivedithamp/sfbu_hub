import 'package:flutter/material.dart';
import 'package:sfbu_hub/api_layer/api.dart' as api;
import 'package:sfbu_hub/pages/coursePage.dart';
import 'package:sfbu_hub/pages/chatPage.dart';
import 'package:sfbu_hub/pages/assignmentPage.dart';
import 'package:sfbu_hub/pages/clubPage.dart';

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Center(
              child: Container(
            width: 80,
            height: 80,
            child: Image.network(
                'https://www.sfbu.edu/sites/default/files/SFBU-logo_0.png'),
          ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          api.LocalStorageApi().clearLocal();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.assignment_outlined)),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Badge(
              child: Icon(Icons.messenger_sharp),
            ),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Badge(
              child: Icon(Icons.local_activity_rounded),
            ),
            label: 'Clubs',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        const CoursePage(),

        /// Notifications page
        const AssignmentPage(),

        /// Messages page
        const ChatPage(),

        const ClubPage(),
      ][currentPageIndex],
    );
  }
}
