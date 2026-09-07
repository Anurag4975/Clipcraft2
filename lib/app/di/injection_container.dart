import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/ffmpeg_service.dart';
import '../../core/services/transcription_service.dart';
import '../../core/services/usuage_service.dart';
import '../../features/media_tools/domain/usecases/extract_audio.dart';
import '../../features/media_tools/domain/usecases/transcribe_audio.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/entities/project.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/usecases/analyze_project.dart';
import '../../features/projects/domain/usecases/delete_project.dart';
import '../../features/projects/domain/usecases/export_selected_clips.dart';
import '../../features/projects/domain/usecases/get_all_projects.dart';
import '../../features/projects/domain/usecases/save_project.dart';
import '../../features/projects/domain/usecases/update_project.dart';
import '../../features/projects/presentation/cubit/project_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDependencies(
  Box<Project> projectBox,
  Box<dynamic> subscriptionBox,
) async {
  // Dio
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {'Content-Type': 'application/json'},
    ));
    return dio;
  });

  // Hive Boxes
  getIt.registerLazySingleton<Box<Project>>(() => projectBox);
  getIt.registerLazySingleton<Box<dynamic>>(() => subscriptionBox);

  // Services
  getIt
      .registerLazySingleton<UsageService>(() => UsageService(subscriptionBox));
  getIt.registerLazySingleton(() => FFmpegService());
  getIt.registerLazySingleton(() => TranscriptionService());

  // Repositories
  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(getIt<Box<Project>>()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetAllProjects(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => SaveProject(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => DeleteProject(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => UpdateProject(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => AnalyzeProject());
  getIt.registerLazySingleton(() => ExportSelectedClips());
  getIt.registerLazySingleton(() => ExtractAudio(getIt<FFmpegService>()));
  getIt.registerLazySingleton(
      () => TranscribeAudio(getIt<TranscriptionService>()));

  // Cubits
  getIt.registerFactory(() => ProjectCubit(
        getAllProjects: getIt<GetAllProjects>(),
        saveProject: getIt<SaveProject>(),
        deleteProject: getIt<DeleteProject>(),
        updateProject: getIt<UpdateProject>(),
        analyzeProject: getIt<AnalyzeProject>(),
        exportSelectedClips: getIt<ExportSelectedClips>(),
      ));
}
