class LoginResponse {
  final String? token;
  final bool? error;
  final String? error_message;

  LoginResponse({this.token, this.error, this.error_message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      error: json['error'],
      error_message: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'error': error,
      'error_message': error_message,
    };
  }
}

class Course {
  final String? id;
  final String? name;
  final bool? is_public;
  final String? schedule_day;
  final String? schedule_time1;
  final String? schedule_time2;
  final String? location;

  Course({
    this.id,
    this.name,
    this.is_public,
    this.schedule_day,
    this.schedule_time1,
    this.schedule_time2,
    this.location,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? "xxx",
      name: json['name'] ?? "xxx",
      is_public: json['is_public'] ?? false,
      schedule_day: json['schedule_day'] ?? "xxx",
      schedule_time1: json['schedule_time1'] ?? "xxx",
      schedule_time2: json['schedule_time2'] ?? "xxx",
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_public': is_public,
      'schdule_day': schedule_day,
      'schdule_time1': schedule_time1,
      'schdule_time2': schedule_time2,
      'location': location,
    };
  }
}

class CourseResponse {
  final List<Course>? courses;
  final bool? error;
  final String? error_message;

  CourseResponse({this.courses, this.error, this.error_message});

  factory CourseResponse.fromJson(Map<String, dynamic> json) {
    return CourseResponse(
      courses:
          (json['courses'] as List).map((e) => Course.fromJson(e)).toList(),
      error: json['error'],
      error_message: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courses': courses,
      'error': error,
      'error_message': error_message,
    };
  }
}

class ChatMessage {
  final String? message;
  final String? senderName;
  final String? senderEmail;
  final String? groupId;
  final String? createdAt;

  ChatMessage({
    this.message,
    this.senderName,
    this.senderEmail,
    this.groupId,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'],
      senderName: json['sender_name'],
      senderEmail: json['sender_email'],
      groupId: json['group_id'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sender_name': senderName,
      'sender_email': senderEmail,
      'group_id': groupId,
      'created_at': createdAt,
    };
  }
}

class ChatMember {
  final String? id;
  final String? name;
  final String? email;

  ChatMember({this.id, this.name, this.email});

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(id: json['id'], name: json['name'], email: json['email']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

class ChatGroup {
  final String? id;
  final String? name;
  final List<ChatMember>? members;

  ChatGroup({
    this.id,
    this.name,
    this.members,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
        id: json['id'],
        name: json['name'],
        members: (json['members'] as List)
            .map((e) => ChatMember.fromJson(e))
            .toList());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members?.map((e) => e.toJson()).toList(),
    };
  }
}

class Assignment {
  final String? id;
  final String? name;
  final String? description;
  final String? dueDate;
  final String? courseId;
  final bool? isSubmitted;

  Assignment({
    this.id,
    this.name,
    this.description,
    this.dueDate,
    this.courseId,
    this.isSubmitted,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      dueDate: json['due_at'],
      courseId: json['course_id'],
      isSubmitted: json['is_submitted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'due_at': dueDate,
      'course_id': courseId,
      'is_submitted': isSubmitted,
    };
  }
}

class ChatRead {
  final String courseId;
  final int count;

  ChatRead({required this.courseId, required this.count});

  factory ChatRead.fromJson(Map<String, dynamic> json) {
    return ChatRead(courseId: json['course_id'], count: json['count']);
  }

  Map<String, dynamic> toJson() {
    return {'course_id': courseId, 'count': count};
  }
}

class Club {
  final String id;
  final String name;

  Club({required this.id, required this.name});

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

// type Event {
//         id: String,
//         name: String,
//         info: String,
//         date: String,
//         time: String,
//         location: String
//     }

class Event {
  final String id;
  final String name;
  final String info;
  final String date;
  final String time;
  final String location;

  Event({
    required this.id,
    required this.name,
    required this.info,
    required this.date,
    required this.time,
    required this.location,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      info: json['info'] ?? "",
      date: json['date'] ?? "",
      time: json['time'] ?? "",
      location: json['location'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'info': info,
      'date': date,
      'time': time,
      'location': location,
    };
  }
}
