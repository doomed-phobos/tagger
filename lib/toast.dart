import "package:toastification/toastification.dart";
import 'package:flutter/material.dart';

const TOAST_DURATION = Duration(seconds: 3);

void show_error_toast(String text) {
  toastification.show(
    title: Text(text),
    type: .error,
    alignment: Alignment.bottomRight,
    autoCloseDuration: TOAST_DURATION,
  );
}

void show_success_toast(String text) {
  toastification.show(
    title: Text(text),
    type: .success,
    alignment: Alignment.bottomRight,
    autoCloseDuration: TOAST_DURATION,
  );
}

void show_warning_toast(String text) {
  toastification.show(
    title: Text(text),
    type: .warning,
    alignment: .bottomRight,
    autoCloseDuration: TOAST_DURATION
  );
}
