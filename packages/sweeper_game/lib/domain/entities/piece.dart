import 'package:equatable/equatable.dart';

/// All pieces share the same design per PDF spec.
class Piece extends Equatable {
  const Piece({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
