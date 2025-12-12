import 'dart:convert';
import 'dart:io';
import 'package:book_reader_student/views/reading_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reader_bloc.dart';
import '../bloc/reader_event.dart';
import '../bloc/reader_state.dart';
import '../models/book.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late LibraryBloc _libraryBloc;

  @override
  void initState() {
    super.initState();
    _libraryBloc = LibraryBloc()..add(LoadLibrary());
  }

  @override
  void dispose() {
    _libraryBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Library"),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_open_outlined),
            tooltip: "Import JSON",
            onPressed: () => _pickAndOpenBook(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: BlocProvider.value(
        value: _libraryBloc,
        child: BlocBuilder<LibraryBloc, LibraryState>(
          builder: (context, state) {
            if (state is LibraryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is LibraryError) {
              return Center(child: Text(state.message));
            }
            if (state is LibraryLoaded) {
              if (state.books.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_books_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Library is empty.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () => _pickAndOpenBook(context),
                        child: const Text("Import a JSON Book"),
                      ),
                    ],
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 800
                      ? 4
                      : (constraints.maxWidth > 500 ? 3 : 2);

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.books.length,
                    itemBuilder: (context, index) {
                      final book = state.books[index];
                      return _BookCard(
                        book: book,
                        onTap: () => _openBook(context, book),
                      );
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _pickAndOpenBook(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();

        final List<dynamic> jsonList = jsonDecode(jsonString);
        final List<PageModel> pages = jsonList
            .map((e) => PageModel.fromJson(e))
            .toList();

        if (context.mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookReaderPage(
                bookTitle: result.files.single.name.replaceAll('.json', ''),
                pages: pages,
              ),
            ),
          );
          _libraryBloc.add(LoadLibrary());
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _openBook(BuildContext context, BookEntry book) async {
    try {
      final List<dynamic> jsonList = jsonDecode(book.rawJson);
      final List<PageModel> pages = jsonList
          .map((e) => PageModel.fromJson(e))
          .toList();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookReaderPage(bookTitle: book.title, pages: pages),
        ),
      );
      _libraryBloc.add(LoadLibrary());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}

class _BookCard extends StatelessWidget {
  final BookEntry book;
  final VoidCallback onTap;

  const _BookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_stories,
                    size: 48,
                    color: Colors.blue.shade400,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${book.pageCount} Pages",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
