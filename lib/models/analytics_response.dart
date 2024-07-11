class AnalyticsResponse {
  final String success;
  final String message;
  final List<AnalyticsData> analytics;

  AnalyticsResponse({
    required this.success,
    required this.message,
    required this.analytics,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    List<AnalyticsData> analyticsList = [];
    if (json['Analytics'] != null) {
      for (var data in json['Analytics']) {
        if (data["date"] == "0000-00-00") continue;
        AnalyticsData analyticsData = AnalyticsData.fromJson(data);
        analyticsList.add(analyticsData);
      }
    }

    return AnalyticsResponse(
      success: json['success'],
      message: json['message'],
      analytics: analyticsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'Analytics': analytics.map((data) => data.toJson()).toList(),
    };
  }
}

class AnalyticsData {
  final DateTime date;
  final double count;
  final double amount;

  AnalyticsData({
    required this.date,
    required this.count,
    required this.amount,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    DateTime date;
    double count;
    double amount;

    try {
      date = DateTime.parse(json['date'] ?? '');
    } catch (e) {
      date = DateTime.fromMillisecondsSinceEpoch(0); // default value
    }

    try {
      count = double.parse(json['count']?.toString() ?? '0');
    } catch (e) {
      count = 0; // default value
    }

    try {
      amount = double.parse(json['amount']?.toString() ?? '0');
    } catch (e) {
      amount = 0; // default value
    }

    return AnalyticsData(
      date: date,
      count: count,
      amount: amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'count': count.toString(),
      'amount': amount.toString(),
    };
  }
}
