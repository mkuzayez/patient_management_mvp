import 'dart:developer';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();

  factory CacheManager() => _instance;

  CacheManager._internal() {
    _initializeCache();
  }

  final Map<String, dynamic> _cache = {};

  void _initializeCache() {
    log("Cache started");
  }

  void cacheData<T>({required String key, required T data}) {
    if (data == null) {
      log("Error: Attempted to cache null data for key: $key");
      return;
    }
    _cache[key] = data;
    log("Cached data for key: $key");
  }

  T? getData<T>({required String key}) {
    return _cache[key] as T?;
  }

  void clearData({required String key}) {
    _cache.remove(key);
    log("Cleared cache for key: $key");
  }

  void clearAll() {
    _cache.clear();
    log("Cache cleared");
  }
}
