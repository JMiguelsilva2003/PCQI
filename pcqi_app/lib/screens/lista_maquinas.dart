import 'package:flutter/material.dart';

class ListaMaquinas extends StatefulWidget {
  const ListaMaquinas({super.key});

  @override
  State<ListaMaquinas> createState() => _ListaMaquinasState();
}

class _ListaMaquinasState extends State<ListaMaquinas> {
  List<String> a = [];
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < 30; i++) {
      a.add(i.toString());
    }
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: a.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                title: Text(a[index]),
                onTap: () {
                  //pushScreenWithoutNavBar(context, TesteCamera());
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
