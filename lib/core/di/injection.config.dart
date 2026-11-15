// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:natyapp/core/config/app_config.dart' as _i98;
import 'package:natyapp/core/database/app_database.dart' as _i517;
import 'package:natyapp/core/di/injection.dart' as _i76;
import 'package:natyapp/core/network/api_client.dart' as _i495;
import 'package:natyapp/features/home/presentation/bloc/home_bloc.dart'
    as _i949;
import 'package:natyapp/features/quiz/data/quiz_repository_api.dart' as _i800;
import 'package:natyapp/features/quiz/presentation/bloc/quiz_bloc.dart'
    as _i801;
import 'package:natyapp/features/training/data/training_repository_api.dart'
    as _i802;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.factory<_i949.HomeBloc>(() => _i949.HomeBloc());
    gh.singleton<_i98.AppConfig>(() => registerModule.appConfig);
    gh.lazySingleton<_i517.AppDatabase>(() => _i517.AppDatabase());
    gh.lazySingleton<_i495.ApiClient>(
      () => _i495.ApiClient(gh<_i98.AppConfig>()),
    );
    gh.lazySingleton<_i800.QuizRepository>(
      () => _i800.QuizRepositoryApi(gh<_i495.ApiClient>()),
    );
    gh.factory<_i801.QuizBloc>(
      () => _i801.QuizBloc(gh<_i800.QuizRepository>()),
    );
    gh.lazySingleton<_i802.TrainingRepository>(
      () => _i802.TrainingRepositoryApi(gh<_i495.ApiClient>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i76.RegisterModule {}
