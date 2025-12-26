import '../../models/watch_device.dart';
import '../repositories/watch_repository.dart';
import 'usecase.dart';

/// Use case for fetching all watch devices
class GetAllWatches extends UseCase<List<WatchDevice>, NoParams> {
  final WatchRepository repository;

  GetAllWatches(this.repository);

  @override
  Future<List<WatchDevice>> call(NoParams params) async {
    return await repository.getAllDevices();
  }
}
