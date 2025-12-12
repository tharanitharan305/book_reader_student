import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/book.dart';

class BookRendererService {
  static Widget buildWidget(WidgetModel model) {
    switch (model.type.toLowerCase()) {
      case 'text':
        return _TextRenderer(model: model);
      case 'image':
        return _ImageRenderer(model: model);
      case 'video':
        return _VideoRenderer(model: model);
      case 'audio':
        return _AudioRenderer(model: model);
      default:
        return const SizedBox.shrink();
    }
  }

  static Color parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.black;
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.black;
    }
  }
}

class _TextRenderer extends StatelessWidget {
  final WidgetModel model;
  const _TextRenderer({required this.model});

  @override
  Widget build(BuildContext context) {
    final props = model.properties;
    final fontSize = (props['fontSize'] as num?)?.toDouble() ?? 16.0;
    final color = BookRendererService.parseColor(props['color']);
    final bgColor = props['backgroundColor'] != null
        ? BookRendererService.parseColor(props['backgroundColor'])
        : Colors.transparent;
    final isBold = props['isBold'] == true;
    final isItalic = props['isItalic'] == true;
    final isUnderline = props['isUnderline'] == true;
    final fontFamily = props['fontFamily'] as String? ?? 'Roboto';

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.topLeft,
      child: Text(
        props['text'] ?? '',
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          decoration: isUnderline
              ? TextDecoration.underline
              : TextDecoration.none,
          fontFamily: fontFamily,
        ),
      ),
    );
  }
}

class _ImageRenderer extends StatelessWidget {
  final WidgetModel model;
  const _ImageRenderer({required this.model});

  @override
  Widget build(BuildContext context) {
    final src = model.properties['src'] as String?;
    if (src == null || src.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image),
      );
    }
    return Image.network(
      src,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.error)),
      loadingBuilder: (_, child, p) =>
          p == null ? child : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _VideoRenderer extends StatefulWidget {
  final WidgetModel model;
  const _VideoRenderer({required this.model});

  @override
  State<_VideoRenderer> createState() => _VideoRendererState();
}

class _VideoRendererState extends State<_VideoRenderer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final src = widget.model.properties['src'] as String?;
    if (src != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(src))
        ..initialize().then((_) {
          if (mounted) setState(() => _isInitialized = true);
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
        if (!_controller!.value.isPlaying)
          GestureDetector(
            onTap: () => setState(() => _controller!.play()),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => setState(() => _controller!.pause()),
            behavior: HitTestBehavior.translucent,
            child: Container(), // Invisible layer to catch pause taps
          ),
      ],
    );
  }
}

class _AudioRenderer extends StatefulWidget {
  final WidgetModel model;
  const _AudioRenderer({required this.model});

  @override
  State<_AudioRenderer> createState() => _AudioRendererState();
}

class _AudioRendererState extends State<_AudioRenderer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final src = widget.model.properties['src'] as String?;
    if (src != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(src))
        ..initialize().then((_) {
          if (mounted) setState(() => _isInitialized = true);
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _controller?.value.isPlaying ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_note, color: Colors.indigo),
          const SizedBox(width: 8),
          if (!_isInitialized)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
              ),
              color: Colors.indigo,
              iconSize: 36,
              onPressed: () {
                setState(() {
                  isPlaying ? _controller!.pause() : _controller!.play();
                });
              },
            ),
        ],
      ),
    );
  }
}
