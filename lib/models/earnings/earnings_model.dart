class EarningsSummary {
  final double totalEarnings;
  final double averagePerJob;
  final double pendingPayouts;
  final int jobsCompleted;

  EarningsSummary({
    required this.totalEarnings,
    required this.averagePerJob,
    required this.pendingPayouts,
    required this.jobsCompleted,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalEarnings: (json['total_earnings'] ?? json['totalEarnings'] ?? 0).toDouble(),
      averagePerJob: (json['average_per_job'] ?? json['averagePerJob'] ?? 0).toDouble(),
      pendingPayouts: (json['pending_payouts'] ?? json['pendingPayouts'] ?? 0).toDouble(),
      jobsCompleted: json['jobs_completed'] ?? json['jobsCompleted'] ?? 0,
    );
  }
}

class DailyEarning {
  final String date;
  final double amount;

  DailyEarning({
    required this.date,
    required this.amount,
  });

  factory DailyEarning.fromJson(Map<String, dynamic> json) {
    return DailyEarning(
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class JobEarning {
  final String jobTitle;
  final String date;
  final String time;
  final double amount;
  final String status;

  JobEarning({
    required this.jobTitle,
    required this.date,
    required this.time,
    required this.amount,
    required this.status,
  });

  factory JobEarning.fromJson(Map<String, dynamic> json) {
    return JobEarning(
      jobTitle: json['job_title'] ?? json['jobTitle'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
    );
  }
}

