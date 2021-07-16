class UserNotificationSettings {
  bool messages;
  bool orders;

  UserNotificationSettings({
    this.messages,
    this.orders,
  });

  UserNotificationSettings.fromJson(Map<String, dynamic> json)
      : messages = json['messages'],
        orders = json['orders'];

  Map<String, dynamic> toJson() => {'messages': messages, 'orders': orders};
}
