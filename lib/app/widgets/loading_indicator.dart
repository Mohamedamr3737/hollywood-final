import '/general/consts/consts.dart';

class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;
  
  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color ?? AppColors.primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
