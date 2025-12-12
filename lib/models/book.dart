import 'package:equatable/equatable.dart';

class PageModel extends Equatable {
  final String id;
  final String pageTitle;
  final int pageSizeX;
  final int pageSizeY;
  final List<WidgetModel> widgets;

  const PageModel({
    required this.id,
    required this.pageTitle,
    this.pageSizeX = 800,
    this.pageSizeY = 1000,
    required this.widgets,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id'] ?? 'unknown',
      pageTitle: json['pageTitle'] ?? 'Untitled Page',
      pageSizeX: json['page_size_X'] ?? 800,
      pageSizeY: json['page_size_Y'] ?? 1000,
      widgets: (json['widgets'] as List<dynamic>? ?? [])
          .map((w) => WidgetModel.fromJson(Map<String, dynamic>.from(w)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, pageTitle, pageSizeX, pageSizeY, widgets];
}

class WidgetModel extends Equatable {
  final String id;
  final String type;
  final Map<String, dynamic> properties;
  final double x;
  final double y;
  final double width;
  final double height;

  const WidgetModel({
    required this.id,
    required this.type,
    required this.properties,
    this.x = 0,
    this.y = 0,
    this.width = 200,
    this.height = 100,
  });

  factory WidgetModel.fromJson(Map<String, dynamic> json) {
    return WidgetModel(
      id: json['id'] ?? 'unknown',
      type: json['type'] ?? 'Text',
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 200).toDouble(),
      height: (json['height'] ?? 100).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, type, properties, x, y, width, height];
}
