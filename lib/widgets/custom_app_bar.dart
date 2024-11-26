import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;

  const CustomAppBar({Key? key, this.backgroundColor}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
    );
  }
}