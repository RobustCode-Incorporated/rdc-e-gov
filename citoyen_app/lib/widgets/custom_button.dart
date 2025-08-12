import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  // ✅ Correction ici : onPressed est maintenant nullable
  final VoidCallback? onPressed; 

  const CustomButton({super.key, required this.text, this.onPressed}); // onPressed n'est plus required si il est nullable

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Cela fonctionne car onPressed peut être null
      child: Text(text),
    );
  }
}