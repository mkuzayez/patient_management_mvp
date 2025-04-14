import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastificationDialog {
  static showToast({
    required String msg,
    required BuildContext context,
    required ToastificationType type,
  }) {
    toastification.show(
      context: context,
      title: Text(msg, maxLines: 3),
      autoCloseDuration: const Duration(milliseconds: 2000),
      animationDuration: const Duration(milliseconds: 150),
      applyBlurEffect: false,
      pauseOnHover: true,
      type: type,
      borderSide: const BorderSide(width: 0),
      margin: const EdgeInsets.all(14),
      showProgressBar: false,
      alignment: Alignment.center,
      showIcon: true,
      // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      // borderRadius: BorderRadius.circular(16),
      // closeButtonShowType: CloseButtonShowType.none,
      style: ToastificationStyle.flat,

    );
  }
}
