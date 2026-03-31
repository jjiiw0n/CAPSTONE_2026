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

  List<Map<String, dynamic>> _tags = [];
  List<Map<String, dynamic>> _calendar = [];
  Map<String, dynamic> _categories = {};
  Map<String, dynamic> _systemControl = {};

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _testController.dispose();
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
            ..._tags.map(
              (tag) => ListTile(
                title: Text('TagID: ${tag['TagID']}'),
                subtitle: Text('Status: ${tag['Status']}'),
                trailing: Text(_formatDateTime(tag['Timestamp'] as DateTime)),
              ),
            ),

            const Divider(),

            // Calendar 섹션
            _buildSectionTitle('Calendar'),
            ..._calendar.map((item) {
              final fields = item['fields'] as Map<String, dynamic>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(title: Text('${item['doc_id']}')),
                  ...fields.entries.map((entry) {
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
            }),

            // flutter_Test 문서 수정 UI
            ListTile(title: const Text('flutter_Test - test 값 수정')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _testController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
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

            const Divider(),

            // Categories 섹션
            _buildSectionTitle('Categories'),

            // essential
            if (_categories.containsKey('essential')) ...[
              ListTile(title: const Text('essential')),
              ListTile(
                title: const Text('categoryName'),
                trailing: Text('${_categories['essential']['categoryName']}'),
              ),
              ListTile(
                title: const Text('description'),
                trailing: Text('${_categories['essential']['description']}'),
              ),
              ListTile(
                title: const Text('startTime'),
                trailing: Text('${_categories['essential']['startTime']}'),
              ),
              ListTile(
                title: const Text('targetDays'),
                trailing: Text(
                  '${_categories['essential']['targetDays'] ?? 'null'}',
                ),
              ),
            ],

            // school
            if (_categories.containsKey('school')) ...[
              ListTile(title: const Text('school')),
              ListTile(
                title: const Text('categoryName'),
                trailing: Text('${_categories['school']['categoryName']}'),
              ),
              ListTile(
                title: const Text('description'),
                trailing: Text('${_categories['school']['description']}'),
              ),
              ListTile(
                title: const Text('isActive'),
                trailing: Text('${_categories['school']['isActive']}'),
              ),
              ListTile(
                title: const Text('startTime'),
                trailing: Text('${_categories['school']['startTime']}'),
              ),
              ListTile(
                title: const Text('targetDays'),
                trailing: Text(
                  (_categories['school']['targetDays'] as List).join(', '),
                ),
              ),
            ],

            // unassigned
            if (_categories.containsKey('unassigned')) ...[
              ListTile(title: const Text('unassigned')),
              ListTile(
                title: const Text('name1'),
                trailing: Text('${_categories['unassigned']['name1']}'),
              ),
            ],

            const Divider(),

            // System Control 섹션
            _buildSectionTitle('System Control'),

            // Tag_ID
            if (_systemControl.containsKey('Tag_ID')) ...[
              ListTile(title: const Text('Tag_ID')),
              ListTile(
                title: const Text('new'),
                trailing: Text('${_systemControl['Tag_ID']['new']}'),
              ),
            ],

            // rpi_01
            if (_systemControl.containsKey('rpi_01')) ...[
              ListTile(title: const Text('rpi_01')),
              ListTile(
                title: const Text('mode'),
                trailing: Text('${_systemControl['rpi_01']['mode']}'),
              ),
            ],
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
