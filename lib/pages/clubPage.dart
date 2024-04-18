import 'package:flutter/material.dart';
import 'package:sfbu_hub/models/models.dart';
import 'package:sfbu_hub/api_layer/api.dart' as api;

class ClubPage extends StatefulWidget {
  const ClubPage({super.key});

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  List<Event> events = [];
  bool isLoading = false;

  void refresh() async {
    setState(() {
      isLoading = true;
    });
    events = await api.GraphQlApi().getEvents();
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
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // set max height to 80% of the screen
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: events.isEmpty
                      ? const Center(
                          child: Text(
                            "No clubs Subscribed.",
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: events.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(events[index].name!),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  events[index].info != ""
                                      ? Text(
                                          "Event info: ${events[index].info!}")
                                      : const SizedBox.shrink(),
                                  events[index].date != ""
                                      ? Text("Date: ${events[index].date!}")
                                      : const SizedBox.shrink(),
                                  events[index].time != ""
                                      ? Text("Time: ${events[index].time!}")
                                      : const SizedBox.shrink(),
                                  events[index].location != ""
                                      ? Text(
                                          "Location: ${events[index].location!}")
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            );
                          },
                        )),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ClubEditPage()))
                      .then((value) => refresh());
                },
                child: const Text('Subscribe to Clubs'),
              ),
            ],
          );
  }
}

class ClubEditPage extends StatefulWidget {
  const ClubEditPage({super.key});

  @override
  State<ClubEditPage> createState() => _ClubEditPageState();
}

class _ClubEditPageState extends State<ClubEditPage> {
  List<Club> clubs = [];
  List<String> selectedClubs = [];
  bool isLoading = false;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() async {
    setState(() {
      isLoading = true;
    });
    clubs = await api.GraphQlApi().getClubs();
    selectedClubs = await api.GraphQlApi().getSubscribedClubs();

    print(selectedClubs);
    print(clubs);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: const Text("Subscribe to Clubs",
                  style: TextStyle(fontSize: 14.0)),
            ),
            body: clubs.isEmpty
                ? const Center(
                    child: Text(
                      "No clubs Subscribed.",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: clubs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(clubs[index].name!),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(clubs[index].name!),
                                  Checkbox(
                                    value:
                                        selectedClubs.contains(clubs[index].id),
                                    onChanged: (bool? value) {
                                      if (value!) {
                                        api.GraphQlApi()
                                            .addClub(clubs[index].id);
                                        selectedClubs.add(clubs[index].id);
                                      } else {
                                        api.GraphQlApi()
                                            .removeClub(clubs[index].id);
                                        selectedClubs.remove(clubs[index].id);
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ]),
                          ],
                        ),
                      );
                    },
                  ));
  }
}
