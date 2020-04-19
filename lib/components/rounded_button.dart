import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color colour;

  RoundedButton({this.text,this.colour,this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: this.colour,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: () {
            this.onPressed();
          },
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            this.text,
          ),
        ),
      ),
    );
  }
}
