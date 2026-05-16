import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/message_model.dart';
import '../../../core/repositories/message_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/coming_soon_dialog.dart';
import '../../../core/widgets/overlays/prolance_bottom_sheet.dart';
import '../widgets/image_preview_screen.dart';
import '../widgets/quick_reply_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.userName,
    required this.userAvatar,
    this.isOnline = false,
  });

  final String conversationId;
  final String userName;
  final String userAvatar;
  final bool isOnline;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<MessageRepository>()
          .markConversationRead(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      withData: true,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (!mounted) return;
    setState(() => _isSending = true);
    try {
      await context
          .read<MessageRepository>()
          .uploadAttachment(widget.conversationId, file);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    final picker = ImagePicker();
    final XFile? picked = fromCamera
        ? await picker.pickImage(source: ImageSource.camera, imageQuality: 85)
        : await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    final file = PlatformFile(
      name: picked.name,
      size: bytes.length,
      bytes: bytes,
    );
    if (!mounted) return;
    final repo = context.read<MessageRepository>();
    setState(() => _isSending = true);
    try {
      await repo.uploadAttachment(widget.conversationId, file);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showImageSourceSheet() {
    final appState = context.read<AppState>();
    showProlanceBottomSheet<void>(
      context: context,
      title: appState.t('Attach', 'Ekle'),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProlanceSheetListTile(
              icon: Iconsax.camera,
              title: appState.t('Camera', 'Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(fromCamera: true);
              },
            ),
            ProlanceSheetListTile(
              icon: Iconsax.gallery,
              title: appState.t('Gallery', 'Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(fromCamera: false);
              },
            ),
            ProlanceSheetListTile(
              icon: Iconsax.document,
              title: appState.t('File', 'Dosya'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage([String? override]) async {
    final text = override ?? _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    _messageController.clear();
    setState(() => _isSending = true);
    try {
      await context
          .read<MessageRepository>()
          .sendMessageAsync(widget.conversationId, text);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MessageRepository>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Iconsax.arrow_left, color: scheme.onSurface),
        ),
        titleSpacing: 0,
        title: InkWell(
          onTap: () =>
              showComingSoonDialog(context, feature: 'Contact profile'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.userAvatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: scheme.surfaceContainerHighest,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(Iconsax.user,
                              color: scheme.onSurfaceVariant, size: 20),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isOnline
                              ? AppColors.success
                              : AppColors.grey500,
                          border: Border.all(
                            color: scheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.userName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.isOnline ? 'Online' : 'Last seen recently',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: widget.isOnline
                              ? AppColors.success
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                context.push('/video-call/${widget.conversationId}'),
            icon: Icon(Iconsax.video, color: AppColors.primary, size: 24),
          ),
          IconButton(
            onPressed: () => context.push(
              '/video-call/${widget.conversationId}?voice=1',
            ),
            icon: Icon(Iconsax.call, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // E2E trust badge
          _TrustBadge(),

          // Messages
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: repo.messagesStream(widget.conversationId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (messages.isEmpty &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.message,
                            size: 48, color: scheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'Henüz mesaj yok.\nBir şeyler yazın!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: scheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _MessageBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),

          // Quick reply chips
          QuickReplyBar(
            onSelect: (text) => _sendMessage(text),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _showImageSourceSheet,
                    icon: Icon(
                      Iconsax.attach_circle,
                      color: scheme.onSurfaceVariant,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        onChanged: (_) => setState(() {}),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Mesaj yaz...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isSending
                        ? const SizedBox(
                            width: 48,
                            height: 48,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _messageController.text.trim().isEmpty
                            ? Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => showComingSoonDialog(
                                      context,
                                      feature: 'Voice message'),
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: scheme.surfaceContainerHighest,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Iconsax.microphone_2,
                                      color: scheme.onSurfaceVariant,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              )
                            : Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _sendMessage,
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary,
                                          blurRadius: 12,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Iconsax.send_1,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trust badge
// ---------------------------------------------------------------------------
class _TrustBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.lock,
            size: 13,
            color: Colors.indigo.shade400,
          ),
          const SizedBox(width: 5),
          Text(
            'Bu konuşma TLS + AES-256 ile korunmaktadır',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.indigo.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble
// ---------------------------------------------------------------------------
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isImage = message.type == ChatMessageType.image;
    final isFile = message.type == ChatMessageType.file;

    return Align(
      alignment:
          message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: isImage
            ? null
            : BoxDecoration(
                color: message.isMe
                    ? AppColors.primary
                    : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft:
                      Radius.circular(message.isMe ? 20 : 4),
                  bottomRight:
                      Radius.circular(message.isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        scheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
        child: isImage && message.attachmentUrl != null
            ? _ImageBubble(message: message)
            : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFile)
                      GestureDetector(
                        onTap: () async {
                          final url = message.attachmentUrl;
                          if (url != null) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.document,
                                size: 18,
                                color: message.isMe
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  message.text,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: message.isMe
                                        ? Colors.white
                                        : scheme.onSurface,
                                    decoration:
                                        TextDecoration.underline,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Text(
                        message.text,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: message.isMe
                              ? Colors.white
                              : scheme.onSurface,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(message.timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: message.isMe
                            ? Colors.white.withValues(alpha: 0.8)
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image bubble with Hero tap-to-expand
// ---------------------------------------------------------------------------
class _ImageBubble extends StatelessWidget {
  const _ImageBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final url = message.attachmentUrl!;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewScreen(
            imageUrl: url,
            heroTag: 'img_${message.id}',
          ),
        ),
      ),
      child: Hero(
        tag: 'img_${message.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isMe ? 20 : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : 20),
          ),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 240,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
              width: 240,
              height: 200,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, _, _) => Container(
              width: 240,
              height: 200,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Iconsax.image, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}
