import 'package:flutter/material.dart';

class HeaderRounded extends StatelessWidget {
  final Widget child;

  const HeaderRounded({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blue, // Ubah warna latar belakang sesuai keinginan Anda
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
