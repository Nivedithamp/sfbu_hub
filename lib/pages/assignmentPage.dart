import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:sfbu_hub/models/models.dart';
import 'package:sfbu_hub/api_layer/api.dart' as api;

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  List<Assignment> assignments = [];
  bool isLoading = false;

  void refresh() async {
    setState(() {
      isLoading = true;
    });
    assignments = await api.GraphQlApi().getAssignments();
    assignments.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(assignments[index].name!),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(DateFormat('yyyy-MM-dd hh:mm a')
                        .format(DateTime.parse(assignments[index].dueDate!))),
                    Text(assignments[index].description!.split(" ")[0]),
                  ],
                ),
                trailing: assignments[index].isSubmitted!
                    ? const Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                    : DateTime.parse(assignments[index].dueDate!)
                            .isBefore(DateTime.now())
                        ? const Icon(
                            Icons.alarm,
                            color: Colors.red,
                            semanticLabel: "Late",
                          )
                        : const Icon(Icons.pending_actions,
                            color: Colors.orange),
              );
            });
  }
}
