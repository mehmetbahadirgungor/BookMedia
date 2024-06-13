import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class ToastWidget extends StatelessWidget {
  const ToastWidget({super.key, required this.content, required this.type});

  final String content;
  final bool type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: type ? Colors.greenAccent : Colors.red,
      ),
      child: Row(
        children: [
          type ? Icon(Icons.check) : Icon(Icons.close),
          SizedBox(
            width: 12.0,
          ),
          Expanded(child: Text(content)),
        ],
      ),
    );
  }
}

class MyToast {
  void show(String message, bool type, BuildContext context) {
    showToastWidget(ToastWidget(content: message, type: false),
        context: context,
        animation: StyledToastAnimation.slideFromTop,
        position: StyledToastPosition.top,
        duration: Duration(seconds: 4));
  }
}
