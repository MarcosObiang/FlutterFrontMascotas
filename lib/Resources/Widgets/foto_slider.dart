// widgets/foto_slider.dart
import 'package:flutter/material.dart';

class FotoSlider extends StatefulWidget {
  final List<String> fotos;
  
  const FotoSlider({super.key, required this.fotos});
  
  @override
  _FotoSliderState createState() => _FotoSliderState();
}

class _FotoSliderState extends State<FotoSlider> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.fotos.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Image.asset(
              widget.fotos[index],
              fit: BoxFit.cover,
            );
          },
        ),
        if (widget.fotos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.fotos.length,
                (index) => _buildIndicator(index == _currentIndex),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.pink : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}