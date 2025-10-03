import 'package:flutter/material.dart';
import 'package:pcqi_app/services/request_methods.dart';

class ListaMaquinas extends StatefulWidget {
  const ListaMaquinas({super.key});

  @override
  State<ListaMaquinas> createState() => _ListaMaquinasState();
}

class _ListaMaquinasState extends State<ListaMaquinas> {
  List machineList = [];
  late RequestMethods requestMethods;

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: /*RefreshIndicator(
        onRefresh: () => requestMethods.getMachineList(),
        child:*/ Center(
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                title: Text("aa"),
                onTap: () {
                  //pushScreenWithoutNavBar(context, TesteCamera());
                },
              ),
            );
          },
        ),
      ),
    ) /*,
    )*/;
  }
}
