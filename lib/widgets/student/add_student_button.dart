import 'package:flutter/material.dart';

class AddStudentButton extends StatelessWidget {
  final Color courseColor;
  final VoidCallback onPressed;

  const AddStudentButton({
    super.key,
    required this.courseColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: courseColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.person_add, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}