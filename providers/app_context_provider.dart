import 'package:flutter/foundation.dart';

import '../models/app_context_model.dart';
import '../services/app_context_service.dart';

class AppContextProvider extends ChangeNotifier {
  final AppContextService _service;
  AppContext? _appContext;
  Object? _error;
  bool _isLoading = false;
  bool _isDisposed = false;
  Future<void> _requestQueue = Future<void>.value();

  AppContextProvider({AppContextService? service})
    : _service = service ?? AppContextService();

  AppContext? get appContext => _appContext;
  Object? get error => _error;
  bool get isLoading => _isLoading;
  bool get isInitialized => _appContext != null;

  Future<void> init(String appName) {
    final request = _requestQueue.then((_) => _loadAppContext(appName));
    _requestQueue = request.onError((Object error, StackTrace stackTrace) {
      debugPrint('Error loading app context for $appName: $error');
    });
    return request;
  }

  Future<void> _loadAppContext(String appName) async {
    if (_isDisposed) {
      throw StateError('The app context provider has been disposed.');
    }

    _isLoading = true;
    if (_appContext?.alias != appName) {
      _appContext = null;
    }
    _error = null;
    notifyListeners();

    try {
      _appContext = await _service.getAppContext(appName);
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
