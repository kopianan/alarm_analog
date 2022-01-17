import 'package:analog_alarm/domain/am_pm_model.dart';
import 'package:flutter/material.dart';

class pmAmWidget extends StatelessWidget {
  const pmAmWidget({Key? key, required this.amPmModel}) : super(key: key);
  final AmPmModel amPmModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
      decoration: amPmModel.isActive
          ? BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(6))
          : null,
      child: Text(
        amPmModel.label,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
