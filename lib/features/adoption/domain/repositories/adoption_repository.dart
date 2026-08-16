import 'package:paw_sos/features/adoption/data/models/AdoptionTrackingModel.dart';
abstract class AdoptionRepository {
  Future<List<AdoptionTrackingModel>> getMyTrackings();
  Future<bool> submitWeeklyImage(String trackingId, int week, dynamic imageFile);
}