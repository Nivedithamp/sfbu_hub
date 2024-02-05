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
  final String? schdule_day;
  final String? schdule_time1;
  final String? schdule_time2;
  final String? location;

  Course({
    this.id,
    this.name,
    this.is_public,
    this.schdule_day,
    this.schdule_time1,
    this.schdule_time2,
    this.location,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      is_public: json['is_public'],
      schdule_day: json['schdule_day'],
      schdule_time1: json['schdule_time1'],
      schdule_time2: json['schdule_time2'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_public': is_public,
      'schdule_day': schdule_day,
      'schdule_time1': schdule_time1,
      'schdule_time2': schdule_time2,
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
