import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'book_form_page.dart';
import 'login_page.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final ApiService _api = ApiService();
  late Future<List<Book>> _futureBooks;

  @override
  void initState() {
    super.initState();
    _futureBooks = _api.getBooks();
  }

  void _refresh() {
    setState(() {
      _futureBooks = _api.getBooks();
    });
  }

  Future<void> _logout() async {
    await _api.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? '';
  }

  Future<void> _confirmDelete(Book book) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Yakin ingin menghapus "${book.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _api.deleteBook(book.id!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil dihapus')),
        );
        _refresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserName(),
      builder: (context, snapshot) {
        final userName = snapshot.data ?? '';
        return Scaffold(
          appBar: AppBar(
            title: const Text('Inventaris Buku Malkamart'),
            actions: [
              if (userName.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      userName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: FutureBuilder<List<Book>>(
            future: _futureBooks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final books = snapshot.data ?? [];
              if (books.isEmpty) {
                return const Center(
                  child: Text('Belum ada data inventaris buku.'),
                );
              }
              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final b = books[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(b.judul),
                      subtitle: Text(
                          'Penulis: ${b.penulis}\nHarga: Rp ${b.harga} | Jumlah: ${b.jumlah}\nTgl Masuk: ${b.tanggalMasuk} | Volume: ${b.volume}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookFormPage(book: b),
                                ),
                              );
                              if (result == true) {
                                _refresh();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(b),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookFormPage()),
              );
              if (result == true) {
                _refresh();
              }
            },
            child: const Icon(Icons.add),
            tooltip: 'Tambah Inventaris Malkamart',
          ),
        );
      },
    );
  }
}
