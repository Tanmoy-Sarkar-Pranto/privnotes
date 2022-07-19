// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart';
// import 'package:privnotes/extentions/list/filter.dart';
// import 'package:sqflite/sqflite.dart';
//
// import 'crud_exceptions.dart';
//
// class NotesService {
//   Database? _db;
//
//   DatabaseUser? _user;
//
//   List<DatabaseNote> _notes = [];
//
//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _noteStreamsController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _noteStreamsController.sink.add(_notes);
//       },
//     );
//   }
//   factory NotesService() => _shared;
//
//   late final StreamController<List<DatabaseNote>> _noteStreamsController;
//
//   Stream<List<DatabaseNote>> get allNotes =>
//       _noteStreamsController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllNotes();
//         }
//       });
//
//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _noteStreamsController.add(_notes);
//   }
//
//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpenException();
//     } else {
//       return db;
//     }
//   }
//
//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedUser = await db.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedUser != 1) {
//       throw CouldNotDeleteUserException();
//     }
//   }
//
//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUserException {
//       final createdUser = await createUser(email: email);
//       if (setCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (result.isNotEmpty) {
//       throw UserAlreadyExistsException();
//     }
//
//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });
//
//     return DatabaseUser(id: userId, email: email);
//   }
//
//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (result.isEmpty) {
//       throw CouldNotFindUserException();
//     } else {
//       return DatabaseUser.fromRow(result.first);
//     }
//   }
//
//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//
//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUserException();
//     }
//
//     const text = '';
//     final noteId = await db.insert(noteTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });
//
//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );
//
//     _notes.add(note);
//     _noteStreamsController.add(_notes);
//     return note;
//   }
//
//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       noteTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deletedCount == 0) {
//       throw CouldNotDeleteNoteException();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _noteStreamsController.add(_notes);
//     }
//   }
//
//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions = await db.delete(noteTable);
//     _notes = [];
//     _noteStreamsController.add(_notes);
//     return numberOfDeletions;
//   }
//
//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (notes.isEmpty) {
//       throw CouldNotDeleteNoteException();
//     } else {
//       final note = DatabaseNote.fromRow(notes.first);
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _noteStreamsController.add(_notes);
//       return note;
//     }
//   }
//
//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final note = await db.query(
//       noteTable,
//     );
//
//     return note.map((noteRow) => DatabaseNote.fromRow(noteRow));
//   }
//
//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     await getNote(id: note.id);
//     final updatesCount = await db.update(
//       noteTable,
//       {
//         textColumn: text,
//         isSyncedWithCloudColumn: 0,
//       },
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );
//
//     if (updatesCount == 0) {
//       throw CouldNotUpdateNoteException();
//     } else {
//       final updateNote = await getNote(id: note.id);
//       _notes.removeWhere((note) => note.id == updateNote.id);
//       _notes.add(updateNote);
//       _noteStreamsController.add(_notes);
//       return note;
//     }
//   }
//
//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpenException();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }
//
//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenExceptionError {
//       //empty
//     }
//   }
//
//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenExceptionError();
//     }
//     try {
//       final docsPath = await getApplicationSupportDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;
//
//       await db.execute(createUserTable);
//
//       await db.execute(createNoteTable);
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentDirectoryExceptionError();
//     }
//   }
// }
//
// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;
//
//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });
//
//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;
//
//   @override
//   String toString() => 'Person, id=$id, email=$email';
//
//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
// }
//
// class DatabaseNote {
//   final int id;
//   final int? userId;
//   final String text;
//   final bool isSyncedWithCloud;
//
//   DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });
//
//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;
//
//   @override
//   String toString() =>
//       'Note, Id=$id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';
//
//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
// }
//
// const dbName = 'notes.db';
// const noteTable = 'note';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
// 	          "id"	INTEGER NOT NULL,
// 	          "email"	TEXT NOT NULL UNIQUE,
// 	          PRIMARY KEY("id" AUTOINCREMENT)
//       );
//       ''';
// const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
// 	          "id"	INTEGER NOT NULL,
// 	          "user_id"	INTEGER NOT NULL,
// 	          "text"	TEXT,
// 	          "is_synced_with_cloud"	INTEGER DEFAULT 0,
// 	          PRIMARY KEY("id" AUTOINCREMENT),
// 	          FOREIGN KEY("user_id") REFERENCES "user"("id")
//       );
//       ''';
// // const deleteNoteTable =
