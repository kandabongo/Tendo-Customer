import 'dart:async';
import 'dart:convert';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Generic stale-while-revalidate cache for API responses.
///
/// Reads return whatever is on disk immediately (regardless of age). If the
/// cached entry is missing or older than [ttl], a background refresh is
/// kicked off (or awaited inline when there's nothing cached yet) and
/// [onBackgroundUpdate] fires once fresh data lands, so callers can
/// notifyListeners() without blocking the initial render.
class CacheService {
  static const _boxName = 'api_cache';
  static Box<String>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _cacheBox {
    final box = _box;
    if (box == null) {
      throw StateError('CacheService.init() must be called before use');
    }
    return box;
  }

  /// Fetches [key] using a stale-while-revalidate strategy.
  ///
  /// - [fetch] hits the network and returns the raw decoded value.
  /// - [toJson]/[fromJson] (de)serialize that value for disk storage.
  /// - [ttl] is how long a cached value is served without triggering a
  ///   background refresh.
  /// - [onBackgroundUpdate] is called with the fresh value once a background
  ///   refresh completes (only when it differs from what was just returned).
  /// - [isEmptyResult], when provided, flags a value (freshly-fetched or
  ///   read from disk) as "empty" (e.g. an empty list). An empty result is
  ///   never written to disk, and an empty value already on disk is always
  ///   treated as stale regardless of [ttl] - so it can never get stuck
  ///   being served as if it were a real, confirmed answer, and it
  ///   self-heals any empty entry that was persisted before this guard
  ///   existed. This matters for requests whose params can be incomplete
  ///   early on (e.g. vendor types fetched before the delivery location
  ///   resolves): without this, one unlucky empty response gets cached and
  ///   silently re-served under the same key until it expires.
  static Future<T> staleWhileRevalidate<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() fetch,
    required Object? Function(T value) toJson,
    required T Function(Object? json) fromJson,
    void Function(T value)? onBackgroundUpdate,
    bool Function(T value)? isEmptyResult,
  }) async {
    final raw = _cacheBox.get(key);
    final cached = raw == null ? null : _decodeEntry(raw, fromJson);

    if (cached == null) {
      //nothing on disk yet, must wait for the network
      final fresh = await fetch();
      if (isEmptyResult == null || !isEmptyResult(fresh)) {
        await _store(key, toJson(fresh));
      }
      return fresh;
    }

    final cachedIsEmpty = isEmptyResult?.call(cached.value) ?? false;
    if (cachedIsEmpty) {
      //never trust an empty cached value, however fresh it is by TTL - it
      //may have been written before this guard existed, or the earlier
      //fetch that produced it may have run before required params (e.g.
      //location) were ready. Wait for a real network answer instead of
      //serving a known-empty result.
      final fresh = await fetch();
      if (isEmptyResult == null || !isEmptyResult(fresh)) {
        await _store(key, toJson(fresh));
      }
      return fresh;
    }

    final isStale = DateTime.now().difference(cached.cachedAt) > ttl;
    if (isStale) {
      //return stale data now, refresh quietly in the background
      unawaited(
        fetch()
            .then((fresh) async {
              //an empty refresh is treated as inconclusive, not as "now
              //empty" - skip persisting it and skip notifying the caller,
              //so the still-good stale cache keeps being served until a
              //refresh actually returns something.
              if (isEmptyResult != null && isEmptyResult(fresh)) {
                return;
              }
              await _store(key, toJson(fresh));
              onBackgroundUpdate?.call(fresh);
            })
            .catchError((_) {
              //keep serving the stale cache if the background refresh fails
            }),
      );
    }

    return cached.value;
  }

  static Future<void> _store(String key, Object? json) async {
    final entry = jsonEncode({
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'data': json,
    });
    await _cacheBox.put(key, entry);
  }

  static _CacheEntry<T>? _decodeEntry<T>(
    String raw,
    T Function(Object? json) fromJson,
  ) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _CacheEntry(
        cachedAt: DateTime.fromMillisecondsSinceEpoch(map['cachedAt'] as int),
        value: fromJson(map['data']),
      );
    } catch (_) {
      //corrupt/incompatible entry, treat as no cache
      return null;
    }
  }

  static Future<void> clear(String key) => _cacheBox.delete(key);

  static Future<void> clearAll() => _cacheBox.clear();
}

class _CacheEntry<T> {
  _CacheEntry({required this.cachedAt, required this.value});
  final DateTime cachedAt;
  final T value;
}
