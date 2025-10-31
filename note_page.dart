import 'package:flutter/material.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/note.dart';

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final noteMaps = await DatabaseHelper.instance.getNotes();
    setState(() {
      notes = noteMaps.map((map) => Note.fromMap(map)).toList();
    });
  }

  Future<void> _addOrUpdateNote({Note? note}) async {
    final TextEditingController titleController = TextEditingController(text: note?.title);
    final TextEditingController contentController = TextEditingController(text: note?.content);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Update Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text;
                final content = contentController.text;

                if (title.isEmpty || content.isEmpty) {
                  return;
                }

                final newNote = Note(
                  id: note?.id,
                  title: title,
                  content: content,
                );

                if (note == null) {
                  await DatabaseHelper.instance.insertNote(newNote.toMap());
                } else {
                  await DatabaseHelper.instance.updateNote(newNote.toMap());
                }

                Navigator.of(context).pop();
                _fetchNotes();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    _fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Taking App'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            onTap: () => _addOrUpdateNote(note: note),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteNote(note.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateNote(),
        child: Icon(Icons.add),
      ),
    );
  }
}
