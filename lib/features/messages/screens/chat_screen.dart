import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/models/message_model.dart';
import '../../../core/repositories/message_repository.dart';
import '../../../core/widgets/coming_soon_dialog.dart';

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
  late List<Message> _messages;

  @override
  void initState() {
    super.initState();
    _messages = widget.conversationId.startsWith('job_')
        ? <Message>[]
        : Message.dummyList();
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

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      withData: true,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'jpg',
        'png',
      ],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() {
      for (final f in result.files) {
        _messages.insert(
          0,
          Message(
            id: 'att_${DateTime.now().millisecondsSinceEpoch}_${f.name}',
            senderId: 'user_me',
            text: f.name,
            timestamp: DateTime.now(),
            isMe: true,
            type: ChatMessageType.file,
          ),
        );
      }
    });
    if (!mounted) return;
    final repo = context.read<MessageRepository>();
    final preview = result.files.length == 1
        ? result.files.single.name
        : '${result.files.length} attachments';
    repo.recordOutboundPreview(widget.conversationId, preview);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(
        0,
        Message(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'user_me',
          text: text,
          timestamp: DateTime.now(),
          isMe: true,
        ),
      );
      _messageController.clear();
    });
    if (!mounted) return;
    context
        .read<MessageRepository>()
        .recordOutboundPreview(widget.conversationId, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Iconsax.arrow_left,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        titleSpacing: 0,
        title: InkWell(
          onTap: () => showComingSoonDialog(
            context,
            feature: 'Contact profile',
          ),
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
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Iconsax.user,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
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
                            color: Theme.of(context).colorScheme.surface,
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
                          color: Theme.of(context).colorScheme.onSurface,
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
                              : Theme.of(context).colorScheme.onSurfaceVariant,
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
            onPressed: () => showComingSoonDialog(
              context,
              feature: 'Video call',
            ),
            icon: Icon(
              Iconsax.video,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () => showComingSoonDialog(
              context,
              feature: 'Voice call',
            ),
            icon: Icon(
              Iconsax.call,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          return Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
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
                    onPressed: _pickAttachment,
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
                          hintText: 'Type a message...',
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: _messageController.text.trim().isEmpty
                        ? Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => showComingSoonDialog(
                                context,
                                feature: 'Voice message',
                              ),
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
                                  color: AppColors.white,
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
      );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isMe ? AppColors.primary : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isMe ? 20 : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.type == ChatMessageType.file)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.document,
                      size: 18,
                      color: message.isMe
                          ? AppColors.white
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
                              ? AppColors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                message.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: message.isMe ? AppColors.white : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              timeago.format(message.timestamp),
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: message.isMe
                    ? AppColors.white.withValues(alpha: 0.8)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
