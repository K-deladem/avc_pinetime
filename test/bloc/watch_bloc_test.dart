import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_event.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_state.dart';
import 'package:flutter_bloc_app_template/domain/repositories/watch_repository.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/watch_device.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock du repository
class MockWatchRepository extends Mock implements WatchRepository {}

// Fake pour WatchDevice
class FakeWatchDevice extends Fake implements WatchDevice {}

void main() {
  late MockWatchRepository mockRepository;
  late WatchBloc watchBloc;

  // Données de test avec tous les champs requis
  final testDevice = WatchDevice(
    id: 'test-id-123',
    name: 'Test Watch',
    manufacturer: 'InfiniTime',
    model: 'PineTime',
    firmwareVersion: '1.14.0',
    hardwareVersion: '1.0',
    armSide: ArmSide.left,
  );

  final testDevices = [testDevice];

  setUpAll(() {
    registerFallbackValue(FakeWatchDevice());
  });

  setUp(() {
    mockRepository = MockWatchRepository();
    watchBloc = WatchBloc(mockRepository);
  });

  tearDown(() {
    watchBloc.close();
  });

  group('WatchBloc', () {
    test('initial state is WatchInitial', () {
      expect(watchBloc.state, isA<WatchInitial>());
    });

    blocTest<WatchBloc, WatchState>(
      'emits [WatchLoading, WatchLoaded] when LoadWatchDevices succeeds',
      build: () {
        when(() => mockRepository.getAllDevices())
            .thenAnswer((_) async => testDevices);
        return WatchBloc(mockRepository);
      },
      act: (bloc) => bloc.add(LoadWatchDevices()),
      expect: () => [
        isA<WatchLoading>(),
        isA<WatchLoaded>().having(
          (state) => state.devices.length,
          'devices count',
          1,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.getAllDevices()).called(1);
      },
    );

    blocTest<WatchBloc, WatchState>(
      'emits [WatchLoading, WatchError] when LoadWatchDevices fails',
      build: () {
        when(() => mockRepository.getAllDevices())
            .thenThrow(Exception('Database error'));
        return WatchBloc(mockRepository);
      },
      act: (bloc) => bloc.add(LoadWatchDevices()),
      expect: () => [
        isA<WatchLoading>(),
        isA<WatchError>(),
      ],
    );

    blocTest<WatchBloc, WatchState>(
      'emits [WatchLoading, WatchLoaded] when AddWatchDevice succeeds',
      build: () {
        when(() => mockRepository.addWatchDevice(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getAllDevices())
            .thenAnswer((_) async => testDevices);
        return WatchBloc(mockRepository);
      },
      act: (bloc) => bloc.add(AddWatchDevice(testDevice)),
      expect: () => [
        isA<WatchLoading>(),
        isA<WatchLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.addWatchDevice(any())).called(1);
      },
    );

    blocTest<WatchBloc, WatchState>(
      'emits [WatchLoading, WatchLoaded] when DeleteWatchDevice succeeds',
      build: () {
        when(() => mockRepository.deleteDevice(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getAllDevices())
            .thenAnswer((_) async => []);
        return WatchBloc(mockRepository);
      },
      act: (bloc) => bloc.add(DeleteWatchDevice('test-id-123')),
      expect: () => [
        isA<WatchLoading>(),
        isA<WatchLoaded>().having(
          (state) => state.devices.isEmpty,
          'devices empty',
          true,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.deleteDevice('test-id-123')).called(1);
      },
    );
  });
}
