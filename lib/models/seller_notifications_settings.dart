class SellerNotificationSettings {
  bool messages;
  bool orders;

  SellerNotificationSettings({
    this.messages = false,
    this.orders = false,
  });

  SellerNotificationSettings.fromJson(Map<String, dynamic> json)
      : orders = json['orders'],
        messages = json['messages'];
}
