import 'package:cloud_firestore/cloud_firestore.dart';
import '../notes/models/note.dart';

class NoteService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Note>> getNotes() {
    return _db.collection('notes').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return Note(
          id: doc.id,
          title: data['title'],
          content: data['content'],
          reminder: data['reminder'] != null
              ? (data['reminder'] as Timestamp).toDate()
              : null,
        );
      }).toList(),
    );
  }

  Future<void> addNote(Note note) async {
    await _db.collection('notes').add({
      'title': note.title,
      'content': note.content,
      'reminder': note.reminder,
    });
  }

  Future<void> deleteNote(String id) async {
    await _db.collection('notes').doc(id).delete();
  }
}