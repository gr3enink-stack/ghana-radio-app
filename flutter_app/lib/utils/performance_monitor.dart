import 'dart:collection';

/// Performance monitoring utility for tracking playback metrics
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<PerformanceMetric> _metrics = [];
  static const int _maxHistorySize = 50; // Keep last 50 measurements

  /// Record a performance metric
  void recordMetric({
    required String action,
    required Duration duration,
    String? label,
    Map<String, dynamic>? metadata,
  }) {
    final metric = PerformanceMetric(
      action: action,
      duration: duration,
      label: label,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _metrics.add(metric);

    // Maintain bounded history
    if (_metrics.length > _maxHistorySize) {
      _metrics.removeAt(0);
    }

    // Log the metric
    _logMetric(metric);
  }

  /// Log metric to console with formatting
  void _logMetric(PerformanceMetric metric) {
    final emoji = _getPerformanceEmoji(metric.duration);
    final rating = _getPerformanceRating(metric.duration);
    
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║  ⏱️  PERFORMANCE METRIC                                  ║');
    print('╠═══════════════════════════════════════════════════════════╣');
    print('║  Action: ${_padRight(metric.action, 48)}║');
    if (metric.label != null) {
      print('║  Label: ${_padRight(metric.label!, 49)}║');
    }
    print('║  Duration: ${_padRight('${metric.duration.inMilliseconds}ms', 45)}║');
    print('║  Rating: ${_padRight(rating, 49)}║');
    print('║  Time: ${_padRight(metric.timestamp.toIso8601String(), 49)}║');
    print('╚═══════════════════════════════════════════════════════════╝');
  }

  String _padRight(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    return text + ' ' * (width - text.length);
  }

  String _getPerformanceEmoji(Duration duration) {
    if (duration.inMilliseconds < 500) return '⚡';
    if (duration.inMilliseconds < 1000) return '✅';
    if (duration.inMilliseconds < 2000) return '👍';
    if (duration.inMilliseconds < 3000) return '⚠️';
    return '🐌';
  }

  String _getPerformanceRating(Duration duration) {
    if (duration.inMilliseconds < 500) return 'EXCELLENT (<0.5s)';
    if (duration.inMilliseconds < 1000) return 'GOOD (0.5-1s)';
    if (duration.inMilliseconds < 2000) return 'ACCEPTABLE (1-2s)';
    if (duration.inMilliseconds < 3000) return 'SLOW (2-3s)';
    return 'VERY SLOW (>3s)';
  }

  /// Get average duration for a specific action
  Duration? getAverageDuration(String action) {
    final matchingMetrics = _metrics.where((m) => m.action == action).toList();
    
    if (matchingMetrics.isEmpty) return null;

    final totalMs = matchingMetrics.fold<int>(
      0,
      (sum, metric) => sum + metric.duration.inMilliseconds,
    );

    return Duration(milliseconds: totalMs ~/ matchingMetrics.length);
  }

  /// Get the best (fastest) time for an action
  Duration? getBestTime(String action) {
    final matchingMetrics = _metrics.where((m) => m.action == action).toList();
    
    if (matchingMetrics.isEmpty) return null;

    return matchingMetrics.reduce(
      (a, b) => a.duration < b.duration ? a : b,
    ).duration;
  }

  /// Get the worst (slowest) time for an action
  Duration? getWorstTime(String action) {
    final matchingMetrics = _metrics.where((m) => m.action == action).toList();
    
    if (matchingMetrics.isEmpty) return null;

    return matchingMetrics.reduce(
      (a, b) => a.duration > b.duration ? a : b,
    ).duration;
  }

  /// Get all metrics for an action
  List<PerformanceMetric> getMetricsForAction(String action) {
    return _metrics.where((m) => m.action == action).toList();
  }

  /// Get recent metrics
  List<PerformanceMetric> getRecentMetrics({int count = 10}) {
    return _metrics.take(count).toList();
  }

  /// Print summary statistics
  void printSummary() {
    print('\n╔═══════════════════════════════════════════════════════════╗');
    print('║  📊  PERFORMANCE SUMMARY                                 ║');
    print('╠═══════════════════════════════════════════════════════════╣');

    final actions = _metrics.map((m) => m.action).toSet();
    
    for (final action in actions) {
      final avg = getAverageDuration(action);
      final best = getBestTime(action);
      final worst = getWorstTime(action);
      final count = _metrics.where((m) => m.action == action).length;

      print('║');
      print('║  🎯 $action');
      print('║     Samples: $count');
      if (avg != null) {
        print('║     Average: ${avg.inMilliseconds}ms');
      }
      if (best != null) {
        print('║     Best: ${best.inMilliseconds}ms');
      }
      if (worst != null) {
        print('║     Worst: ${worst.inMilliseconds}ms');
      }
      print('║');
    }

    print('╚═══════════════════════════════════════════════════════════╝\n');
  }

  /// Clear all metrics
  void clear() {
    _metrics.clear();
    print('🗑️ Performance metrics cleared');
  }
}

/// Represents a single performance measurement
class PerformanceMetric {
  final String action;
  final Duration duration;
  final String? label;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.action,
    required this.duration,
    this.label,
    required this.timestamp,
    this.metadata,
  });

  @override
  String toString() {
    return 'PerformanceMetric(action: $action, duration: ${duration.inMilliseconds}ms, label: $label)';
  }
}

/// Helper class for easy performance tracking
class PerformanceTimer {
  final String action;
  final String? label;
  final DateTime _startTime;
  final Map<String, dynamic>? metadata;

  PerformanceTimer(this.action, {this.label, this.metadata})
      : _startTime = DateTime.now();

  /// Stop the timer and record the metric
  void stop() {
    final duration = DateTime.now().difference(_startTime);
    PerformanceMonitor().recordMetric(
      action: action,
      duration: duration,
      label: label,
      metadata: metadata,
    );
  }
}
