import 'package:flutter/material.dart';

class MessageDialog extends StatelessWidget {
  final String message;
  MessageDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      // ダイアログを上詰め表示
      children: [
        AlertDialog(
            content: Container(
          width: 200,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(message,
                    style: const TextStyle(
                      fontSize: 16,
                    )),
                const SizedBox(height: 5),
                TextButton(
                    onPressed: () {
                      // ダイアログを閉じる
                      Navigator.pop(context);
                    },
                    child: Text("Close",
                        style: TextStyle(
                          fontSize: 12,
                        )),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, // foreground
                      // fixedSize: Size(50.w, 20.h),
                      backgroundColor: Colors.black,
                      alignment: Alignment.topCenter,
                    )),
              ]),
        ))
      ],
    );
  }
}
