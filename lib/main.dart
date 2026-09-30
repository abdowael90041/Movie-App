import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'repositories/movie_repository.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/tmdb_service.dart';
import 'viewmodels/auth_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final tmdbService = TmdbService();
  final movieRepository = MovieRepository(tmdbService);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<MovieRepository>(create: (_) => movieRepository),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            context.read<AuthService>(),
          ),
        ),
      ],
      child: const MovieApp(),
    ),
  );
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}
