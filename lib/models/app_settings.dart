/// Session-scoped Notification/Privacy toggle state for the Settings screen.
/// Unlike this app's other shared cross-screen state (a `final List<X>`
/// mutated via `.add`/`.removeWhere`, e.g. `sampleTrips`), a bag of toggles
/// doesn't fit a list — so this is a plain mutable class with non-final
/// fields, mutated directly in place (`sampleSettings.pushNotifications =
/// false`). No backend/persistence exists for any of these yet, so values
/// reset on app restart, same as every other `sample_*.dart` seed.
class AppSettings {
  bool pushNotifications = true;
  bool likesAndComments = true;
  bool followRequests = true;
  bool communityActivity = true;
  bool shareLocation = true;
  bool allowMessagesFromAnyone = true;
}
