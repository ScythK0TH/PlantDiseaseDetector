import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class RecogniserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecogniserStarted extends RecogniserEvent {}

class PhotoPicked extends RecogniserEvent {
  final File image;
  PhotoPicked(this.image);

  @override
  List<Object?> get props => [image];
}
