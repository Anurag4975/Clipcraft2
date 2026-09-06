import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/project.dart';
import '../cubit/project_cubit.dart';

class ProjectDetailPage extends StatelessWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(project.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
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
      // ignore: use_build_context_synchronously
      context.read<ProjectCubit>().updateProject(updatedProject);

      setState(() => _project = updatedProject);
      await _initVideoPlayer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            '✅ Video set • ${_formatDuration(extractedDuration)}',
          )),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoPreview(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
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
        Text(_project.videoPath != null
            ? 'Video selected'
            : 'No video selected'),
        if (_project.videoPath != null) ...[
          const SizedBox(height: 6),
          Text(path.basename(_project.videoPath!),
              style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text('Duration: ${_formatDuration(_project.duration)}'),
        ],
        const SizedBox(height: 16),
        _isSaving
            ? const CircularProgressIndicator(strokeWidth: 2)
            : ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: Text(_project.videoPath != null
                    ? 'Change Video'
                    : 'Select Video'),
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
          const Text('Project Info',
              style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          _row('Created', _project.createdAt.toString().substring(0, 10)),
          const Divider(height: 16),
          _row('Duration', _formatDuration(_project.duration)),
          const Divider(height: 16),
          _row('Status', _project.status.name),
          const Divider(height: 16),
          _row('Clips', '${_project.clipsCount}'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _project.videoPath != null
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI Analysis coming next!')),
                    )
                : null,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('AI Analyze'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
