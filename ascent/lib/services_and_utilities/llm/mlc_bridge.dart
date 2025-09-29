import 'dart:async';

import 'package:flutter/services.dart';

class MlcBridgeError implements Exception {
  MlcBridgeError(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'MlcBridgeError($code, $message)';
}

class MlcBridge {
  MlcBridge._internal()
    : _methodChannel = const MethodChannel('mlc_bridge'),
      _eventChannel = const EventChannel('mlc_bridge/events') {
    _eventStream = _eventChannel.receiveBroadcastStream().map(
      (event) => Map<String, dynamic>.from(event as Map),
    );
  }

  static final MlcBridge instance = MlcBridge._internal();

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  late final Stream<Map<String, dynamic>> _eventStream;

  String? _loadedDirectory;
  String? _activeRequestId;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  Future<void>? _initializeFuture;

  Future<void> initialize(String modelDirectory) {
    if (_loadedDirectory == modelDirectory && _initializeFuture == null) {
      return Future.value();
    }

    _initializeFuture ??= () async {
      if (_loadedDirectory != null && _loadedDirectory != modelDirectory) {
        await shutdown();
      }
      await _methodChannel.invokeMethod('initialize', {
        'modelDir': modelDirectory,
      });
      _loadedDirectory = modelDirectory;
    }().whenComplete(() {
      _initializeFuture = null;
    });

    return _initializeFuture!;
  }

  Future<void> shutdown() async {
    _initializeFuture = null;
    _loadedDirectory = null;

    await _subscription?.cancel();
    _subscription = null;
    _activeRequestId = null;

    await _methodChannel.invokeMethod('shutdown');
  }

  Stream<String> generate(String prompt, {double? temperature, double? topP}) {
    final requestId = DateTime.now().microsecondsSinceEpoch.toString();

    _subscription?.cancel();
    _activeRequestId = requestId;

    final controller = StreamController<String>(
      onCancel: () async {
        if (_activeRequestId == requestId) {
          await _methodChannel.invokeMethod('cancel', {'requestId': requestId});
          _activeRequestId = null;
        }
        await _subscription?.cancel();
        _subscription = null;
      },
    );

    _subscription = _eventStream.listen(
      (event) {
        final type = event['type'] as String?;
        final eventRequestId = event['requestId'] as String?;

        if (eventRequestId != null && eventRequestId != requestId) {
          return;
        }

        switch (type) {
          case 'token':
            final token = event['value'] as String?;
            if (token != null && token.isNotEmpty && !controller.isClosed) {
              controller.add(token);
            }
            break;
          case 'completed':
          case 'cancelled':
            if (!controller.isClosed) {
              controller.close();
            }
            _finalizeActiveRequest(requestId);
            break;
          case 'error':
            final code = event['code'] as String? ?? 'error';
            final message = event['message'] as String? ?? 'Unknown error';
            if (!controller.isClosed) {
              controller.addError(MlcBridgeError(code, message));
              controller.close();
            }
            _finalizeActiveRequest(requestId);
            break;
          default:
            break;
        }
      },
      onError: (error) {
        if (!controller.isClosed) {
          controller.addError(error);
          controller.close();
        }
        _finalizeActiveRequest(requestId);
      },
    );

    Future(() async {
      try {
        await _methodChannel.invokeMethod('generate', {
          'prompt': prompt,
          'requestId': requestId,
          if (temperature != null) 'temperature': temperature,
          if (topP != null) 'topP': topP,
        });
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
          controller.close();
        }
        _finalizeActiveRequest(requestId);
      }
    });

    return controller.stream;
  }

  void _finalizeActiveRequest(String requestId) {
    if (_activeRequestId == requestId) {
      _activeRequestId = null;
    }
    _subscription?.cancel();
    _subscription = null;
  }
}
