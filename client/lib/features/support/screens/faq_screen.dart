import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/overlays/prolance_dialog.dart';

/// Frequently asked questions (EN + TR via [prolanceT]).
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static final _items = <_FaqEntry>[
    _FaqEntry(
      qEn: 'How do proposals and escrow work?',
      qTr: 'Teklifler ve escrow nasıl çalışır?',
      aEn:
          'You submit a proposal with your price and timeline. If the client accepts, funds can be held in escrow until delivery is approved. Exact steps are shown on your proposal’s progress timeline.',
      aTr:
          'Fiyat ve süre ile teklif gönderirsiniz. İşveren kabul ederse ödeme escrow’da tutulabilir ve teslim onaylanana kadar akış ilerler. Ayrıntılar teklif ekranındaki ilerleme adımlarında görünür.',
    ),
    _FaqEntry(
      qEn: 'The client accepted my proposal but I don’t see it updated.',
      qTr: 'İşveren teklifimi kabul etti ama ekran güncellenmedi.',
      aEn:
          'Try pulling to refresh on “My proposals”. If you use multiple devices, wait a few seconds for realtime sync. If it persists, use Contact & ticket with your proposal ID.',
      aTr:
          '“Tekliflerim” sayfasında yenilemeyi deneyin. Birden fazla cihazda birkaç saniye realtime gecikmesi olabilir. Devam ederse teklif ID’si ile İletişim & ticket üzerinden yazın.',
    ),
    _FaqEntry(
      qEn: 'How do I deliver files after my proposal is accepted?',
      qTr: 'Teklif kabul edildikten sonra dosyaları nasıl teslim ederim?',
      aEn:
          'Open the proposal, upload deliverables, then tap “Submit for client review” when you are ready. Uploading alone does not notify the client until you submit.',
      aTr:
          'Teklifi açın, dosyaları yükleyin ve hazır olduğunuzda “İşverene gönder” / inceleme için gönder’e basın. Sadece yükleme müşteriyi bilgilendirmez.',
    ),
    _FaqEntry(
      qEn: 'How long does support take to answer tickets?',
      qTr: 'Destek taleplerine ne kadar sürede dönülür?',
      aEn:
          'We usually respond within one business day. Check this FAQ first — many payout, proposal, and account questions are answered here.',
      aTr:
          'Genelde bir iş günü içinde dönüş yapılır. Önce bu SSS’ye bakın; ödeme, teklif ve hesap sorularının çoğu burada yanıtlanıyor.',
    ),
    _FaqEntry(
      qEn: 'How do I report a bug or payment issue?',
      qTr: 'Hata veya ödeme sorununu nasıl bildiririm?',
      aEn:
          'Settings → Contact & ticket (or “Report an issue” on a proposal). Describe what happened and include IDs shown in the app. Email is delivered to our inbox via Resend when configured.',
      aTr:
          'Ayarlar → İletişim & ticket (veya teklif ekranındaki “Sorun bildir”). Olan biteni ve uygulamadaki ID’leri yazın. Sunucu yapılandırıldığında e-posta Resend ile gelir.',
    ),
    _FaqEntry(
      qEn: 'Can I delete my account?',
      qTr: 'Hesabımı silebilir miyim?',
      aEn:
          'Use Settings → Delete account for eligible profiles. Some demo or admin accounts may be restricted.',
      aTr:
          'Uygun profiller için Ayarlar → Hesabı sil. Demo veya yönetici hesapları kısıtlı olabilir.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          prolanceT(context, 'F.A.Q.', 'S.S.S.'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        children: [
          Text(
            prolanceT(context, 'Common questions', 'Sıkça sorulan sorular'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          ..._items.map((e) => _FaqAccordion(entry: e)),
        ],
      ),
    );
  }
}

class _FaqAccordion extends StatelessWidget {
  const _FaqAccordion({required this.entry});

  final _FaqEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSm),
      child: Material(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        clipBehavior: Clip.none,
        // Material: use [shape] OR [borderRadius], never both (Flutter assertion).
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMd,
              vertical: 8,
            ),
            childrenPadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            expandedAlignment: Alignment.topLeft,
            maintainState: true,
            collapsedShape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent),
            ),
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent),
            ),
            title: Text(
              prolanceT(context, entry.qEn, entry.qTr),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: scheme.onSurface,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingMd,
                  10,
                  AppConstants.paddingMd,
                  16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    prolanceT(context, entry.aEn, entry.aTr),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.55,
                      color: scheme.onSurfaceVariant,
                    ),
                    softWrap: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqEntry {
  const _FaqEntry({
    required this.qEn,
    required this.qTr,
    required this.aEn,
    required this.aTr,
  });

  final String qEn;
  final String qTr;
  final String aEn;
  final String aTr;
}
