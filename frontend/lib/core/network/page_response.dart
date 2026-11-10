class PageResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;
  final bool empty;

  const PageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> itemJson) fromItemJson,
  ) {
    final rawContent = json['content'] as List<dynamic>? ?? [];
    final items = rawContent
        .whereType<Map<String, dynamic>>()
        .map(fromItemJson)
        .toList();

    final size = json['size'] as int? ?? items.length;
    final totalElements = json['totalElements'] as int? ?? items.length;
    final totalPages = json['totalPages'] as int? ?? (size > 0 ? (totalElements / size).ceil() : 1);
    final number = json['number'] as int? ?? 0;

    return PageResponse<T>(
      content: items,
      totalElements: totalElements,
      totalPages: totalPages > 0 ? totalPages : 1,
      size: size,
      number: number,
      first: json['first'] as bool? ?? (number == 0),
      last: json['last'] as bool? ?? (number >= totalPages - 1),
      empty: json['empty'] as bool? ?? items.isEmpty,
    );
  }
}

