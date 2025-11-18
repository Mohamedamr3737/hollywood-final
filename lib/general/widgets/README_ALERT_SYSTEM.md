# Liquid Glass Alert System

A beautiful, unified alert system with liquid glass design for Flutter applications.

## Features

- 🎨 **Liquid Glass Design**: Beautiful glassmorphism effects with blur and transparency
- 🎭 **Smooth Animations**: Elastic slide-in and fade animations
- 🎯 **Unified API**: Single service for all alert types
- 🎨 **Color-coded**: Different colors for success, error, warning, and info
- ⏰ **Auto-dismiss**: Configurable duration with auto-dismiss
- 👆 **Tap to Dismiss**: Users can tap to dismiss alerts
- 📱 **Responsive**: Works on all screen sizes
- 🎪 **Customizable**: Easy to extend and modify

## Usage

### Basic Usage

```dart
import 'package:your_app/general/services/alert_service.dart';

// Success alert
AlertService.success(context, "Operation completed successfully!");

// Error alert
AlertService.error(context, "Something went wrong!");

// Warning alert
AlertService.warning(context, "Please check your input");

// Info alert
AlertService.info(context, "Here's some information");
```

### Advanced Usage

```dart
// Custom alert with specific type and duration
AlertService.show(
  context,
  message: "Custom message",
  type: AlertType.success,
  duration: Duration(seconds: 5),
  onTap: () => print("Alert tapped!"),
);

// Convenience methods for common scenarios
AlertService.loginSuccess(context);
AlertService.loginError(context);
AlertService.networkError(context);
AlertService.serverError(context);
AlertService.validationError(context, "Invalid input");
AlertService.operationSuccess(context, "save");
AlertService.operationError(context, "save");
```

## Alert Types

### AlertType.success
- Color: Green
- Icon: Check circle
- Use for: Successful operations, confirmations

### AlertType.error
- Color: Red
- Icon: Error
- Use for: Errors, failures, exceptions

### AlertType.warning
- Color: Orange
- Icon: Warning
- Use for: Warnings, validation errors

### AlertType.info
- Color: Blue
- Icon: Info
- Use for: Information, tips, general messages

## Customization

### Duration
```dart
AlertService.success(context, "Message", duration: Duration(seconds: 5));
```

### Custom Actions
```dart
AlertService.error(context, "Error occurred", onTap: () {
  // Custom action when alert is tapped
  Navigator.pop(context);
});
```

## Migration from VxToast and ScaffoldMessenger

### Before (VxToast)
```dart
VxToast.show(context, msg: "Login Successful");
```

### After (AlertService)
```dart
AlertService.loginSuccess(context);
```

### Before (ScaffoldMessenger)
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Error occurred")),
);
```

### After (AlertService)
```dart
AlertService.error(context, "Error occurred");
```

## Implementation Details

### Files Created
- `lib/general/widgets/liquid_glass_alert.dart` - Main alert widget
- `lib/general/services/alert_service.dart` - Service for managing alerts
- `lib/general/widgets/alert_demo.dart` - Demo page for testing

### Dependencies
- `dart:ui` - For ImageFilter.blur
- `flutter/material.dart` - For Flutter widgets

### Performance
- Uses Overlay for non-blocking alerts
- Efficient animations with AnimationController
- Auto-cleanup of overlay entries
- Minimal memory footprint

## Design Features

### Liquid Glass Effect
- BackdropFilter with blur effects
- Gradient backgrounds with transparency
- Subtle borders with opacity
- Box shadows for depth

### Animations
- Slide-in from top with elastic curve
- Fade-in/fade-out transitions
- Smooth dismiss animations
- Responsive to user interactions

### Accessibility
- High contrast colors
- Clear typography
- Touch-friendly targets
- Screen reader compatible

## Best Practices

1. **Use appropriate alert types**: Match the alert type to the message context
2. **Keep messages concise**: Short, clear messages work best
3. **Use convenience methods**: Leverage pre-built methods for common scenarios
4. **Test on different devices**: Ensure alerts work on various screen sizes
5. **Consider duration**: Longer messages may need longer display times

## Troubleshooting

### Common Issues
1. **Alerts not showing**: Ensure context is valid and not disposed
2. **Animation issues**: Check if AnimationController is properly disposed
3. **Overlay issues**: Ensure Overlay is available in the widget tree

### Debug Tips
- Use the demo page to test different alert types
- Check console for any error messages
- Verify imports are correct
- Ensure context is not null

## Future Enhancements

- [ ] Queue system for multiple alerts
- [ ] Custom positioning options
- [ ] Sound effects
- [ ] Haptic feedback
- [ ] Theme integration
- [ ] Localization support
