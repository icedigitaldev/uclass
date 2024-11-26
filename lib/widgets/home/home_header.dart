import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onLogoutPressed;

  const HomeHeader({
    super.key,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Hola, Admin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: onLogoutPressed,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}