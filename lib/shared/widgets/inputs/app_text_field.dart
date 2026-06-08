// MoneyBuddy
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';

/// Reusable auth text field with label, prefix icon, and optional
/// password visibility toggle. Supports both plain and obscured input.
///
/// For password fields, pass [obscureText] and [toggleObscureText].
/// For plain fields like email, leave [toggleObscureText] null.
class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final TextEditingController controller;
  final RxBool? obscureText;
  final VoidCallback? toggleObscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final int? maxLines;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.icon,
    this.obscureText,
    this.toggleObscureText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 6),
        obscureText != null
            ? Obx(() => _buildField(obscureText!.value))
            : _buildField(false),
      ],
    );
  }

  Widget _buildField(bool isObscured) {
    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      keyboardType: keyboardType,
      enabled: enabled,
      onChanged: onChanged,
      validator: validator,
      maxLines: isObscured ? 1 : maxLines,
      style: AppTextStyles.inputValue,
      cursorColor: AppColors.kPrimary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.inputHint,
        filled: true,
        fillColor: AppColors.kInputFill,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.kTextHint, size: 20)
            : null,
        suffixIcon: toggleObscureText != null
            ? IconButton(
                icon: Icon(
                  isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.kTextHint,
                  size: 20,
                ),
                onPressed: toggleObscureText,
              )
            : null,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.kBorder),
          borderRadius: AppRadius.input,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.kBorderActive,
            width: 1.5,
          ),
          borderRadius: AppRadius.input,
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.kBorderError),
          borderRadius: AppRadius.input,
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.kBorderError,
            width: 1.5,
          ),
          borderRadius: AppRadius.input,
        ),
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.kBorder),
          borderRadius: AppRadius.input,
        ),
      ),
    );
  }
}