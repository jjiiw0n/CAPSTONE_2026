import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 컬렉션 이름 상수 관리 -> 컬렉션 이름이 바뀔 경우 여기서 수정
  static const String tagsCollection = 'Tags';
  static const String calendarCollection = 'calendar';
  static const String categoriesCollection = 'categories';
  static const String systemControlCollection = 'system_control';

  // Tags 컬렉션 데이터 가져오기
  Future<List<Map<String, dynamic>>> getTags() async {
    final snapshot = await _db.collection(tagsCollection).get();

    print('가져온 태그 수: ${snapshot.docs.length}');
    for (var doc in snapshot.docs) {
      print('문서 ID: ${doc.id}');
      print('TagID: ${doc['TagID']}');
      print('Status: ${doc['Status']}');
      print('Timestamp: ${doc['Timestamp']}');
    }

    return snapshot.docs.map((doc) {
      return {
        'doc_id': doc.id,
        'TagID': doc['TagID'],
        'Status': doc['Status'],
        'Timestamp': doc['Timestamp'],
      };
    }).toList();
  }

  // calendar 컬렉션 데이터 가져오기
  Future<List<Map<String, dynamic>>> getCalendar() async {
    final snapshot = await _db.collection(calendarCollection).get();
    return snapshot.docs.map((doc) {
      return {'doc_id': doc.id, ...doc.data()};
    }).toList();
  }

  // categories 컬렉션 데이터 가져오기
  Future<List<Map<String, dynamic>>> getCategories() async {
    final snapshot = await _db.collection(categoriesCollection).get();
    return snapshot.docs.map((doc) {
      return {'doc_id': doc.id, ...doc.data()};
    }).toList();
  }

  // system_control 컬렉션 데이터 가져오기
  Future<List<Map<String, dynamic>>> getSystemControl() async {
    final snapshot = await _db.collection(systemControlCollection).get();
    return snapshot.docs.map((doc) {
      return {'doc_id': doc.id, ...doc.data()};
    }).toList();
  }
}
