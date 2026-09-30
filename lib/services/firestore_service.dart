import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/movie.dart';
import '../models/movie_list_type.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _movieCollection(
    MovieListType listType,
  ) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const FirestoreException('You must be logged in.');
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lists')
        .doc(listType.firestoreName)
        .collection('movies');
  }

  Future<List<Movie>> getMovies(MovieListType listType) async {
    try {
      final snapshot = await _movieCollection(listType).get();
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc.data())).toList();
    } on FirebaseException catch (error) {
      throw FirestoreException(error.message ?? 'Database error.');
    }
  }

  Future<void> addMovie(Movie movie, MovieListType listType) async {
    try {
      await _movieCollection(listType)
          .doc(movie.id.toString())
          .set(movie.toFirestore());
    } on FirebaseException catch (error) {
      throw FirestoreException(error.message ?? 'Database error.');
    }
  }

  Future<void> updateMovie(Movie movie, MovieListType listType) async {
    try {
      await _movieCollection(listType)
          .doc(movie.id.toString())
          .update(movie.toFirestore());
    } on FirebaseException catch (error) {
      throw FirestoreException(error.message ?? 'Database error.');
    }
  }

  Future<void> deleteMovie(int movieId, MovieListType listType) async {
    try {
      await _movieCollection(listType).doc(movieId.toString()).delete();
    } on FirebaseException catch (error) {
      throw FirestoreException(error.message ?? 'Database error.');
    }
  }
}

class FirestoreException implements Exception {
  final String message;

  const FirestoreException(this.message);

  @override
  String toString() => message;
}
