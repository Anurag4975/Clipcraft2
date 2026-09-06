import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/analysis_result.dart';
import '../cubit/project_cubit.dart';
import '../cubit/project_state.dart';

class ProjectDetailPage extends StatelessWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          project.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _ProjectDetailBody(project: project),
    );
  }
}

class _ProjectDetailBody extends StatefulWidget {
  final Project project;
  const _ProjectDetailBody({required this.project});

  @override
  State<_ProjectDetailBody> createState() => _ProjectDetailBodyState();
}

class _ProjectDetailBodyState extends State<_ProjectDetailBody> {
  late Project _project;
  bool _isSaving = false;
  VideoPlayerController? _videoController;
  bool _isPlayerInitialized = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    if (_project.videoPath == null) return;
    _videoController = VideoPlayerController.file(File(_project.videoPath!));
    try {
      await _videoController!.initialize();
      if (mounted) setState(() => _isPlayerInitialized = true);
    } catch (e) {
      debugPrint('❌ Video preview failed: $e');
    }
  }

  Future<void> _pickVideo() async {
    setState(() => _isSaving = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (result == null || result.files.single.path == null) {
        setState(() => _isSaving = false);
        return;
      }

      final filePath = result.files.single.path!;

      // Extract duration
      Duration extractedDuration = Duration.zero;
      final tempController = VideoPlayerController.file(File(filePath));
      try {
        await tempController.initialize();
        extractedDuration = tempController.value.duration;
      } catch (e) {
        debugPrint('⚠️ Could not read duration: $e');
      } finally {
        await tempController.dispose();
      }

      final updatedProject = Project(
        id: _project.id,
        name: _project.name,
        createdAt: _project.createdAt,
        videoPath: filePath,
        duration: extractedDuration,
        status: _project.status,
        clipsCount: _project.clipsCount,
        lastEdited: DateTime.now(),
      );

      // Dispose old preview player before reassigning
      await _videoController?.dispose();
      _videoController = null;
      _isPlayerInitialized = false;

      // Save through the cubit so app-wide state stays in sync
      if (mounted) {
        context.read<ProjectCubit>().updateProject(updatedProject);
        setState(() => _project = updatedProject);
        await _initVideoPlayer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('✅ Video set • ${_formatDuration(extractedDuration)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectCubit, ProjectState>(
      listener: (context, state) {
        if (state is ProjectLoaded) {
          final match = state.projects.where((p) => p.id == _project.id);
          if (match.isNotEmpty && mounted) {
            setState(() => _project = match.first);
          }
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoPreview(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildAnalysisResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: _isPlayerInitialized && _videoController != null
          ? _buildVideoPlayer()
          : _buildPlaceholder(),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
        Center(
          child: IconButton.filled(
            onPressed: () => setState(() {
              _videoController!.value.isPlaying
                  ? _videoController!.pause()
                  : _videoController!.play();
            }),
            icon: Icon(
              _videoController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              size: 48,
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _formatDuration(_project.duration),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _project.videoPath != null
              ? Icons.check_circle_rounded
              : Icons.video_library_rounded,
          size: 48,
          color: _project.videoPath != null
              ? AppTheme.success
              : AppTheme.textMuted,
        ),
        const SizedBox(height: 12),
        Text(
          _project.videoPath != null ? 'Video selected' : 'No video selected',
          style: TextStyle(
            color: _project.videoPath != null
                ? AppTheme.success
                : AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        if (_project.videoPath != null) ...[
          const SizedBox(height: 6),
          Text(
            path.basename(_project.videoPath!),
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: ${_formatDuration(_project.duration)}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        if (_isSaving)
          const CircularProgressIndicator(strokeWidth: 2)
        else
          ElevatedButton.icon(
            onPressed: _pickVideo,
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: Text(
                _project.videoPath != null ? 'Change Video' : 'Select Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Info',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          _row('Created', _project.createdAt.toString().substring(0, 10)),
          const Divider(height: 16),
          _row('Duration', _formatDuration(_project.duration)),
          const Divider(height: 16),
          _row('Status', _project.status.name.toUpperCase()),
          const Divider(height: 16),
          _row('Clips', '${_project.clipsCount}'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, state) {
        final isAnalyzing = state is ProjectAnalyzing;
        final hasResults = state is ProjectAnalysisComplete;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _project.videoPath != null && !isAnalyzing
                        ? () =>
                            context.read<ProjectCubit>().startAnalysis(_project)
                        : null,
                    icon: isAnalyzing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(isAnalyzing ? 'Analyzing...' : 'AI Analyze'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisResults() {
    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, state) {
        if (state is ProjectAnalyzing) {
          return const _AnalysisLoadingView();
        }
        if (state is ProjectAnalysisComplete && state.result != null) {
          return _AnalysisResultsView(
            project: state.project,
            result: state.result!,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ──────────────────────────────────────────────
// Analysis Loading View
// ──────────────────────────────────────────────
class _AnalysisLoadingView extends StatelessWidget {
  const _AnalysisLoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            '🤖 AI is scanning your video...',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Detecting viral moments & engagement peaks...',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Analysis Results View
// ──────────────────────────────────────────────
class _AnalysisResultsView extends StatelessWidget {
  final Project project;
  final AnalysisResult result;

  const _AnalysisResultsView({
    required this.project,
    required this.result,
  });

  String _formatConfidence(double score) {
    return '${(score * 100).toStringAsFixed(0)}% Viral Score';
  }

  String _formatTime(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppTheme.success),
              const SizedBox(width: 8),
              const Text(
                '✅ Analysis Complete',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatConfidence(result.viralScore),
                  style: const TextStyle(
                    color: AppTheme.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.summary,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Clip List
          ...result.clips.map((clip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: AppTheme.background,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.15),
                    child: Text(
                      '${result.clips.indexOf(clip) + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    clip.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${_formatTime(clip.startAt)} → ${_formatTime(clip.endAt)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    '${(clip.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
