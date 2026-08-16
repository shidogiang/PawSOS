import 'package:paw_sos/features/adoption/data/models/AdoptionTrackingModel.dart';
import '../repositories/adoption_repository.dart';
class GetMyTrackingsUseCase {
  final AdoptionRepository repository;
  GetMyTrackingsUseCase(this.repository);

  Future<List<AdoptionTrackingModel>> call() async {
    return await repository.getMyTrackings();
  }
}