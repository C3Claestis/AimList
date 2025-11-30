import 'package:flutter/material.dart';

class NotificationController {
  // Notifier global, default 0
  static final ValueNotifier<int> notificationCount = ValueNotifier<int>(0);
}
