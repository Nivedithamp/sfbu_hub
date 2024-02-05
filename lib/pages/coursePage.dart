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

  @override
  void initState() {
    super.initState();
    getCourse();
  }

  void getCourse() async {
    setState(() {
      isLoading = true;
    });
    courseResponse = await api.GraphQlApi().getCourses();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : courseResponse == null
            ? ElevatedButton(
                onPressed: getCourse,
                child: const Text('Courses'),
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
                            '${courseResponse!.courses![index].schdule_day!} ${courseResponse!.courses![index].schdule_time1!} - ${courseResponse!.courses![index].schdule_time2!}',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.green)),
                        trailing: courseResponse!.courses![index].location ==
                                null
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
