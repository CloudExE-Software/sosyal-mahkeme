import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'logger_service.dart';

/// Bağlantı durumu yönetimi
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  final ValueNotifier<bool> isOnline = ValueNotifier(true);
  final ValueNotifier<ConnectivityType> connectionType = 
      ValueNotifier(ConnectivityType.unknown);

  bool _isInitialized = false;

  /// Servisi başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // İlk durumu kontrol et
      await checkConnectivity();

      // Değişiklikleri dinle
      _subscription = _connectivity.onConnectivityChanged.listen(
        _handleConnectivityChange,
        onError: (error) {
          LoggerService.error('Connectivity error', error: error);
        },
      );

      _isInitialized = true;
      LoggerService.info('ConnectivityService initialized');
    } catch (e) {
      LoggerService.error('Failed to initialize ConnectivityService', error: e);
    }
  }

  /// Bağlantı durumunu kontrol et
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasConnection = _hasInternetConnection(results);
      
      isOnline.value = hasConnection;
      connectionType.value = _getConnectionType(results);
      
      return hasConnection;
    } catch (e) {
      LoggerService.error('Failed to check connectivity', error: e);
      return false;
    }
  }

  /// Bağlantı değişikliğini işle
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection = _hasInternetConnection(results);
    final oldValue = isOnline.value;
    
    isOnline.value = hasConnection;
    connectionType.value = _getConnectionType(results);

    if (oldValue != hasConnection) {
      LoggerService.info(
        'Connection changed: ${hasConnection ? "ONLINE" : "OFFLINE"} (${connectionType.value})'
      );
    }
  }

  /// Internet bağlantısı var mı?
  bool _hasInternetConnection(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  /// Bağlantı tipini belirle
  ConnectivityType _getConnectionType(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityType.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityType.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityType.ethernet;
    } else if (results.contains(ConnectivityResult.vpn)) {
      return ConnectivityType.vpn;
    }
    return ConnectivityType.none;
  }

  /// Dispose - Bağlantı dinleyicisini temizle (çağrılmazsa memory leak!)
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    isOnline.dispose();
    connectionType.dispose();
    _isInitialized = false;
  }
}

/// Bağlantı tipleri
enum ConnectivityType {
  wifi,
  mobile,
  ethernet,
  vpn,
  none,
  unknown,
}
