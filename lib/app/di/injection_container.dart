import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../features/projects/domain/entities/project.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/usecases/get_all_projects.dart';
import '../../features/projects/domain/usecases/save_project.dart';
import '../../features/projects/domain/usecases/delete_project.dart';
import '../../features/projects/domain/usecases/update_project.dart';
import '../../features/projects/presentation/cubit/project_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDependencies(Box<Project> projectBox) async {
  // Network
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {'Content-Type': 'application/json'},
    ));
    return dio;
  });

  // Storage — box is already open & typed. DON'T open or delete it here.
  getIt.registerLazySingleton<Box<Project>>(() => projectBox);

  // ─── Projects Feature ───
  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(getIt<Box<Project>>()),
  );
  getIt.registerLazySingleton(() => GetAllProjects(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => SaveProject(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => DeleteProject(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(
      () => UpdateProject(getIt<ProjectRepository>())); // ✅ added

  getIt.registerFactory(() => ProjectCubit(
        getAllProjects: getIt<GetAllProjects>(),
        saveProject: getIt<SaveProject>(),
        deleteProject: getIt<DeleteProject>(),
        updateProject: getIt<UpdateProject>(), // ✅ added
      ));
}
