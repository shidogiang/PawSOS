import 'package:equatable/equatable.dart';

//  UI và BLoC chỉ giao tiếp với thằng này
class AnimalReportEntity extends Equatable {
  final String id;
  final String reporterId;
  final String? rescuerId;
  final String animalType;
  final List<String> conditions; 
  final String status; 
  final String description;
  final String imageUrl;
  final double? noiseLat;
  final double? noiseLng;
  final DateTime createdAt;

  const AnimalReportEntity({
    required this.id,
    required this.reporterId,
    this.rescuerId,
    required this.animalType,
    required this.conditions,
    required this.status,
    required this.description,
    required this.imageUrl,
    this.noiseLat,
    this.noiseLng,
    required this.createdAt,
  });

  String get title => animalType;
  
  String get distance => '~ 2.5 km'; // Mock data
  
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}p trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  @override
  List<Object?> get props => [
    id, reporterId, rescuerId, animalType, conditions, status, 
    description, imageUrl, noiseLat, noiseLng, createdAt
  ];
}