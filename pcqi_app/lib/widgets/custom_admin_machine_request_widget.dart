import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/models/app_enums.dart';

class CustomAdminMachineRequestWidget extends StatelessWidget {
  final String text;
  final RequestTypeAdminMachineControl requestType;
  final RequestStatusAdminMachineControl requestStatus;
  final Color backgroundColor;
  final Color circularProgressIndicatorColor;

  const CustomAdminMachineRequestWidget({
    super.key,
    required this.text,
    required this.requestType,
    required this.requestStatus,
    required this.backgroundColor,
    required this.circularProgressIndicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (requestType != RequestTypeAdminMachineControl.none)
            SizedBox(
              width: AppStyles.textStyleStreamingState.fontSize! * 1.7,
              height: AppStyles.textStyleStreamingState.fontSize! * 1.7,
              child: CircularProgressIndicator(
                color: AppColors.preto,
                strokeWidth: 2,
              ),
            ),
          SizedBox(width: 5),
          Text(text, style: AppStyles.textStyleStreamingState),
        ],
      ),
    );
  }
}
