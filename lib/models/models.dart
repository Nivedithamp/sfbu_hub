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
