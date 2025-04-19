import 'package:flutter/material.dart';
import 'modules/ChatModule/Views/chat_screen.dart';
import 'modules/HomeModule/Views/home_screen.dart';
import 'modules/MatchesModule/Views/matches_screen.dart';
import 'modules/SocialModule/Views/social_screen.dart';
import 'modules/ProfileModule/Views/perfil_screen.dart';

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  _NavigationControllerState createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _selectedIndex = 0;
  
  // Método para obtener las pantallas, asegurando que tengan acceso a los providers
  List<Widget> _getScreens(BuildContext context) => [
    HomeScreen(),
    MatchesScreen(),
    SocialScreen(),
    ChatScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Obtenemos las pantallas en el momento de construir el widget
    final screens = _getScreens(context);
    
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Descubrir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}