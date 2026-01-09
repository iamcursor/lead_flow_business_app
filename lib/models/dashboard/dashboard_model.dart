class DashboardModel {
  final int todayJobs;
  final int totalCompleted;
  final double avgRating;
  final String thisWeekEarning;

  DashboardModel({
    required this.todayJobs,
    required this.totalCompleted,
    required this.avgRating,
    required this.thisWeekEarning,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      todayJobs: json['today_jobs'] ?? 0,
      totalCompleted: json['total_completed'] ?? 0,
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      thisWeekEarning: json['this_week_earning'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_jobs': todayJobs,
      'total_completed': totalCompleted,
      'avg_rating': avgRating,
      'this_week_earning': thisWeekEarning,
    };
  }
}


