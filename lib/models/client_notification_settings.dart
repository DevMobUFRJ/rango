class ClientNotificationSettings {
  bool messages;
  bool reservation;

  ClientNotificationSettings({
    this.messages,
    this.reservation,
  });

  ClientNotificationSettings.fromJson(Map<String, dynamic> json)
      : messages = json['messages'],
        reservation = json['reservation'];

  Map<String, dynamic> toJson() =>
      {'messages': messages, 'reservation': reservation};
}
