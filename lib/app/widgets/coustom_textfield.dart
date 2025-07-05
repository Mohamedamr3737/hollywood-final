import 'package:flutter/material.dart';
import '../../general/consts/colors.dart';

class CoustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController? textcontroller;
  final Widget? icon;
  final Color? textcolor;
  final validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? label;
  final bool enabled;
  
  const CoustomTextField({
    super.key,
    required this.hint,
    this.textcontroller,
    this.icon,
    this.textcolor,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.label,
    this.enabled = true,
  });

  @override
  State<CoustomTextField> createState() => _CoustomTextFieldState();
}

class _CoustomTextFieldState extends State<CoustomTextField> {
  bool _isObscured = true;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused ? [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: TextFormField(
              controller: widget.textcontroller,
              obscureText: _isObscured,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              style: TextStyle(
                fontSize: 16,
                color: widget.enabled ? AppColors.textPrimary : AppColors.textLight,
              ),
              decoration: InputDecoration(
                prefixIcon: widget.icon != null 
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: widget.icon,
                      )
                    : null,
                suffixIcon: widget.obscureText
                    ? IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      )
                    : null,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: widget.textcolor ?? AppColors.textLight,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: widget.enabled ? AppColors.surfaceColor : AppColors.bgDarkColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.bgDarkColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.bgDarkColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.errorColor),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.errorColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: widget.validator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ),
      ],
    );
  }
}
