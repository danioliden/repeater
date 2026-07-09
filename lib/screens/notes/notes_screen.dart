import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:repeater/utils/constants/styles.dart';
import 'package:repeater/screens/notes/note_tile.dart';
import 'package:http/http.dart' as http;

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late ScrollController _scrollController;

  bool isConnected = true;
  List _notes = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://danioliden.github.io/repeater/api/notes/metadata.json'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() => _notes = data['data']);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isConnected = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final getCrossAxisCount = (width / 300).floor();
    final crossAxisCount = (getCrossAxisCount < 1) ? 1 : getCrossAxisCount;
    final childWidth = (width -
            2 * Styles.screenSpacing -
            Styles.largeSpacing * (crossAxisCount - 1)) /
        crossAxisCount;
    final childHeight = childWidth * 9 / 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: (_notes.isEmpty)
          ? Center(
              child: isConnected
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off),
                        const Text(
                          'No internet connection!',
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: _fetchData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
            )
          : Scrollbar(
              controller: _scrollController,
              child: GridView.builder(
                controller: _scrollController,
                padding: Styles.screenPadding,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: Styles.largeSpacing,
                  crossAxisSpacing: Styles.largeSpacing,
                  childAspectRatio: childWidth / (childHeight + 50),
                ),
                itemCount: _notes.length,
                itemBuilder: (_, index) {
                  final note = _notes[index];
                  return NoteCard(
                    imageUrl: note['imageUrl']!,
                    title: note['title']!,
                    contentUrl: note['contentUrl']!,
                  );
                },
              ),
            ),
    );
  }
}
