import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookFormPage extends StatefulWidget {
  final Book? book;

  const BookFormPage({super.key, this.book});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _tanggalCtrl = TextEditingController();
  final _volumeCtrl = TextEditingController();
  final _penulisCtrl = TextEditingController();
  final _penerbitCtrl = TextEditingController();

  final ApiService _api = ApiService();
  bool _loading = false;

  bool get isEdit => widget.book != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final b = widget.book!;
      _judulCtrl.text = b.judul;
      _hargaCtrl.text = b.harga.toString();
      _jumlahCtrl.text = b.jumlah.toString();
      _tanggalCtrl.text = b.tanggalMasuk;
      _volumeCtrl.text = b.volume.toString();
      _penulisCtrl.text = b.penulis;
      _penerbitCtrl.text = b.penerbit;
    } else {
      _tanggalCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _hargaCtrl.dispose();
    _jumlahCtrl.dispose();
    _tanggalCtrl.dispose();
    _volumeCtrl.dispose();
    _penulisCtrl.dispose();
    _penerbitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _tanggalCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  final harga = int.tryParse(_hargaCtrl.text.trim()) ?? 0;
  final jumlah = int.tryParse(_jumlahCtrl.text.trim()) ?? 0;
  final volume = int.tryParse(_volumeCtrl.text.trim()) ?? 0;

  final book = Book(
    id: widget.book?.id,
    judul: _judulCtrl.text.trim(),
    harga: harga,
    jumlah: jumlah,
    tanggalMasuk: _tanggalCtrl.text.trim(),
    volume: volume,
    penulis: _penulisCtrl.text.trim(),
    penerbit: _penerbitCtrl.text.trim(),
  );

  setState(() => _loading = true);

  try {
    bool success;
    if (isEdit) {
      success = await _api.updateBook(book);
    } else {
      success = await _api.createBook(book);
    }

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Data buku berhasil diupdate'
                : 'Data buku berhasil ditambahkan',
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan data (status bukan 200/201).')),
      );
    }
  } catch (e) {
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi error: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final appBarTitle =
        isEdit ? 'Edit Inventaris Malkamart' : 'Tambah Inventaris Malkamart';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _judulCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _penulisCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Penulis',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Penulis wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _penerbitCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Penerbit',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Penerbit wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hargaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga (Rp)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Harga wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _jumlahCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Jumlah wajib diisi'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _volumeCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Volume',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Volume wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _tanggalCtrl,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Masuk',
                              border: OutlineInputBorder(),
                            ),
                            onTap: _pickDate,
                            validator: (val) => val == null || val.isEmpty
                                ? 'Tanggal masuk wajib diisi'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _save,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text('SIMPAN'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
