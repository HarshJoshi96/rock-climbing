import 'package:flutter/material.dart';
import 'package:namer_app/core/utils/text_styles.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.activityDetailText});
  final String activityDetailText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Description",
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Nunito-Bold',
              fontSize: AppTextStyles.title.fontSize,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Text(activityDetailText,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Nunito',
                    fontSize: AppTextStyles.subtitle.fontSize)),
          ),
        ),
      ]),
    );
  }
}
