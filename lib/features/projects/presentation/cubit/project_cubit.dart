import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/get_all_projects.dart';
import '../../domain/usecases/save_project.dart';
import '../../domain/usecases/delete_project.dart';
import '../../domain/usecases/update_project.dart';
import '../../domain/usecases/analyze_project.dart';

part 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final GetAllProjects _getAllProjects;
  final SaveProject _saveProject;
  final DeleteProject _deleteProject;
  final UpdateProject _updateProjectUseCase;
  final AnalyzeProject _analyzeProject;

  ProjectCubit({
    required GetAllProjects getAllProjects,
    required SaveProject saveProject,
    required DeleteProject deleteProject,
    required UpdateProject updateProject,
    required AnalyzeProject analyzeProject,
  })  : _getAllProjects = getAllProjects,
        _saveProject = saveProject,
        _deleteProject = deleteProject,
        _updateProjectUseCase = updateProject,
        _analyzeProject = analyzeProject,
        super(const ProjectInitial());

  Future<void> loadProjects() async {
    emit(const ProjectLoading());
    final result = await _getAllProjects(NoParams());
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (projects) => emit(ProjectLoaded(projects)),
    );
  }

  Future<void> createProject(String name, {String? videoPath}) async {
    emit(const ProjectLoading());
    final project = Project.create(name: name, videoPath: videoPath);
    final result = await _saveProject(SaveProjectParams(project));
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (_) {
        emit(const ProjectSuccess('Project created!'));
        loadProjects();
      },
    );
  }

  Future<void> deleteProject(String id) async {
    emit(const ProjectLoading());
    final result = await _deleteProject(DeleteProjectParams(id));
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (_) {
        emit(const ProjectSuccess('Project deleted'));
        loadProjects();
      },
    );
  }

  Future<void> updateProject(Project project) async {
    emit(const ProjectLoading());
    final result = await _updateProjectUseCase(project);
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (_) => loadProjects(),
    );
  }

  Future<void> startAnalysis(Project project) async {
    emit(ProjectAnalyzing(project));

    final result = await _analyzeProject(project);

    await result.fold(
      (failure) async => emit(ProjectError(failure.message)),
      (analysis) async {
        final updated = Project(
          id: project.id,
          name: project.name,
          createdAt: project.createdAt,
          videoPath: project.videoPath,
          duration: project.duration,
          status: ProjectStatus.ready,
          lastEdited: DateTime.now(),
          clipsCount: analysis.clips.length,
          clips: analysis.clips.map((c) => c.toMap()).toList(), // ✅ fixed
        );

        final saveResult = await _updateProjectUseCase(updated);

        saveResult.fold(
          (failure) => emit(ProjectError(failure.message)),
          (_) => emit(ProjectAnalysisComplete(updated, analysis)),
        );
      },
    );
  }
}
