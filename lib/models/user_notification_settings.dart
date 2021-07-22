class UserNotificationSettings {
  bool messages;
  bool reservations;

  UserNotificationSettings({
    this.messages = false,
    this.reservations = false,
  });

  UserNotificationSettings.fromJson(Map<String, dynamic> json)
      : reservations = json['reservations'],
        messages = json['messages'];

  Map<String, dynamic> toJson() =>
      {'messages': messages, 'reservations': reservations};
}
