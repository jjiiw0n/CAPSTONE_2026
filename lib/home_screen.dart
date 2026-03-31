import 'package:flutter/material.dart';
import 'firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _testController = TextEditingController();
  final TextEditingController _fieldNameController = TextEditingController();
  final TextEditingController _fieldValueController = TextEditingController();

  List<Map<String, dynamic>> _tags = [];
  List<Map<String, dynamic>> _calendar = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _systemControl = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _testController.dispose();
    _fieldNameController.dispose();
    _fieldValueController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    final tags = await _service.getTags();
    final calendar = await _service.getCalendar();
    final categories = await _service.getCategories();
    final systemControl = await _service.getSystemControl();

    setState(() {
      _tags = tags;
      _calendar = calendar;
      _categories = categories;
      _systemControl = systemControl;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
        '${dateTime.hour}시 ${dateTime.minute}분';
  }

  // 문서 하나를 자동으로 표시하는 위젯
  Widget _buildDocumentTile(Map<String, dynamic> doc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            '${doc['doc_id']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...doc.entries.where((entry) => entry.key != 'doc_id').map((entry) {
          final value = entry.value;
          return ListTile(
            title: Text(entry.key),
            trailing: Text(
              value is DateTime ? _formatDateTime(value) : '$value',
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('소지품 확인')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags 섹션
            _buildSectionTitle('Tags'),
            ..._tags.map((doc) => _buildDocumentTile(doc)),

            const Divider(),

            // Calendar 섹션
            _buildSectionTitle('Calendar'),
            ..._calendar.map((doc) => _buildDocumentTile(doc)),

            // flutter_Test 수정 UI
            ListTile(title: const Text('flutter_Test - test 값 수정')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _testController,
                      decoration: const InputDecoration(
                        hintText: '새로운 값을 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await _service.updateCalendarTest(_testController.text);
                      _testController.clear();
                      await _loadAllData();
                    },
                    child: const Text('수정'),
                  ),
                ],
              ),
            ),

            // flutter_Test 필드 추가 UI
            ListTile(title: const Text('flutter_Test - 필드 추가')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _fieldNameController,
                    decoration: const InputDecoration(
                      hintText: '필드 이름 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fieldValueController,
                    decoration: const InputDecoration(
                      hintText: '필드 값 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await _service.addFieldToFlutterTest(
                        _fieldNameController.text,
                        _fieldValueController.text,
                      );
                      _fieldNameController.clear();
                      _fieldValueController.clear();
                      await _loadAllData();
                    },
                    child: const Text('필드 추가'),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Categories 섹션
            _buildSectionTitle('Categories'),
            ..._categories.map((doc) => _buildDocumentTile(doc)),

            const Divider(),

            // System Control 섹션
            _buildSectionTitle('System Control'),
            ..._systemControl.map((doc) => _buildDocumentTile(doc)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
