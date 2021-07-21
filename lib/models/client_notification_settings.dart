class ClientNotificationSettings {
  bool messages;
  bool reservations;

  ClientNotificationSettings({
    this.messages,
    this.reservations,
  });

  ClientNotificationSettings.fromJson(Map<String, dynamic> json)
      : messages = json['messages'],
        reservations = json['reservations'];

  Map<String, dynamic> toJson() =>
      {'messages': messages, 'reservations': reservations};
}
