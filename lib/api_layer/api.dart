import 'dart:math';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sfbu_hub/api_layer/graphql_config.dart';
import 'package:sfbu_hub/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQlApi {
  static final GraphQLConfig _graphQLConfig = GraphQLConfig();
  final GraphQLClient _client = _graphQLConfig.clientToQuery();
  final GraphQLClient _subscriptionClient =
      _graphQLConfig.clientToSubscription();

  Future<LoginResponse> getOtp(String email) async {
    final String getOtp = """
      query {
        otpRequest(email: "$email") {
          token,
          error,
          error_message
        }
      }
    """;
    print(email);
    final QueryOptions options = QueryOptions(
      document: gql(getOtp),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    print(result.data!['otpRequest']);
    return LoginResponse.fromJson(result.data!['otpRequest']);
  }

  Future<LoginResponse> login(String email, String otp) async {
    final String login = """
      query {
        login(email: "$email", otp: "$otp") {
          token,
          error,
          error_message
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(login),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    return LoginResponse.fromJson(result.data!['login']);
  }

  Future<CourseResponse> getCourses() async {
    final String token = (await LocalStorageApi().getLoginToken())!;
    final String email = (await LocalStorageApi().getEmail())!;
    final String getCourses = """
      query {
        getCourses(token: "$token", email: "$email") {
            courses {
              id,
              name,
              is_public,
              schedule_day,
              schedule_time1,
              schedule_time2,
              location
            },
            error,
            error_message
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(getCourses),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    CourseResponse courseResponse =
        CourseResponse.fromJson(result.data!['getCourses']);
    if (courseResponse.error! &&
        courseResponse.error_message == "Invalid token") {
      LocalStorageApi().clearLocal();
    }
    // print(result.data!['getCourses']);
    return courseResponse;
  }

  Future<LoginResponse> setCanvasToken(String canvas_token) async {
    final String token = (await LocalStorageApi().getLoginToken())!;
    final String email = (await LocalStorageApi().getEmail())!;

    final String setCanvasToken = """
      mutation {
        setCanvasToken(email: "$email", token: "$token", canvas_token: "$canvas_token") {
          token,
          error,
          error_message
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(setCanvasToken),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      // print(result.exception.toString());
      throw Exception(result.exception.toString());
    }

    // print(result.data!['setCanvasToken']);

    return LoginResponse.fromJson(result.data!['setCanvasToken']);
  }

  Future<bool> hasCanvasToken() async {
    final String token = (await LocalStorageApi().getLoginToken())!;
    final String email = (await LocalStorageApi().getEmail())!;
    final String query = """
      query {
        hasCanvasToken(email: "$email", token: "$token") {
          has_canvas_token
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      print("error");
      LocalStorageApi().clearLocal();
      throw Exception(result.exception.toString());
    }

    return result.data!['hasCanvasToken']['has_canvas_token'];
  }

  Future<List<ChatGroup>> getChatGroups() async {
    final String token = (await LocalStorageApi().getLoginToken())!;
    final String email = (await LocalStorageApi().getEmail())!;
    final String query = """
      query {
        getCourses(email: "$email", token: "$token") {
          courses{
            id,
            name,
            members {
              name,
              email
            }
          }
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    return _client.query(options).then((result) {
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      List<ChatGroup> chatGroups = [];
      for (var course in result.data!['getCourses']['courses']) {
        List<ChatMember> members = [];
        for (var member in course['members']) {
          members.add(ChatMember.fromJson(member));
        }
        chatGroups.add(ChatGroup(
          id: course['id'],
          name: course['name'],
          members: members,
        ));
      }

      return chatGroups;
    });
  }

  Future<List<ChatMessage>> getChatMessages(String groupId) async {
    final String query = """
      query {
        getChatMessages(course_id: "$groupId") {
          message,
          sender_name,
          sender_email,
          group_id,
          created_at
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    return _client.query(options).then((result) {
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      List<ChatMessage> chatMessages = [];
      for (var message in result.data!['getChatMessages']) {
        chatMessages.add(ChatMessage.fromJson(message));
      }

      return chatMessages;
    });
  }

  Future<String> getShortName() async {
    final String email = (await LocalStorageApi().getEmail())!;
    final String token = (await LocalStorageApi().getLoginToken())!;
    final String query = """
      query {
        user(email: "$email", token: "$token") {
          short_name
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['user']['short_name'];
  }

  Future<LoginResponse> sendMessage(String text, String groupId) async {
    final String email = (await LocalStorageApi().getEmail())!;
    final String name = (await LocalStorageApi().getShortName())!;
    final String query = """
      mutation {
        addChatMessage(sender_email: "$email", sender_name: "$name", message: "$text", course_id: "$groupId") {
          error,
          error_message
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return LoginResponse.fromJson(result.data!['sendMessage']);
  }

  Future<List<Assignment>> getAssignments() async {
    final String email = (await LocalStorageApi().getEmail())!;
    final String token = (await LocalStorageApi().getLoginToken())!;
    final String query = """
      query {
        assignments(email: "$email", token: "$token") {
          id,
          name,
          due_at,
          description,
          course_id,
          is_submitted,
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    return _client.query(options).then((result) {
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      List<Assignment> assignments = [];
      for (var assignment in result.data!['assignments']) {
        assignments.add(Assignment.fromJson(assignment));
      }

      return assignments;
    });
  }

  Future<List<ChatRead>> chatReads() async {
    final String email = (await LocalStorageApi().getEmail())!;
    final String query = """
      query {
        chatReads(email: "$email") {
          course_id,
          count
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    return _client.query(options).then((result) {
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      List<ChatRead> chatReads = [];
      for (var chatRead in result.data!['chatReads']) {
        chatReads.add(ChatRead.fromJson(chatRead));
      }
      return chatReads;
    });
  }

  Future<bool> markChatRead(String courseId) async {
    final String email = (await LocalStorageApi().getEmail())!;
    final String query = """
      mutation {
        markChatRead(email: "$email", course_id: "$courseId")
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return true;
  }

  Future<bool> clearChat(String courseId) async {
    final String query = """
      mutation {
        clearChat(course_id: "$courseId")
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return true;
  }

  Future<List<Club>> getClubs() async {
    const String query = """
      query {
        clubs {
          id,
          name,
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    return _client.query(options).then((result) {
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      List<Club> clubs = [];
      for (var club in result.data!['clubs']) {
        clubs.add(Club.fromJson(club));
      }

      return clubs;
    });
  }

  Future<List<String>> getSubscribedClubs() async {
    final email = (await LocalStorageApi().getEmail())!;
    final String query = """
      query {
        getClubsforUser(email: "$email") {
          id,
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    return _client.query(options).then((result) {
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      List<String> clubs = [];
      for (var club in result.data!['getClubsforUser']) {
        clubs.add(club['id']);
      }
      return clubs;
    });
  }

  Future<List<Event>> getEvents() async {
    final email = (await LocalStorageApi().getEmail())!;

    final String query = """
      query {
        getEvents(email: "$email") {
          date
          info
          location
          name
          time
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    print(query);

    return _client.query(options).then((result) {
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      print(result.data);

      List<Event> events = [];
      for (var event in result.data!['getEvents']) {
        events.add(Event.fromJson(event));
        print(event);
      }

      return events;
    });
  }

  Future<bool> addClub(String clubId) async {
    final email = (await LocalStorageApi().getEmail())!;
    final String query = """
      mutation {
        addClub(email: "$email", club_id: "$clubId")
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return true;
  }

  Future<bool> removeClub(String clubId) async {
    final email = (await LocalStorageApi().getEmail())!;
    final String query = """
      mutation {
        removeClub(email: "$email", club_id: "$clubId")
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return true;
  }

  Future<bool> setNotificationToken(String email, String token) async {
    final String query = """
      mutation {
        addNotificationToken(email: "$email", token: "$token")
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return true;
  }
}

class LocalStorageApi {
  Future<String?> getLoginToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('loginToken');
  }

  Future<String?> getShortName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('shortName') == null) {
      final shortName = await GraphQlApi().getShortName();
      prefs.setString('shortName', shortName);
    }
    return prefs.getString('shortName');
  }

  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> setLoginToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('loginToken', token);
  }

  Future<void> setShortName(String shortName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('shortName', shortName);
  }

  Future<void> setEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    GraphQlApi().setNotificationToken(email, (await getNotificationToken())!);
  }

  Future<void> clearLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loginToken');
    prefs.remove('email');
    prefs.clear();
  }

  Future<void> setNotificationToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = (await getEmail());
    if (email != null && email != "") {
      GraphQlApi().setNotificationToken(email, token);
    }
    prefs.setString('notificationToken', token);
  }

  Future<String?> getNotificationToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('notificationToken');
  }
}
