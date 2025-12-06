class ClassSession {
  final String teacherName;
  final String subject;
  final String date;
  final String startTime;
  final String? endTime; // NEW
  final String ssid;

  ClassSession({
    required this.teacherName,
    required this.subject,
    required this.date,
    required this.startTime,
    required this.ssid,
    this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'teacherName': teacherName,
      'subject': subject,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'ssid': ssid,
    };
  }
}
