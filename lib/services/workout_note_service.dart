import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/workout_note.dart';

class WorkoutNoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 特定のワークアウトセッションのメモを取得
  Future<WorkoutNote?> getNoteByWorkoutSession(String workoutSessionId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 Fetching note for workout session: $workoutSessionId');
      }

      // シンプルなクエリ（インデックス不要）
      final querySnapshot = await _firestore
          .collection('workout_notes')
          .where('workout_session_id', isEqualTo: workoutSessionId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint('📋 No note found for this workout session');
        }
        return null;
      }

      final doc = querySnapshot.docs.first;
      final note = WorkoutNote.fromFirestore(doc.data(), doc.id);

      if (kDebugMode) {
        debugPrint('✅ Note loaded: ${note.content.substring(0, note.content.length > 50 ? 50 : note.content.length)}...');
      }

      return note;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching note: $e');
      }
      rethrow;
    }
  }

  // ユーザーの全メモを取得（最新順）
  Future<List<WorkoutNote>> getUserNotes(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 Fetching all notes for user: $userId');
      }

      // シンプルなクエリ（インデックス不要）
      final querySnapshot = await _firestore
          .collection('workout_notes')
          .where('user_id', isEqualTo: userId)
          .get();

      // メモリ内でソート（updated_at降順）
      final notes = querySnapshot.docs
          .map((doc) => WorkoutNote.fromFirestore(doc.data(), doc.id))
          .toList();

      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      if (kDebugMode) {
        debugPrint('✅ Loaded ${notes.length} notes');
      }

      return notes;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching user notes: $e');
      }
      rethrow;
    }
  }

  // メモを作成
  Future<WorkoutNote> createNote({
    required String userId,
    required String workoutSessionId,
    required String content,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('📝 Creating note for workout session: $workoutSessionId');
      }

      // 既存のメモがあるか確認
      final existingNote = await getNoteByWorkoutSession(workoutSessionId);
      if (existingNote != null) {
        if (kDebugMode) {
          debugPrint('⚠️ Note already exists, updating instead');
        }
        return await updateNote(existingNote.id, content);
      }

      final now = DateTime.now();
      final note = WorkoutNote(
        id: '', // Firestoreが自動生成
        userId: userId,
        workoutSessionId: workoutSessionId,
        content: content,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _firestore.collection('workout_notes').add(note.toFirestore());

      if (kDebugMode) {
        debugPrint('✅ Note created with ID: ${docRef.id}');
      }

      return note.copyWith(id: docRef.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error creating note: $e');
      }
      rethrow;
    }
  }

  // メモを更新
  Future<WorkoutNote> updateNote(String noteId, String newContent) async {
    try {
      if (kDebugMode) {
        debugPrint('✏️ Updating note: $noteId');
      }

      final now = DateTime.now();
      await _firestore.collection('workout_notes').doc(noteId).update({
        'content': newContent,
        'updated_at': Timestamp.fromDate(now),
      });

      // 更新後のメモを取得
      final docSnapshot = await _firestore.collection('workout_notes').doc(noteId).get();
      final updatedNote = WorkoutNote.fromFirestore(docSnapshot.data()!, noteId);

      if (kDebugMode) {
        debugPrint('✅ Note updated successfully');
      }

      return updatedNote;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating note: $e');
      }
      rethrow;
    }
  }

  // メモを削除
  Future<void> deleteNote(String noteId) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ Deleting note: $noteId');
      }

      await _firestore.collection('workout_notes').doc(noteId).delete();

      if (kDebugMode) {
        debugPrint('✅ Note deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting note: $e');
      }
      rethrow;
    }
  }

  // メモの存在確認
  Future<bool> hasNote(String workoutSessionId) async {
    try {
      final note = await getNoteByWorkoutSession(workoutSessionId);
      return note != null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking note existence: $e');
      }
      return false;
    }
  }
}
