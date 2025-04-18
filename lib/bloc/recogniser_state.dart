import 'dart:io';
import 'package:equatable/equatable.dart';

enum RecogniserStatus { initial, analyzing, found, notFound, timeout }

class RecogniserState extends Equatable {
  final File? image;
  final String label;
  final double accuracy;
  final RecogniserStatus status;

  const RecogniserState({
    this.image,
    this.label = '',
    this.accuracy = 0.0,
    this.status = RecogniserStatus.initial,
  });

  RecogniserState copyWith({
    File? image,
    String? label,
    double? accuracy,
    RecogniserStatus? status,
  }) {
    return RecogniserState(
      image: image ?? this.image,
      label: label ?? this.label,
      accuracy: accuracy ?? this.accuracy,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [image, label, accuracy, status];
}
