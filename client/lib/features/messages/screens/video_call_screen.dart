import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({
    super.key,
    required this.conversationId,
    this.voiceOnly = false,
  });

  final String conversationId;
  final bool voiceOnly;

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  RtcEngine? _engine;
  bool _joined = false;
  bool _muted = false;
  bool _videoOff = false;
  String? _error;
  bool _loading = true;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  Future<void> _startCall() async {
    if (!SupabaseConfig.isEnabled) {
      setState(() {
        _error = 'Supabase devre dışı.';
        _loading = false;
      });
      return;
    }

    final mic = await Permission.microphone.request();
    if (!widget.voiceOnly) {
      await Permission.camera.request();
    }
    if (!mic.isGranted) {
      setState(() {
        _error = 'Mikrofon izni gerekli.';
        _loading = false;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'agora-token',
        body: {'conversationId': widget.conversationId},
      );

      if (response.status != 200) {
        final data = response.data;
        final message = data is Map && data['error'] != null
            ? '${data['error']}'
            : 'Agora token alınamadı (${response.status}).';
        setState(() {
          _error = message;
          _loading = false;
        });
        return;
      }

      final raw = response.data;
      if (raw is! Map) {
        setState(() {
          _error = 'Agora token yanıtı geçersiz.';
          _loading = false;
        });
        return;
      }
      final data = Map<String, dynamic>.from(raw);
      final appId = data['appId'] as String?;
      final token = data['token'] as String?;
      final channel = data['channel'] as String?;
      final uid = data['uid'] as int?;

      if (appId == null ||
          token == null ||
          channel == null ||
          uid == null ||
          appId.isEmpty) {
        setState(() {
          _error = 'Geçersiz Agora yanıtı. AGORA_APP_ID ayarlarını kontrol edin.';
          _loading = false;
        });
        return;
      }

      final engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(appId: appId));
      await engine.enableAudio();
      if (!widget.voiceOnly) {
        await engine.enableVideo();
        await engine.startPreview();
      }

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (_, __) {
            if (mounted) setState(() => _joined = true);
          },
          onUserJoined: (_, remoteUid, __) {
            if (mounted) setState(() => _remoteUid = remoteUid);
          },
          onUserOffline: (_, remoteUid, __) {
            if (mounted && _remoteUid == remoteUid) {
              setState(() => _remoteUid = null);
            }
          },
          onError: (err, msg) {
            if (mounted) {
              setState(() => _error = 'Agora: $err $msg');
            }
          },
        ),
      );

      await engine.joinChannel(
        token: token,
        channelId: channel,
        uid: uid,
        options: ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: !widget.voiceOnly,
          autoSubscribeAudio: true,
          autoSubscribeVideo: !widget.voiceOnly,
        ),
      );

      _engine = engine;
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _toggleMute() async {
    final engine = _engine;
    if (engine == null) return;
    final next = !_muted;
    await engine.muteLocalAudioStream(next);
    setState(() => _muted = next);
  }

  Future<void> _toggleVideo() async {
    if (widget.voiceOnly) return;
    final engine = _engine;
    if (engine == null) return;
    final next = !_videoOff;
    await engine.muteLocalVideoStream(next);
    setState(() => _videoOff = next);
  }

  Future<void> _endCall() async {
    final engine = _engine;
    if (engine != null) {
      await engine.leaveChannel();
      await engine.release();
    }
    _engine = null;
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    final engine = _engine;
    if (engine != null) {
      engine.leaveChannel();
      engine.release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.voiceOnly ? 'Sesli arama' : 'Görüntülü arama',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorBody(message: _error!, onClose: _endCall)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    if (!widget.voiceOnly && _engine != null)
                      AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    else
                      Center(
                        child: Icon(
                          Iconsax.call,
                          size: 72,
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    if (!widget.voiceOnly &&
                        _remoteUid != null &&
                        _engine != null)
                      Positioned(
                        right: 16,
                        top: 16,
                        width: 120,
                        height: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AgoraVideoView(
                            controller: VideoViewController.remote(
                              rtcEngine: _engine!,
                              canvas: VideoCanvas(uid: _remoteUid),
                              connection: RtcConnection(
                                channelId: widget.conversationId,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 32,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CallFab(
                            icon: _muted ? Iconsax.microphone_slash : Iconsax.microphone,
                            label: _muted ? 'Sessiz' : 'Mik',
                            onTap: _toggleMute,
                          ),
                          if (!widget.voiceOnly) ...[
                            const SizedBox(width: 16),
                            _CallFab(
                              icon: _videoOff ? Iconsax.video_slash : Iconsax.video,
                              label: _videoOff ? 'Kapalı' : 'Kamera',
                              onTap: _toggleVideo,
                            ),
                          ],
                          const SizedBox(width: 16),
                          _CallFab(
                            icon: Iconsax.call_slash,
                            label: 'Bitir',
                            color: AppColors.error,
                            onTap: _endCall,
                          ),
                        ],
                      ),
                    ),
                    if (!_joined)
                      const Center(
                        child: Text(
                          'Bağlanıyor…',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.warning_2, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: onClose, child: const Text('Kapat')),
        ],
      ),
    );
  }
}

class _CallFab extends StatelessWidget {
  const _CallFab({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: color ?? Colors.white24,
          onPressed: onTap,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
