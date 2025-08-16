import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';

class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final images = [
      'assets/1.jpg',
      'assets/2.jpg',
      'assets/3.jpg',
      'assets/4.jpg',
      'assets/5.jpg',
    ];

    return SizedBox(
      height: 180,
      child: CarouselSlider.builder(
        slideBuilder: (index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              images[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          );
        },
        slideTransform: const DefaultTransform(),
        slideIndicator: CircularSlideIndicator(
          padding: EdgeInsets.only(bottom: 10),
        ),
        itemCount: images.length,
        autoSliderTransitionTime: const Duration(seconds: 1),
        enableAutoSlider: true,
      ),
    );
  }
}
