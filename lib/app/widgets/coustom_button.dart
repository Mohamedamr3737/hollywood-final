import '../../general/consts/consts.dart';

class CoustomButton extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;
  
  const CoustomButton({
    super.key, 
    required this.onTap, 
    required this.title,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: !isOutlined ? [
          BoxShadow(
            color: (backgroundColor ?? AppColors.primaryColor).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined 
              ? Colors.transparent 
              : (backgroundColor ?? AppColors.primaryColor),
          foregroundColor: isOutlined 
              ? (textColor ?? AppColors.primaryColor)
              : (textColor ?? Colors.white),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutlined 
                ? BorderSide(color: backgroundColor ?? AppColors.primaryColor, width: 2)
                : BorderSide.none,
          ),
        ),
        onPressed: isLoading ? null : onTap,
        child: isLoading 
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOutlined ? AppColors.primaryColor : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOutlined 
                          ? (textColor ?? AppColors.primaryColor)
                          : (textColor ?? Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
