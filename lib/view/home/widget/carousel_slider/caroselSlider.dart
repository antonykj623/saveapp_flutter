import 'dart:math' as math;

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ModernCarouselSlider extends StatefulWidget {
  final List<String> images;
  final bool isDarkTheme;

  const ModernCarouselSlider({
    Key? key,
    required this.images,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  State<ModernCarouselSlider> createState() => _ModernCarouselSliderState();
}

class _ModernCarouselSliderState extends State<ModernCarouselSlider>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();
  late AnimationController _backgroundController;
  late AnimationController _indicatorController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _indicatorController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Container(
              height: 280,
              child: Stack(
                children: [
                  _buildAnimatedBackground(),
                  _buildCarouselContent(),
                  _buildModernIndicators(),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  widget.isDarkTheme
                      ? [
                        Color(0xFF1A1A2E).withOpacity(0.8),
                        Color(0xFF16213E).withOpacity(0.6),
                        Color(0xFF0F3460).withOpacity(0.8),
                      ]
                      : [
                        Color(0xFFE3FDFD).withOpacity(0.8),
                        Color(0xFFCBF1F5).withOpacity(0.6),
                        Color(0xFFA6E3E9).withOpacity(0.8),
                      ],
              transform: GradientRotation(
                _backgroundController.value * 2 * math.pi,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    widget.isDarkTheme
                        ? Colors.cyan.withOpacity(0.3)
                        : Colors.teal.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: Offset(
                  5 * math.sin(_backgroundController.value * 2 * math.pi),
                  5 * math.cos(_backgroundController.value * 2 * math.pi),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarouselContent() {
    return Container(
      margin: EdgeInsets.all(20),
      child: CarouselSlider.builder(
        carouselController: CarouselSliderController(),
        itemCount: widget.images.length,
        options: CarouselOptions(
          height: 240,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.85,
          aspectRatio: 16 / 9,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayAnimationDuration: const Duration(milliseconds: 1200),
          autoPlayCurve: Curves.elasticInOut,
          scrollDirection: Axis.horizontal,
          enableInfiniteScroll: true,
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
            _indicatorController.reset();
            _indicatorController.forward();
          },
        ),
        itemBuilder: (context, index, realIndex) {
          return _buildCarouselItem(widget.images[index], index);
        },
      ),
    );
  }

  Widget _buildCarouselItem(String imageUrl, int index) {
    bool isActive = index == _currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.symmetric(
        horizontal: isActive ? 5 : 10,
        vertical: isActive ? 10 : 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                widget.isDarkTheme
                    ? Colors.cyan.withOpacity(0.4)
                    : Colors.teal.withOpacity(0.4),
            blurRadius: isActive ? 25 : 15,
            spreadRadius: isActive ? 3 : 1,
            offset: const Offset(0, 10),
          ),
          if (isActive)
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: -5,
              offset: const Offset(0, -5),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Transform.scale(
              scale: isActive ? 1.05 : 1.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingWidget(loadingProgress);
                },
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(isActive ? 0.4 : 0.6),
                  ],
                ),
              ),
            ),
            if (isActive) _buildFloatingElements(),
            _buildContentOverlay(index, isActive),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: List.generate(6, (index) {
        return AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            double animValue = _backgroundController.value;
            double delay = index * 0.1;
            double offsetX = 30 * math.sin((animValue + delay) * 2 * math.pi);
            double offsetY = 20 * math.cos((animValue + delay) * 3 * math.pi);

            return Positioned(
              left: 20 + (index * 30) + offsetX,
              top: 20 + (index * 25) + offsetY,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildContentOverlay(int index, bool isActive) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isActive ? 1.0 : 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Text(
                'Slide ${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Modern Finance App',
              style: TextStyle(
                color: Colors.white,
                fontSize: isActive ? 18 : 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernIndicators() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            widget.images.asMap().entries.map((entry) {
              int index = entry.key;
              bool isActive = index == _currentIndex;

              return AnimatedBuilder(
                animation: _indicatorController,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: () {
                      CarouselSliderController().animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: isActive ? 40 : 12,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                        boxShadow:
                            isActive
                                ? [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.8),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                                : null,
                      ),
                      child:
                          isActive
                              ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.cyan.withOpacity(0.8),
                                      Colors.teal.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              )
                              : null,
                    ),
                  );
                },
              );
            }).toList(),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Positioned.fill(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                CarouselSliderController().previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                color: Colors.transparent,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                CarouselSliderController().nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                color: Colors.transparent,
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              widget.isDarkTheme
                  ? [Colors.grey.shade800, Colors.grey.shade600]
                  : [Colors.grey.shade300, Colors.grey.shade100],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.white, size: 40),
            SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              widget.isDarkTheme
                  ? [Colors.grey.shade800, Colors.grey.shade600]
                  : [Colors.grey.shade300, Colors.grey.shade100],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF008080),
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Loading...',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
