import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/projects/presentation/pages/project_detail_page.dart';
import '../../features/projects/domain/entities/project.dart';
import '../../features/projects/presentation/cubit/project_cubit.dart';
import '../di/injection_container.dart';
import '../../features/media_tools/presentation/pages/audio_extractor_page.dart';

class AppRouter {
  static const String dashboard = 'dashboard';
  static const String projectDetail = 'projectDetail';
  static const String aiAnalysis = 'aiAnalysis';
  static const String editor = 'editor';
  static const String pricing = 'pricing';
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: AppRouter.dashboard,
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/project',
      name: AppRouter.projectDetail,
      builder: (context, state) {
        final project = state.extra as Project;
        // Provide a fresh ProjectCubit for this route since go_router
        // routes aren't automatically wrapped by providers set up elsewhere.
        return BlocProvider(
          create: (_) => getIt<ProjectCubit>()..loadProjects(),
          child: ProjectDetailPage(project: project),
        );
      },
    ),
    GoRoute(
      path: '/ai-analysis',
      name: AppRouter.aiAnalysis,
      builder: (context, state) => const Scaffold(
          body: Center(child: Text('AI Analysis — Coming Soon'))),
    ),
    GoRoute(
      path: '/editor',
      name: AppRouter.editor,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Editor — Coming Soon'))),
    ),
    GoRoute(
      path: '/pricing',
      name: AppRouter.pricing,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Pricing — Coming Soon'))),
    ),
    GoRoute(
      path: '/tools/audio-extractor',
      name: 'audioExtractor',
      builder: (context, state) => const AudioExtractorPage(),
    ),
  ],
);
