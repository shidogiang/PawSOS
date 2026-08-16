import 'package:paw_sos/features/adoption/data/models/AdoptionTrackingModel.dart';
import '../../domain/repositories/adoption_repository.dart';
import '../datasources/adoption_remote_datasouce.dart';
class AdoptionRepositoryImpl implements AdoptionRepository {
  final AdoptionRemoteDataSource remoteDataSource;

  AdoptionRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AdoptionTrackingModel>> getMyTrackings() async {
    return await remoteDataSource.getMyTrackings();
  }

  @override
  Future<bool> submitWeeklyImage(String trackingId, int week, dynamic imageFile) async {
    return await remoteDataSource.submitWeeklyImage(trackingId: trackingId, week: week, imageFile: imageFile);
  }
}