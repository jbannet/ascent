class ReadinessAdjustment {
  final double low;
  final double high;
  
  ReadinessAdjustment({ this.low = -0.05, this.high = 0.05 });

  factory ReadinessAdjustment.fromJson(Map<String, dynamic> json) => ReadinessAdjustment(
    low: (json['low'] as num?)?.toDouble() ?? -0.05,
    high: (json['high'] as num?)?.toDouble() ?? 0.05,
  );

  Map<String, dynamic> toJson() => { 
    'low': low, 
    'high': high 
  };
}