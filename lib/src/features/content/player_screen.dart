import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.targetType, required this.id, this.title});

  final String targetType;
  final String id;
  final String? title;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  WatchSession? _session;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final stream = widget.targetType == 'reel'
          ? await ref.read(reelsRepositoryProvider).stream(widget.id)
          : await ref.read(contentRepositoryProvider).stream(widget.id);
      if (stream.playableUrl.isEmpty) {
        setState(() {
          _error = 'Video asset is not ready yet.';
          _loading = false;
        });
        return;
      }
      _session = await ref.read(analyticsRepositoryProvider).startWatch(targetType: widget.targetType, targetId: widget.id);
      final controller = VideoPlayerController.networkUrl(Uri.parse(stream.playableUrl));
      await controller.initialize();
      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: widget.targetType == 'reel',
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(playedColor: AppTheme.primary, handleColor: AppTheme.primary, backgroundColor: Colors.white24, bufferedColor: Colors.white54),
      );
      setState(() {
        _videoController = controller;
        _chewieController = chewie;
        _loading = false;
      });
    } on ApiException catch (error) {
      setState(() {
        _error = error.statusCode == 402 ? 'Active subscription required. Please choose a plan first.' : error.message;
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _endWatch() async {
    final session = _session;
    final controller = _videoController;
    if (session == null || controller == null) return;
    try {
      final seconds = controller.value.position.inSeconds;
      final completed = controller.value.duration.inSeconds > 0 && seconds >= (controller.value.duration.inSeconds * .9);
      await ref.read(analyticsRepositoryProvider).endWatch(watchSessionId: session.id, secondsWatched: seconds, completed: completed);
    } catch (_) {
      // Do not block navigation if analytics submission fails.
    }
  }

  @override
  void dispose() {
    _endWatch();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Player')),
        body: EmptyState(title: 'Cannot play video', message: _error!, icon: Icons.play_disabled_rounded),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(18),
          child: PrimaryButton(label: 'View subscription plans', icon: Icons.workspace_premium_rounded, onPressed: () => context.push('/subscribe')),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.title ?? 'Now Playing'), backgroundColor: Colors.black),
      body: Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio == 0 ? 16 / 9 : _videoController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      ),
    );
  }
}
