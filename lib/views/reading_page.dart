import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import '../services/reader_services.dart';

class BookReaderPage extends StatefulWidget {
  final String bookTitle;
  final List<PageModel> pages;

  const BookReaderPage({
    super.key,
    required this.bookTitle,
    required this.pages,
  });

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) {
      return const Scaffold(body: Center(child: Text("Empty Book")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      extendBodyBehindAppBar:
          true,
      appBar: AppBar(
        title: Text(
          widget.bookTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black.withOpacity(0.7), // Semi-transparent
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 28),
              tooltip: "Save to Local Library",
              onPressed: _saveToLocalLibrary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: widget.pages.length,
                itemBuilder: (context, index) {
                  return _ResponsivePageRenderer(page: widget.pages[index]);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavButton(
                    icon: Icons.chevron_left,
                    onTap: _currentPage > 0
                        ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          )
                        : null,
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${_currentPage + 1} / ${widget.pages.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  _NavButton(
                    icon: Icons.chevron_right,
                    onTap: _currentPage < widget.pages.length - 1
                        ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _saveToLocalLibrary() async {
    try {
      final box = await Hive.openBox('book_editor_box');
      final String jsonContent = jsonEncode(
        widget.pages.map((p) => _pageToJson(p)).toList(),
      );
      await box.put(widget.bookTitle, jsonContent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('"${widget.bookTitle}" saved to library!'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Map<String, dynamic> _pageToJson(PageModel page) {
    return {
      'id': page.id,
      'pageTitle': page.pageTitle,
      'page_size_X': page.pageSizeX,
      'page_size_Y': page.pageSizeY,
      'widgets': page.widgets
          .map(
            (w) => {
              'id': w.id,
              'type': w.type,
              'properties': w.properties,
              'x': w.x,
              'y': w.y,
              'width': w.width,
              'height': w.height,
            },
          ).toList(),
    };
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: onTap != null ? Colors.white54 : Colors.white10,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: onTap != null ? Colors.white : Colors.white24,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _ResponsivePageRenderer extends StatelessWidget {
  final PageModel page;

  const _ResponsivePageRenderer({required this.page});

  @override
  Widget build(BuildContext context) {
    final double pageW = page.pageSizeX > 0 ? page.pageSizeX.toDouble() : 800.0;
    final double pageH = page.pageSizeY > 0
        ? page.pageSizeY.toDouble()
        : 1000.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: InteractiveViewer(
            minScale: 0.1,
            maxScale: 4.0,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Container(
                width: pageW,
                height: pageH,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10)],
                ),
                child: ClipRect(
                  child: Stack(
                    children: page.widgets.map((w) {
                      return Positioned(
                        left: w.x,
                        top: w.y,
                        width: w.width,
                        height: w.height,
                        child: BookRendererService.buildWidget(w),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
