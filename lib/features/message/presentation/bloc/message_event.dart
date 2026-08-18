import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartListeningChat extends ChatEvent {
  final String reportId;
  StartListeningChat(this.reportId);
  @override
  List<Object?> get props => [reportId];
}

class SendMessageEvent extends ChatEvent {
  final String reportId;
  final String message;
  SendMessageEvent({required this.reportId, required this.message});
  @override
  List<Object?> get props => [reportId, message];
}