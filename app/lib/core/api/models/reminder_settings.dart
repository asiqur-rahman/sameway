class ReminderSettings {
  const ReminderSettings({
    this.driverDeparture = true,
    this.driverNotifyRiders = true,
    this.riderPickup = true,
    this.riderLetDriverKnow = true,
    this.dailySummary = false,
  });

  final bool driverDeparture;
  final bool driverNotifyRiders;
  final bool riderPickup;
  final bool riderLetDriverKnow;
  final bool dailySummary;

  factory ReminderSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ReminderSettings();
    return ReminderSettings(
      driverDeparture: json['driverDeparture'] as bool? ?? true,
      driverNotifyRiders: json['driverNotifyRiders'] as bool? ?? true,
      riderPickup: json['riderPickup'] as bool? ?? true,
      riderLetDriverKnow: json['riderLetDriverKnow'] as bool? ?? true,
      dailySummary: json['dailySummary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'driverDeparture': driverDeparture,
        'driverNotifyRiders': driverNotifyRiders,
        'riderPickup': riderPickup,
        'riderLetDriverKnow': riderLetDriverKnow,
        'dailySummary': dailySummary,
      };

  ReminderSettings copyWith({
    bool? driverDeparture,
    bool? driverNotifyRiders,
    bool? riderPickup,
    bool? riderLetDriverKnow,
    bool? dailySummary,
  }) {
    return ReminderSettings(
      driverDeparture: driverDeparture ?? this.driverDeparture,
      driverNotifyRiders: driverNotifyRiders ?? this.driverNotifyRiders,
      riderPickup: riderPickup ?? this.riderPickup,
      riderLetDriverKnow: riderLetDriverKnow ?? this.riderLetDriverKnow,
      dailySummary: dailySummary ?? this.dailySummary,
    );
  }
}
