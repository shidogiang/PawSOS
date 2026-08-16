import '../repositories/adoption_repository.dart';
class GetActivityStatsUseCase {
  final AdoptionRepository repository;
  GetActivityStatsUseCase(this.repository);

  Future<Map<String, int>> call() async {
    return await repository.getActivityStats();
  }
}