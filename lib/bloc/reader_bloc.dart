import 'dart:convert';
import 'package:book_reader_student/bloc/reader_event.dart';
import 'package:book_reader_student/bloc/reader_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BookEntry {
  final String title;
  final String rawJson;
  final int pageCount;

  BookEntry({
    required this.title,
    required this.rawJson,
    required this.pageCount,
  });
}

// --- Bloc ---
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(LibraryLoading()) {
    on<LoadLibrary>(_onLoadLibrary);
  }

  Future<void> _onLoadLibrary(
    LoadLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      final box = await Hive.openBox('book_editor_box');
      List<BookEntry> books = [];

      // Iterate through ALL keys in the box to find saved books
      for (var key in box.keys) {
        final jsonContent = box.get(key);

        if (jsonContent is String) {
          try {
            final List<dynamic> decoded = jsonDecode(jsonContent);
            // Basic validation to ensure it's a book list
            if (decoded is List) {
              books.add(
                BookEntry(
                  title: key.toString(),
                  rawJson: jsonContent,
                  pageCount: decoded.length,
                ),
              );
            }
          } catch (e) {
            // Skip invalid entries (e.g. simple settings strings if any)
            print("Skipping invalid book entry for key $key");
          }
        }
      }

      emit(LibraryLoaded(books));
    } catch (e) {
      emit(LibraryError("Failed to load library: $e"));
    }
  }
}
