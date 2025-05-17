import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AllInOneScreen extends StatefulWidget {
  const AllInOneScreen({Key? key}) : super(key: key);

  @override
  State<AllInOneScreen> createState() => _AllInOneScreenState();
}

class _AllInOneScreenState extends State<AllInOneScreen> {
  final List<String> images = [
    'https://via.placeholder.com/600x300/008080/ffffff?text=Slide+1',
    'https://via.placeholder.com/600x300/20b2aa/ffffff?text=Slide+2',
    'https://via.placeholder.com/600x300/5f9ea0/ffffff?text=Slide+3',
  ];
  int _current = 0;
  // final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarouselSlider.builder(
            itemCount: images.length,
            itemBuilder: (context, index, realIndex) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            },
            // carouselController: _controller,
            options: CarouselOptions(
              height: 200,
              enlargeCenterPage: true,
              autoPlay: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                images.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _current == entry.key ? Colors.teal : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
