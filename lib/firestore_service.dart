import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String tagsCollection = 'Tags';
  static const String calendarCollection = 'calendar';
  static const String categoriesCollection = 'categories';
  static const String systemControlCollection = 'system_control';

  // Tags 컬렉션 데이터 가져오기
  Future<List<Map<String, dynamic>>> getTags() async {
    final snapshot = await _db.collection(tagsCollection).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Timestamp 필드 자동 변환
      Map<String, dynamic> result = {'doc_id': doc.id};
      data.forEach((key, value) {
        if (value is Timestamp) {
          result[key] = value.toDate();
        } else {
          result[key] = value;
        }
      });
      return result;
    }).toList();
  }

  // calendar 컬렉션 데이터 가져오기
  Future<List<Map<String, dynamic>>> getCalendar() async {
    final snapshot = await _db.collection(calendarCollection).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      Map<String, dynamic> result = {'doc_id': doc.id};
      data.forEach((key, value) {
        if (value is Timestamp) {
          result[key] = value.toDate();
        } else {
          result[key] = value;
        }
      });
      return result;
    }).toList();
  }

  // categories 컬렉션 데이터 가져오기
  Future<List<Map<String, dynamic>>> getCategories() async {
    final snapshot = await _db.collection(categoriesCollection).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      Map<String, dynamic> result = {'doc_id': doc.id};
      data.forEach((key, value) {
        if (value is Timestamp) {
          result[key] = value.toDate();
        } else {
          result[key] = value;
        }
      });
      return result;
    }).toList();
  }

  // system_control 컬렉션 데이터 가져오기
  Future<List<Map<String, dynamic>>> getSystemControl() async {
    final snapshot = await _db.collection(systemControlCollection).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      Map<String, dynamic> result = {'doc_id': doc.id};
      data.forEach((key, value) {
        if (value is Timestamp) {
          result[key] = value.toDate();
        } else {
          result[key] = value;
        }
      });
      return result;
    }).toList();
  }

  // calendar/flutter_Test 문서의 test 필드 수정
  Future<void> updateCalendarTest(String value) async {
    await _db.collection(calendarCollection).doc('flutter_Test').update({
      'test': value,
    });
  }

  // calendar/flutter_Test 문서에 새 필드 추가
  Future<void> addFieldToFlutterTest(String fieldName, dynamic value) async {
    await _db.collection(calendarCollection).doc('flutter_Test').update({
      fieldName: value,
    });
  }
}
