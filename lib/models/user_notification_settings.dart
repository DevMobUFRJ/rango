class UserNotificationSettings {
  bool messages;
  bool newOrder;
  bool orderCanceled;

  UserNotificationSettings({
    this.messages,
    this.newOrder,
    this.orderCanceled
  });

  UserNotificationSettings.fromJson(Map<String, dynamic> json)
      : messages = json['messages'],
        newOrder = json['newOrder'],
        orderCanceled = json['orderCanceled'];

  Map<String, dynamic> toJson() => {
    'messages': messages,
    'newOrder': newOrder,
    'orderCanceled': orderCanceled
  };
}