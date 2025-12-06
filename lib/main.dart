import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/book_list_page.dart';
import 'screens/book_form_page.dart';
import 'models/book.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getInt('user_id') != null;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsi 2 Mobile Paket 3 H1D021100',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: isLoggedIn ? '/books' : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/books': (context) => const BookListPage(),
        '/books/add': (context) => const BookFormPage(),
      },
      // route dinamis untuk edit
      onGenerateRoute: (settings) {
        if (settings.name == '/books/edit') {
          final book = settings.arguments as Book;
          return MaterialPageRoute(
            builder: (_) => BookFormPage(book: book),
          );
        }
        return null;
      },
    );
  }
}
