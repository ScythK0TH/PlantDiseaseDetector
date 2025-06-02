import 'dart:io';
import 'package:equatable/equatable.dart';

enum RecogniserStatus {
  initial,
  analyzing,
  found,
  notFound,
  timeout,
  notSupportedFormat
}

class RecogniserState extends Equatable {
  final File? image;
  final int pid;
  final String label;
  final double accuracy;
  final RecogniserStatus status;

  const RecogniserState({
    this.image,
    this.pid = 0,
    this.label = '',
    this.accuracy = 0.0,
    this.status = RecogniserStatus.initial,
  });

  RecogniserState copyWith({
    File? image,
    int? pid,
    String? label,
    double? accuracy,
    RecogniserStatus? status,
  }) {
    return RecogniserState(
      image: image ?? this.image,
      pid: pid ?? this.pid,
      label: label ?? this.label,
      accuracy: accuracy ?? this.accuracy,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [image, label, accuracy, status];
}
