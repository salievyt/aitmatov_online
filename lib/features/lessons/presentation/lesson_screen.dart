import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../domain/entities/lesson.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../../domain/repositories/progress_repository.dart';

class LessonScreen extends StatefulWidget {
  final int courseId;
  final int lessonId;

  const LessonScreen({super.key, required this.courseId, required this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  Lesson? _lesson;
  List<Lesson> _lessons = [];
  bool _isLoading = true;
  bool _isCompleted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final lessonsResult = await context.read<CourseRepository>().getLessons(widget.courseId);
    lessonsResult.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (lessons) {
        final lesson = lessons.cast<Lesson?>().firstWhere(
              (item) => item?.id == widget.lessonId,
              orElse: () => null,
            );

        setState(() {
          _lessons = lessons..sort((a, b) => a.order.compareTo(b.order));
          _lesson = lesson;
          _isLoading = false;
          if (_lesson == null) {
            _error = 'Урок не найден в этом курсе';
          }
        });
      },
    );
  }

  Future<void> _markAsCompleted() async {
    if (_lesson == null) return;

    final result = await context.read<ProgressRepository>().updateProgress(
          lessonId: _lesson!.id,
          completed: true,
        );

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${failure.message}')),
      ),
      (progress) {
        setState(() => _isCompleted = true);
        _navigateToNextLesson();
      },
    );
  }

  void _navigateToNextLesson() {
    if (_lesson == null || _lessons.isEmpty) return;

    final currentIndex = _lessons.indexWhere((l) => l.id == _lesson!.id);
    if (currentIndex == -1 || currentIndex == _lessons.length - 1) return;

    final nextLesson = _lessons[currentIndex + 1];
    context.push('/courses/${widget.courseId}/lessons/${nextLesson.id}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_lesson?.title ?? 'Урок'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64),
                        const SizedBox(height: 16),
                        Text('Ошибка загрузки', style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(_error!, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _loadLesson, child: const Text('Повторить')),
                      ],
                    ),
                  ),
                )
              : _lesson == null
                  ? const Center(child: Text('Урок не найден'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_getContentTypeIcon(_lesson!.contentType), color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                _getContentTypeLabel(_lesson!.contentType),
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _lesson!.title,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildLearningPlan(theme),
                          const SizedBox(height: 16),
                          _buildContentByType(_lesson!),
                          const SizedBox(height: 16),
                          if (_lesson!.quizEnabled) _buildQuizBlock(theme),
                          if (_lesson!.quizEnabled) const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isCompleted ? null : _markAsCompleted,
                              child: Text(_isCompleted ? 'Завершено' : 'Завершить урок'),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildContentByType(Lesson lesson) {
    final normalizedType = lesson.contentType.toLowerCase();
    if (normalizedType == 'video') {
      if (lesson.videoUrl == null || lesson.videoUrl!.isEmpty) {
        return const _MissingContentWidget(message: 'Видео пока недоступно для этого урока');
      }
      return _VideoLessonWebView(url: lesson.videoUrl!);
    }

    if (normalizedType == 'audio') {
      if (lesson.audioUrl == null || lesson.audioUrl!.isEmpty) {
        return const _MissingContentWidget(message: 'Аудио пока недоступно для этого урока');
      }
      return _AudioLessonPlayer(audioUrl: lesson.audioUrl!);
    }

    if (lesson.textBody == null || lesson.textBody!.trim().isEmpty) {
      return const _MissingContentWidget(message: 'Текст урока пока не заполнен');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          lesson.textBody!,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildLearningPlan(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('План урока', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            const Text('1. Изучи основной материал в этом уроке.'),
            const SizedBox(height: 6),
            const Text('2. Сделай короткий конспект своими словами (3-5 пунктов).'),
            const SizedBox(height: 6),
            const Text('3. Проверь себя: ответь, что ты понял и где можешь применить это на практике.'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizBlock(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz),
                const SizedBox(width: 8),
                Text('Самопроверка', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Тест включен для этого урока. После изучения материала обязательно пройди проверку.'),
          ],
        ),
      ),
    );
  }

  IconData _getContentTypeIcon(String contentType) {
    switch (contentType) {
      case 'video':
        return Icons.play_circle_outline;
      case 'audio':
        return Icons.audiotrack;
      case 'text':
      default:
        return Icons.article;
    }
  }

  String _getContentTypeLabel(String contentType) {
    switch (contentType) {
      case 'video':
        return 'Видео урок';
      case 'audio':
        return 'Аудио урок';
      case 'text':
      default:
        return 'Текстовый урок';
    }
  }
}

class _VideoLessonWebView extends StatefulWidget {
  final String url;

  const _VideoLessonWebView({required this.url});

  @override
  State<_VideoLessonWebView> createState() => _VideoLessonWebViewState();
}

class _VideoLessonWebViewState extends State<_VideoLessonWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final sourceUrl = _toEmbeddableVideoUrl(widget.url);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(sourceUrl));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 220,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }

  String _toEmbeddableVideoUrl(String inputUrl) {
    final uri = Uri.tryParse(inputUrl);
    if (uri == null) return inputUrl;

    if (uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) {
        return 'https://www.youtube.com/embed/$videoId';
      }
    }

    if (uri.host.contains('youtu.be')) {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty && segments.first.isNotEmpty) {
        return 'https://www.youtube.com/embed/${segments.first}';
      }
    }

    return inputUrl;
  }
}

class _AudioLessonPlayer extends StatefulWidget {
  final String audioUrl;

  const _AudioLessonPlayer({required this.audioUrl});

  @override
  State<_AudioLessonPlayer> createState() => _AudioLessonPlayerState();
}

class _AudioLessonPlayerState extends State<_AudioLessonPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    setState(() => _isLoading = true);
    if (_isPlaying) {
      await _player.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
        });
      }
      return;
    }

    await _player.play(UrlSource(widget.audioUrl));
    if (mounted) {
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FilledButton.icon(
              onPressed: _togglePlayback,
              icon: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(_isPlaying ? 'Пауза' : 'Слушать'),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Аудио-урок. Нажми «Слушать», чтобы начать обучение.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingContentWidget extends StatelessWidget {
  final String message;

  const _MissingContentWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
