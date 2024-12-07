import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final String courseName;
  final VoidCallback onPressed;

  const AddButton({
    Key? key,
    required this.courseName,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.person_add, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}