// splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mascotas_citas/Modules/Authentication/views/AuthScreen.dart'; // Importar AuthScreen en lugar de LoginScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    
    _animationController.forward();
    
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacementNamed('/authScreen'); // Usar la ruta definida
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 217, 208, 1),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logos/logo_wildlove_nombre.png',
                width: 450,
                height: 450,
              ),
              const SizedBox(height: 10),
              const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(
                    255,
                    255,
                    0,
                    0
                  )
                ),
              ),
              
              const SizedBox(height: 10),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Encuentra el compañero perfecto para tu mascota',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,                  
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}