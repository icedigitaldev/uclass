import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCustom {
  static Widget buildTextField({
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Function(String)? onChanged,
    TextEditingController? controller,
    bool enabled = true,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    bool showPasswordToggle = false,
    VoidCallback? onTogglePassword,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters ?? [
        if (keyboardType == TextInputType.number)
          FilteringTextInputFormatter.digitsOnly,
      ],
      validator: validator,
      focusNode: focusNode,
      style: TextStyle(
        color: enabled ? Colors.black : Colors.grey,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: enabled ? Colors.grey[600] : Colors.grey[400],
        ),
        suffixIcon: showPasswordToggle
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
          onPressed: onTogglePassword,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[100] : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        counterText: '',
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  static Widget buildButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    double height = 48,
  }) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          disabledBackgroundColor: Colors.grey[300],
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onPressed == null ? Colors.grey[600] : textColor,
          ),
        ),
      ),
    );
  }
}