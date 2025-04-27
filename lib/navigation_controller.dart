import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:mascotas_citas/Modules/ChatModule/Views/chat_screen.dart';
import 'package:mascotas_citas/Modules/HomeModule/Views/home_screen.dart';
import 'package:mascotas_citas/Modules/MatchesModule/Views/matches_screen.dart';
import 'package:mascotas_citas/Modules/ProfileModule/Views/perfil_screen.dart';
import 'package:mascotas_citas/Modules/SocialModule/Views/social_screen.dart';
=======
>>>>>>> dev-rodrigo


class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  _NavigationControllerState createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _selectedIndex = 0;
  
  // Método para obtener las pantallas, asegurando que tengan acceso a los providers
  List<Widget> _getScreens() => [
   
  ];

  @override
  Widget build(BuildContext context) {
    // Obtenemos las pantallas en el momento de construir el widget
    final screens = _getScreens();
    
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