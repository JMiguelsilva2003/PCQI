import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_styles.dart';

class CustomListViewCard extends StatelessWidget {
  String title;

  CustomListViewCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
            child: Text(
              title,
              style: AppStyles.textStyleCustomListViewCard,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
