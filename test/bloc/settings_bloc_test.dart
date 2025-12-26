import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/domain/repositories/settings_repository.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock du repository
class MockSettingsRepository extends Mock implements SettingsRepository {}

// Fake pour AppSettings
class FakeAppSettings extends Fake implements AppSettings {}

void main() {
  late MockSettingsRepository mockRepository;
  late SettingsBloc settingsBloc;

  // Utiliser les paramètres par défaut de l'app
  final testSettings = AppDatabase.defaultSettings;

  setUpAll(() {
    registerFallbackValue(FakeAppSettings());
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    settingsBloc = SettingsBloc(mockRepository);
  });

  tearDown(() {
    settingsBloc.close();
  });

  group('SettingsBloc', () {
    test('initial state is SettingsInitial', () {
      expect(settingsBloc.state, isA<SettingsInitial>());
    });

    blocTest<SettingsBloc, SettingsState>(
      'emits [SettingsLoading, SettingsLoaded] when LoadSettings is added and succeeds',
      build: () {
        when(() => mockRepository.fetchSettings())
            .thenAnswer((_) async => testSettings);
        return SettingsBloc(mockRepository);
      },
      act: (bloc) => bloc.add(LoadSettings()),
      expect: () => [
        isA<SettingsLoading>(),
        isA<SettingsLoaded>().having(
          (state) => state.settings.userName,
          'userName',
          'Test User',
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchSettings()).called(1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits [SettingsLoading, SettingsError] when LoadSettings fails',
      build: () {
        when(() => mockRepository.fetchSettings())
            .thenThrow(Exception('Database error'));
        return SettingsBloc(mockRepository);
      },
      act: (bloc) => bloc.add(LoadSettings()),
      expect: () => [
        isA<SettingsLoading>(),
        isA<SettingsError>(),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits [SettingsLoaded] when UpdateSettings succeeds',
      build: () {
        when(() => mockRepository.saveSettings(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.fetchSettings())
            .thenAnswer((_) async => testSettings);
        return SettingsBloc(mockRepository);
      },
      act: (bloc) => bloc.add(UpdateSettings(testSettings)),
      expect: () => [
        isA<SettingsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSettings(any())).called(1);
        verify(() => mockRepository.fetchSettings()).called(1);
      },
    );
  });
}
