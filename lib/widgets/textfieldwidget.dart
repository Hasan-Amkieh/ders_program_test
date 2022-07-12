
import 'package:flutter/material.dart';

import '../main.dart';

class TextFieldWidget extends StatefulWidget {

  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;

  const TextFieldWidget({
    Key? key,
    required this.text,
    required this.onChanged,
    required this.hintText
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TextFieldWidgetState();
  }

}

class TextFieldWidgetState extends State<TextFieldWidget> {
  final controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.text;
    print("Setting the controller text to ${widget.text}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final styleActive = TextStyle(color: Main.appTheme.titleTextColor);
    final styleHint = TextStyle(color: Main.appTheme.titleTextColor.withOpacity(0.9), fontSize: 12.0);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      height: 30,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Main.appTheme.textfieldBackgroundColor,
        border: Border.all(color: Colors.black26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: controller,
        cursorColor: Main.appTheme.normalTextColor,
        cursorWidth: 1.0,
        decoration: InputDecoration(
          iconColor: Main.appTheme.navIconColor,
          // suffixIcon: widget.text.isNotEmpty
          //     ? GestureDetector(
          //   child: Icon(Icons.close, color: style.color),
          //   onTap: () {
          //     controller.clear();
          //     widget.onChanged('');
          //     FocusScope.of(context).requestFocus(FocusNode());
          //   },
          // ) : null,
          hintText: widget.hintText,
          hintStyle: style,
          border: InputBorder.none,
        ),
        style: style,
        onChanged: widget.onChanged,
      ),
    );

  }

}
