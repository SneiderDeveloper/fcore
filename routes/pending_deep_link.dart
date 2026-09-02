
// A notification may arrive while the app is closed: at that moment, the router
// is still on the splash screen setting up the session, so the global redirect cannot
// take the user to the requested view. Instead of losing the destination, it
// leaves it here, and [HomePage] processes it as soon as the session is ready.
class PendingDeepLink {
  PendingDeepLink._();

  static String? _location;

  static bool get hasPending => _location != null;

  // Remember [location] so you can open it when you're logged in.
  static void save(String location) {
    _location = location;
  }

  // Returns the pending destination once.
  static String? consume() {
    final location = _location;
    _location = null;
    return location;
  }

  static void clear() {
    _location = null;
  }
}
