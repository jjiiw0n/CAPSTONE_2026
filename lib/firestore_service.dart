import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 컬렉션 이름 상수 관리
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
      final timestamp = doc['Timestamp'] as Timestamp;
      final dateTime = timestamp.toDate();
      return {
        'doc_id': doc.id,
        'TagID': doc['TagID'],
        'Status': doc['Status'],
        'Timestamp': dateTime,
      };
    }).toList();
  }

  // calendar 컬렉션 데이터 가져오기
  Future<List<Map<String, dynamic>>> getCalendar() async {
    final snapshot = await _db.collection(calendarCollection).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      Map<String, dynamic> fields = {};
      data.forEach((key, value) {
        if (value is Timestamp) {
          fields[key] = value.toDate();
        } else {
          fields[key] = value;
        }
      });

      return {'doc_id': doc.id, 'fields': fields};
    }).toList();
  }

  // categories 컬렉션 데이터 가져오기
  Future<Map<String, dynamic>> getCategories() async {
    final snapshot = await _db.collection(categoriesCollection).get();

    Map<String, dynamic> result = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (doc.id == 'essential') {
        result['essential'] = {
          'categoryName': data['categoryName'] ?? '',
          'description': data['description'] ?? '',
          'startTime': data['startTime'] ?? '',
          'targetDays': data['targetDays'],
        };
      } else if (doc.id == 'school') {
        result['school'] = {
          'categoryName': data['categoryName'] ?? '',
          'description': data['description'] ?? '',
          'isActive': data['isActive'] ?? false,
          'startTime': data['startTime'] ?? '',
          'targetDays': data['targetDays'] ?? [],
        };
      } else if (doc.id == 'unassigned') {
        result['unassigned'] = {'name1': data['name1'] ?? ''};
      }
    }

    return result;
  }

  // system_control 컬렉션 데이터 가져오기
  Future<Map<String, dynamic>> getSystemControl() async {
    final snapshot = await _db.collection(systemControlCollection).get();

    Map<String, dynamic> result = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (doc.id == 'Tag_ID') {
        result['Tag_ID'] = {'new': data['new'] ?? ''};
      } else if (doc.id == 'rpi_01') {
        result['rpi_01'] = {'mode': data['mode'] ?? ''};
      }
    }

    return result;
  }
}
