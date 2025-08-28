import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service for handling Firebase operations with retry logic and exponential backoff
class FirebaseRetryService {
  static const int _maxRetries = 3;
  static const int _baseDelayMs = 1000;
  static const double _backoffMultiplier = 2.0;
  static const double _jitterFactor = 0.1;

  /// Execute a Firestore operation with retry logic and exponential backoff
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
    int baseDelayMs = _baseDelayMs,
    double backoffMultiplier = _backoffMultiplier,
  }) async {
    int attempt = 0;
    
    while (attempt <= maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        if (attempt > maxRetries || !_isRetryableError(e)) {
          debugPrint('❌ Firebase operation failed after $attempt attempts: $e');
          rethrow;
        }
        
        final int delayMs = _calculateDelay(attempt, baseDelayMs, backoffMultiplier);
        debugPrint('⚠️  Firebase operation failed (attempt $attempt/$maxRetries): $e');
        debugPrint('🔄 Retrying in ${delayMs}ms...');
        
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    
    throw Exception('Maximum retry attempts exceeded');
  }

  /// Check if the error is retryable
  static bool _isRetryableError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
        case 'deadline-exceeded':
        case 'internal':
        case 'resource-exhausted':
        case 'aborted':
          return true;
        case 'permission-denied':
        case 'not-found':
        case 'already-exists':
        case 'failed-precondition':
        case 'out-of-range':
        case 'unimplemented':
        case 'data-loss':
        case 'unauthenticated':
          return false;
        default:
          return false;
      }
    }
    return false;
  }

  /// Calculate delay with exponential backoff and jitter
  static int _calculateDelay(int attempt, int baseDelayMs, double backoffMultiplier) {
    final double exponentialDelay = baseDelayMs * pow(backoffMultiplier, attempt - 1).toDouble();
    final double jitter = exponentialDelay * _jitterFactor * (Random().nextDouble() - 0.5);
    return (exponentialDelay + jitter).round();
  }
}