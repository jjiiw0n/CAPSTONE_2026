import 'package:flutter/material.dart';
import 'firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _service = FirestoreService();

  List<Map<String, dynamic>> _tags = [];
  List<Map<String, dynamic>> _calendar = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _systemControl = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // 전체 데이터 불러오기
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
                trailing: Text('${tag['Timestamp']}'),
              ),
            ),

            const Divider(),

            // Calendar 섹션
            _buildSectionTitle('Calendar'),
            ..._calendar.map(
              (item) => ListTile(
                title: Text('ID: ${item['doc_id']}'),
                subtitle: Text('${item}'),
              ),
            ),

            const Divider(),

            // Categories 섹션
            _buildSectionTitle('Categories'),
            ..._categories.map(
              (item) => ListTile(
                title: Text('ID: ${item['doc_id']}'),
                subtitle: Text('${item}'),
              ),
            ),

            const Divider(),

            // System Control 섹션
            _buildSectionTitle('System Control'),
            ..._systemControl.map(
              (item) => ListTile(
                title: Text('ID: ${item['doc_id']}'),
                subtitle: Text('${item}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 제목 위젯
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
