import 'package:flutter/material.dart';
import 'package:pcqi_app/models/machine_model.dart';
import 'package:pcqi_app/services/request_methods.dart';
import 'package:pcqi_app/widgets/custom_list_view_card.dart';

class Sectors extends StatefulWidget {
  const Sectors({super.key});

  @override
  State<Sectors> createState() => _SectorsState();
}

class _SectorsState extends State<Sectors> {
  List<MachineModel> machineList = [];
  late RequestMethods requestMethods;

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          List<MachineModel>? machineListFromServer = await requestMethods
              .getMachineList();
          if (machineListFromServer != null) {
            setState(() {
              machineList = machineListFromServer;
            });
          }
        },
        child: Center(
          child: ListView.builder(
            itemCount: machineList.length,
            itemBuilder: (BuildContext context, int index) {
              return CustomListViewCard(title: machineList[index].name!);
            },
          ),
        ),
      ),
    );
  }
}
