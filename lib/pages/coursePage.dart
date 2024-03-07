import 'package:flutter/material.dart';
import 'package:sfbu_hub/models/models.dart';
import 'package:sfbu_hub/api_layer/api.dart' as api;

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => CoursePageState();
}

class CoursePageState extends State<CoursePage> {
  CourseResponse? courseResponse;
  bool isLoading = false;
  bool hasCanvasToken = false;
  final TextEditingController _canvasTokenController = TextEditingController();

  @override
  void initState() {
    getCourse();
    super.initState();
  }

  void getCourse() async {
    setState(() {
      isLoading = true;
    });

    hasCanvasToken = await api.GraphQlApi().hasCanvasToken();
    print(hasCanvasToken);
    if (hasCanvasToken) {
      courseResponse = await api.GraphQlApi().getCourses();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : hasCanvasToken == false
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                          "You need to add your Canvas token to view your courses.",
                          style: TextStyle(fontSize: 20)),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "Canvas Token",
                        ),
                        controller: _canvasTokenController,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await api.GraphQlApi()
                              .setCanvasToken(_canvasTokenController.text);
                          getCourse();
                        },
                        child: const Text("Add Token"),
                      )
                    ]),
              )
            : ListView.builder(
                itemCount: courseResponse!.courses!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(courseResponse!.courses![index].name!,
                            style: const TextStyle(fontSize: 15)),
                        subtitle: Text(
                            '${courseResponse!.courses![index].schedule_day!} ${courseResponse!.courses![index].schedule_time1!} - ${courseResponse!.courses![index].schedule_time2!}',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.green)),
                        trailing: (courseResponse!.courses![index].location ??
                                    "null") ==
                                "null"
                            ? const Text("Online",
                                style:
                                    TextStyle(fontSize: 15, color: Colors.red))
                            : Text(courseResponse!.courses![index].location!,
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.red)),
                      ));
                },
              );
  }
}
