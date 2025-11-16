import 'package:flutter/material.dart';

class Pagina2 extends StatelessWidget {
  const Pagina2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagina2')),
      body: const Center(
        child: Text('🏠 Esta es la Pagina2', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
