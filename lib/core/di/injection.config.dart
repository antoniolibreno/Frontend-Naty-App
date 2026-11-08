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
import 'package:natyapp/features/progresso/data/progresso_repository_mock.dart'
    as _i318;
import 'package:natyapp/features/progresso/domain/progresso_repository.dart'
    as _i67;
import 'package:natyapp/features/progresso/presentation/bloc/conclusao_bloc.dart'
    as _i593;
import 'package:natyapp/features/progresso/presentation/bloc/progresso_bloc.dart'
    as _i704;

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
    gh.lazySingleton<_i67.ProgressoRepository>(
      () => _i318.ProgressoRepositoryMock(),
    );
    gh.lazySingleton<_i495.ApiClient>(
      () => _i495.ApiClient(gh<_i98.AppConfig>()),
    );
    gh.factory<_i593.ConclusaoBloc>(
      () => _i593.ConclusaoBloc(gh<_i67.ProgressoRepository>()),
    );
    gh.factory<_i704.ProgressoBloc>(
      () => _i704.ProgressoBloc(gh<_i67.ProgressoRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i76.RegisterModule {}
