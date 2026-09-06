import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/get_all_projects.dart';
import '../../domain/usecases/save_project.dart';
import '../../domain/usecases/delete_project.dart';
import '../../domain/usecases/update_project.dart'; // ✅ added

part 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final GetAllProjects _getAllProjects;
  final SaveProject _saveProject;
  final DeleteProject _deleteProject;
  final UpdateProject _updateProject; // ✅ added

  ProjectCubit({
    required GetAllProjects getAllProjects,
    required SaveProject saveProject,
    required DeleteProject deleteProject,
    required UpdateProject updateProject, // ✅ added
  })  : _getAllProjects = getAllProjects,
        _saveProject = saveProject,
        _deleteProject = deleteProject,
        _updateProject = updateProject,
        super(const ProjectInitial());

  Future<void> loadProjects() async {
    print('🔄 Loading projects...');
    emit(const ProjectLoading());

    final result = await _getAllProjects(NoParams());

    result.fold(
      (failure) {
        print('❌ Error loading projects: ${failure.message}');
        emit(ProjectError(failure.message));
      },
      (projects) {
        print('✅ Loaded ${projects.length} projects');
        emit(ProjectLoaded(projects));
      },
    );
  }

  Future<void> createProject(String name, {String? videoPath}) async {
    emit(const ProjectLoading());

    final project = Project.create(
      name: name,
      videoPath: videoPath,
    );

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

  // ✅ New — needed for Phase 2 (setting videoPath after picker, duration
  // after extraction, clipsCount after AI analysis, etc.)
  Future<void> updateProject(Project project) async {
    emit(const ProjectLoading());
    final result = await _updateProject(project);
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (_) {
        emit(const ProjectSuccess('Project updated'));
        loadProjects();
      },
    );
  }
}
