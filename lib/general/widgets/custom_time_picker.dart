import 'package:flutter/material.dart';
import 'dart:ui';

class CustomTimePicker extends StatefulWidget {
  final List<String> timeOptions;
  final String? selectedTime;
  final Function(String?) onTimeSelected;
  final bool enabled;

  const CustomTimePicker({
    Key? key,
    required this.timeOptions,
    this.selectedTime,
    required this.onTimeSelected,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showTimePicker() {
    if (!widget.enabled) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Material(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(
                maxWidth: 400,
                maxHeight: 500,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.orangeAccent.withOpacity(0.1),
                                Colors.orangeAccent.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.access_time,
                                  color: Colors.orangeAccent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'Select Time',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Time Options
                        Flexible(
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: widget.timeOptions.length,
                              itemBuilder: (context, index) {
                                final time = widget.timeOptions[index];
                                final isSelected = widget.selectedTime == time;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        widget.onTimeSelected(time);
                                        Navigator.pop(context);
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.orangeAccent.withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.orangeAccent
                                                : Colors.grey.withOpacity(0.2),
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? Colors.orangeAccent
                                                    : Colors.grey.withOpacity(0.3),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                time,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? Colors.orangeAccent
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.orangeAccent,
                                                size: 20,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        
                        // Footer
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.withOpacity(0.1),
                                    foregroundColor: Colors.grey[700],
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: widget.selectedTime != null
                                      ? () => Navigator.pop(context)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.selectedTime != null
                                        ? Colors.orangeAccent
                                        : Colors.grey.withOpacity(0.3),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Confirm'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTimePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.enabled ? Colors.white : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.enabled
                ? (widget.selectedTime != null ? Colors.orangeAccent : Colors.grey[300]!)
                : Colors.grey[300]!,
            width: widget.selectedTime != null ? 2 : 1,
          ),
          boxShadow: widget.enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: widget.enabled
                  ? (widget.selectedTime != null ? Colors.orangeAccent : Colors.grey[600])
                  : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.selectedTime ?? 'Select Time',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.enabled
                      ? (widget.selectedTime != null ? Colors.black87 : Colors.grey[600])
                      : Colors.grey[400],
                  fontWeight: widget.selectedTime != null ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: widget.enabled
                  ? (widget.selectedTime != null ? Colors.orangeAccent : Colors.grey[600])
                  : Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
