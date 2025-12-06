import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_session.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if there is an active session (endTime == null)
  Future<DocumentSnapshot?> getActiveSession() async {
    final query = await _firestore
        .collection('class_sessions')
        .where('endTime', isNull: true)
        .limit(1)
        .get();

    return query.docs.isNotEmpty ? query.docs.first : null;
  }

  /// Create a new class session
  Future<void> createClassSession(ClassSession session) async {
    await _firestore.collection('class_sessions').add(session.toMap());
  }

  /// End session: update endTime
  Future<void> endClass(String docId, String endTime) async {
    await _firestore.collection('class_sessions').doc(docId).update({
      'endTime': endTime,
    });
  }
}
