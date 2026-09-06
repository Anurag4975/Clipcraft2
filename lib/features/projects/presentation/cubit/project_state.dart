part of 'project_cubit.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;
  const ProjectLoaded(this.projects);
  @override
  List<Object?> get props => [projects];
}

class ProjectSuccess extends ProjectState {
  final String message;
  const ProjectSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ProjectError extends ProjectState {
  final String message;
  const ProjectError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProjectAnalyzing extends ProjectState {
  final Project project;
  const ProjectAnalyzing(this.project);
  @override
  List<Object?> get props => [project];
}

class ProjectAnalysisComplete extends ProjectState {
  final Project project;
  final AnalysisResult result;
  const ProjectAnalysisComplete(this.project, this.result);
  @override
  List<Object?> get props => [project, result.clips, result.viralScore];
}
