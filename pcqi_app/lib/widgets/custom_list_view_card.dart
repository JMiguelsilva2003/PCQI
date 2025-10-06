import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/models/machine_model.dart';

class CustomSectorViewCard extends StatelessWidget {
  final String name;
  final String description;
  final List<MachineModel> machines;

  const CustomSectorViewCard({
    super.key,
    required this.name,
    required this.description,
    required this.machines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
            child: Column(
              children: [
                Text(
                  name,
                  style: AppStyles.textStyleCustomListViewCard,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  description,
                  style: AppStyles.textStyleCustomListViewCard,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
