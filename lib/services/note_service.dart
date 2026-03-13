import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../notes/models/note.dart';

class NoteService {
  final _db = FirebaseFirestore.instance;

  // Cada usuario solo ve sus propias notas (usando su uid como subcolección)
  CollectionReference get _notesRef {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('notes');
  }

  Stream<List<Note>> getNotes() {
    return _notesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Note(
                id: doc.id,
                title: data['title'] ?? '',
                content: data['content'] ?? '',
                reminder: data['reminder'] != null
                    ? (data['reminder'] as Timestamp).toDate()
                    : null,
              );
            }).toList());
  }

  Future<void> addNote(Note note) async {
    await _notesRef.add({
      'title': note.title,
      'content': note.content,
      'reminder': note.reminder,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote(Note note) async {
    await _notesRef.doc(note.id).update({
      'title': note.title,
      'content': note.content,
      'reminder': note.reminder,
    });
  }

  Future<void> deleteNote(String id) async {
    await _notesRef.doc(id).delete();
  }
}
