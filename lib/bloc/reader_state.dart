import 'package:book_reader_student/bloc/reader_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class LibraryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<BookEntry> books;
  LibraryLoaded(this.books);
  @override
  List<Object?> get props => [books];
}

class LibraryError extends LibraryState {
  final String message;
  LibraryError(this.message);
  @override
  List<Object?> get props => [message];
}
