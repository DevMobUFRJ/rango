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
}
