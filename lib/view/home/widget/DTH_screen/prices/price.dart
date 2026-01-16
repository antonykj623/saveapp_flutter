import 'package:flutter/material.dart';

class  pageone extends StatefulWidget {
  const  pageone({super.key});

  @override
  State< pageone> createState() => pageoneState();
}

class pageoneState extends State< pageone>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override    
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}