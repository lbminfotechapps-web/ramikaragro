import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solufine/features/home/doman/home_entity/menu_entity.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'voice_menu_matcher.dart';

class VoiceMenuDialog extends StatefulWidget {
  final List<MenuEntity> menus;

  const VoiceMenuDialog({super.key, required this.menus});

  @override
  State<VoiceMenuDialog> createState() => _VoiceMenuDialogState();
}

class _VoiceMenuDialogState extends State<VoiceMenuDialog>
    with WidgetsBindingObserver {
  // The plugin retains its first initialization callbacks for the app lifetime.
  static final _speech = SpeechToText();
  static _VoiceMenuDialogState? _active;
  bool _starting = false;
  bool _listening = false;
  bool _finished = false;
  String _words = '';
  String _message = 'Say a menu name, for example “add expense”.';
  Timer? _resolveTimer;

  @override
  void initState() {
    super.initState();
    _active = this;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _listen());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _finished = true;
      _resolveTimer?.cancel();
      unawaited(_speech.cancel());
      if (mounted) setState(() => _listening = false);
    }
  }

  void _status(String status) {
    if (!mounted || _finished) return;
    setState(() {
      _listening = status == 'listening';
      if (status == 'done' || status == 'notListening') {
        _message = 'Listening stopped. Try again if no menu opens.';
      }
    });
    if (status == 'done' || status == 'notListening') {
      _scheduleResolve();
    }
  }

  void _scheduleResolve() {
    _resolveTimer?.cancel();
    _resolveTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted && !_finished) _resolve();
    });
  }

  void _error(String message) {
    if (!mounted || _finished) return;
    _resolveTimer?.cancel();
    setState(() {
      _starting = false;
      _listening = false;
      _message = message;
    });
  }

  Future<void> _listen() async {
    if (!mounted || _starting || _listening) return;
    setState(() {
      _starting = true;
      _finished = false;
      _words = '';
      _resolveTimer?.cancel();
      _message = 'Say a menu name, for example “add expense”.';
    });
    try {
      final available = await _speech.initialize(
        onStatus: (status) => _active?._status(status),
        onError: (error) => _active?._error(
          error.errorMsg.contains('permission')
              ? 'Allow microphone and speech recognition in device Settings, then try again.'
              : 'Could not hear you. Check your connection and try again.',
        ),
        options: [SpeechToText.androidNoBluetooth],
      );
      if (!mounted || _finished) return;
      if (!available) {
        _error(
          'Speech recognition is unavailable. Check microphone and speech permissions in device Settings.',
        );
        return;
      }
      final locales = await _speech.locales();
      if (!mounted || _finished) return;
      final english = locales.where(
        (locale) => locale.localeId.startsWith('en'),
      );
      final indianEnglish = english.where(
        (locale) => locale.localeId.replaceAll('-', '_') == 'en_IN',
      );
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: indianEnglish.isNotEmpty
              ? indianEnglish.first.localeId
              : english.firstOrNull?.localeId,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
          cancelOnError: true,
          partialResults: true,
          listenMode: ListenMode.confirmation,
        ),
        onResult: (result) {
          if (!mounted || _finished) return;
          setState(() => _words = result.recognizedWords);
          _resolveTimer?.cancel();
          if (result.finalResult) {
            _resolve();
          } else if (matchVoiceMenus(_words, widget.menus).isNotEmpty) {
            _scheduleResolve();
          }
        },
      );
    } catch (_) {
      _error('Could not start voice search. Please try again.');
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  void _resolve() {
    if (!mounted || _finished) return;
    _resolveTimer?.cancel();
    _finished = true;
    unawaited(_speech.cancel());
    final matches = matchVoiceMenus(_words, widget.menus);
    if (matches.isNotEmpty) {
      Navigator.of(context).pop(matches.first);
      return;
    }
    setState(() {
      _listening = false;
      _message = 'No matching menu. Try saying the menu name again.';
    });
  }

  @override
  void dispose() {
    _resolveTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (_active == this) {
      _active = null;
      unawaited(_speech.cancel());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(_listening ? 'Listening…' : 'Voice menu'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _listening ? Icons.mic : Icons.mic_none,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          if (_words.isNotEmpty) ...[
            Text(_words, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],
          Text(_message, textAlign: TextAlign.center),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      if (!_listening)
        TextButton(
          onPressed: _starting ? null : _listen,
          child: Text(_starting ? 'Starting…' : 'Try again'),
        ),
    ],
  );
}
