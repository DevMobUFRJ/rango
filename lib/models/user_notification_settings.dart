class UserNotificationSettings {
  bool discounts;
  bool favoriteSellers;
  bool messages;
  bool reservations;

  UserNotificationSettings({
    this.discounts = false,
    this.favoriteSellers = false,
    this.messages = false,
    this.reservations = false,
  });

  UserNotificationSettings.fromJson(Map<String, dynamic> json)
      : discounts = json['discounts'],
        favoriteSellers = json['favoriteSellers'],
        messages = json['messages'],
        reservations = json['reservations'];
}
