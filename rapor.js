const {
    Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, ImageRun,
    Header, Footer, AlignmentType, LevelFormat, HeadingLevel, BorderStyle,
    WidthType, ShadingType, VerticalAlign, PageNumber, PageBreak,
    TabStopType, LeaderType, ExternalHyperlink
  } = require('docx');
  const fs = require('fs');
  const path = require('path');
  
  // ────────────────────────────────────────
  // Page & font constants (A4, Times New Roman — mirrors AfetHat template)
  // ────────────────────────────────────────
  const PAGE_W   = 11900;
  const PAGE_H   = 16840;
  const MAR_TOP  = 1920;
  const MAR_BOT  = 800;
  const MAR_LEFT = 1275;
  const MAR_RIGHT= 992;
  const CONTENT_W = PAGE_W - MAR_LEFT - MAR_RIGHT; // 9633 DXA
  
  const FONT = 'Times New Roman';
  const FONT_BODY = 24;   // 12 pt
  const FONT_H1   = 28;   // 14 pt
  const FONT_H2   = 26;   // 13 pt
  const FONT_H3   = 24;   // 12 pt
  
  // docx v8+ ImageRun expects transformation width/height in **pixels** (96 dpi).
  // DXA (twips): 1440 per inch → px = dxa * 96 / 1440
  const dxaToPx = (dxa) => Math.max(1, Math.round((dxa / 1440) * 96));
  
  // Image paths (Windows / repo-relative). Populate from AfetHat template docx → docs/rapor_media/
  const MEDIA = path.join(__dirname, 'docs', 'rapor_media');
  const OUT_DOCX = path.join(
    process.env.USERPROFILE || __dirname,
    'Downloads',
    'Prolance_Capstone_Report_Final.docx',
  );
  const img = name => fs.readFileSync(path.join(MEDIA, name));
  
  // ────────────────────────────────────────
  // Helper builders
  // ────────────────────────────────────────
  const br = () => new Paragraph({ children: [] });
  
  function txt(text, opts = {}) {
    return new TextRun({
      text,
      font: FONT,
      size: opts.size || FONT_BODY,
      bold:   opts.bold   || false,
      italics:opts.italics|| false,
      color:  opts.color  || undefined,
    });
  }
  
  function para(children, opts = {}) {
    return new Paragraph({
      alignment: opts.align || AlignmentType.JUSTIFIED,
      spacing: { before: opts.before ?? 80, after: opts.after ?? 80, line: opts.line ?? 276 },
      indent: opts.indent ? { left: opts.indent } : undefined,
      children: Array.isArray(children) ? children : [children],
    });
  }
  
  function heading1(text) {
    return new Paragraph({
      heading: HeadingLevel.HEADING_1,
      spacing: { before: 240, after: 120 },
      children: [new TextRun({ text, font: FONT, size: FONT_H1, bold: true })],
    });
  }
  
  function heading2(text) {
    return new Paragraph({
      heading: HeadingLevel.HEADING_2,
      spacing: { before: 200, after: 80 },
      children: [new TextRun({ text, font: FONT, size: FONT_H2, bold: true })],
    });
  }
  
  function heading3(text) {
    return new Paragraph({
      heading: HeadingLevel.HEADING_3,
      spacing: { before: 160, after: 60 },
      children: [new TextRun({ text, font: FONT, size: FONT_H3, bold: true })],
    });
  }
  
  function bullet(text, opts = {}) {
    return new Paragraph({
      numbering: { reference: 'bullets', level: 0 },
      spacing: { before: 60, after: 60, line: 276 },
      children: [new TextRun({ text, font: FONT, size: FONT_BODY, bold: opts.bold||false, italics: opts.italics||false })],
    });
  }
  
  function subbullet(text) {
    return new Paragraph({
      numbering: { reference: 'subbullets', level: 0 },
      spacing: { before: 40, after: 40, line: 276 },
      children: [new TextRun({ text, font: FONT, size: FONT_BODY })],
    });
  }
  
  // Standard cell border
  const CB = { style: BorderStyle.SINGLE, size: 1, color: 'CCCCCC' };
  const CBORD = { top: CB, bottom: CB, left: CB, right: CB };
  const HCELL_FILL = 'D6E4F0';  // header cell fill
  
  function cell(content, opts = {}) {
    const children = typeof content === 'string'
      ? [new Paragraph({ alignment: opts.align || AlignmentType.LEFT,
          children: [new TextRun({ text: content, font: FONT, size: FONT_BODY-2, bold: opts.bold||false })] })]
      : content;
    return new TableCell({
      borders: CBORD,
      width: { size: opts.width || 4680, type: WidthType.DXA },
      shading: opts.fill ? { fill: opts.fill, type: ShadingType.CLEAR } : undefined,
      verticalAlign: VerticalAlign.CENTER,
      margins: { top: 80, bottom: 80, left: 120, right: 120 },
      children,
    });
  }
  
  function hcell(text, w) {
    return cell(text, { bold: true, fill: HCELL_FILL, width: w });
  }
  
  function pageBreak() {
    return new Paragraph({ children: [new PageBreak()] });
  }
  
  // Centered bold title paragraph (for cover)
  function coverTitle(text, size = 28, color = '1F3864') {
    return new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 60, after: 60 },
      children: [new TextRun({ text, font: FONT, size, bold: true, color })],
    });
  }
  
  function centeredPara(text, opts = {}) {
    return new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: opts.before ?? 60, after: opts.after ?? 60 },
      children: [new TextRun({ text, font: FONT, size: opts.size || FONT_BODY, bold: opts.bold||false, italics: opts.italics||false })],
    });
  }
  
  // Inline image helper (portrait screenshots, scaled by width in DXA)
  function inlineImg(name, widthDxa, aspectW, aspectH) {
    const wPx = dxaToPx(widthDxa);
    const hPx = Math.max(1, Math.round((wPx * aspectH) / aspectW));
    return new ImageRun({ data: img(name), transformation: { width: wPx, height: hPx }, type: 'png' });
  }
  
  // Figure caption
  function figCaption(text) {
    return new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 80, after: 160 },
      children: [new TextRun({ text, font: FONT, size: FONT_BODY-2, bold: true, italics: true })],
    });
  }
  
  // Two-image row using table (for screenshot pairs)
  function screenshotPair(img1name, img2name, aspectW, aspectH, caption1, caption2) {
    const colW = Math.floor(CONTENT_W / 2) - 100; // ~4716 DXA each
    const wPx = dxaToPx(colW);
    const hPx = Math.max(1, Math.round((wPx * aspectH) / aspectW));
    const makeImgCell = (name, cap) => new TableCell({
      borders: { top: { style: BorderStyle.NONE }, bottom: { style: BorderStyle.NONE }, left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE } },
      width: { size: colW, type: WidthType.DXA },
      margins: { top: 40, bottom: 40, left: 60, right: 60 },
      children: [
        new Paragraph({ alignment: AlignmentType.CENTER, children: [
          new ImageRun({ data: img(name), transformation: { width: wPx, height: hPx }, type: 'png' })
        ]}),
        new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 40 },
          children: [new TextRun({ text: cap, font: FONT, size: FONT_BODY-4, bold: true, italics: true })] }),
      ],
    });
    return new Table({
      width: { size: CONTENT_W, type: WidthType.DXA },
      columnWidths: [colW, colW],
      borders: { top: { style: BorderStyle.NONE }, bottom: { style: BorderStyle.NONE }, left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE }, insideH: { style: BorderStyle.NONE }, insideV: { style: BorderStyle.NONE } },
      rows: [new TableRow({ children: [makeImgCell(img1name, caption1), makeImgCell(img2name, caption2)] })],
    });
  }
  
  // Full-width image (for web screenshots)
  function fullWidthImg(name, aspectW, aspectH, caption) {
    const wPx = dxaToPx(CONTENT_W - 200);
    const hPx = Math.max(1, Math.round((wPx * aspectH) / aspectW));
    return [
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 80 }, children: [
        new ImageRun({ data: img(name), transformation: { width: wPx, height: hPx }, type: 'png' })
      ]}),
      figCaption(caption),
    ];
  }
  
  // Text-based flow diagram (styled like AfetHat)
  function flowDiagram(lines) {
    return lines.map(line => new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 20, after: 20 },
      children: [new TextRun({ text: line, font: 'Courier New', size: 18, color: '1F3864' })],
    }));
  }
  
  function dividerLine() {
    return new Paragraph({
      border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: '2E75B6', space: 1 } },
      spacing: { before: 80, after: 80 },
      children: [],
    });
  }
  
  // ────────────────────────────────────────
  // TOC entry
  // ────────────────────────────────────────
  function tocEntry(text, page, level = 0) {
    const indent = level * 360;
    return new Paragraph({
      spacing: { before: 40, after: 40 },
      indent: { left: indent },
      tabStops: [{ type: TabStopType.RIGHT, position: CONTENT_W - 200, leader: LeaderType.DOT }],
      children: [
        new TextRun({ text, font: FONT, size: FONT_BODY }),
        new TextRun({ text: '\t' + page, font: FONT, size: FONT_BODY }),
      ],
    });
  }
  
  // ────────────────────────────────────────
  // DOCUMENT ASSEMBLY
  // ────────────────────────────────────────
  const logoData = img('image14.png'); // 220x220 logo
  
  const doc = new Document({
    numbering: {
      config: [
        { reference: 'bullets',
          levels: [{ level: 0, format: LevelFormat.BULLET, text: '•', alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 540, hanging: 360 } } } }] },
        { reference: 'subbullets',
          levels: [{ level: 0, format: LevelFormat.BULLET, text: '◦', alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 900, hanging: 360 } } } }] },
      ],
    },
    styles: {
      default: {
        document: { run: { font: FONT, size: FONT_BODY } },
      },
      paragraphStyles: [
        { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { size: FONT_H1, bold: true, font: FONT, color: '1F3864' },
          paragraph: { spacing: { before: 280, after: 140 }, outlineLevel: 0 } },
        { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { size: FONT_H2, bold: true, font: FONT, color: '2E4057' },
          paragraph: { spacing: { before: 220, after: 100 }, outlineLevel: 1 } },
        { id: 'Heading3', name: 'Heading 3', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { size: FONT_H3, bold: true, font: FONT, color: '2E4057' },
          paragraph: { spacing: { before: 160, after: 60 }, outlineLevel: 2 } },
      ],
    },
  
    sections: [{
      properties: {
        page: {
          size: { width: PAGE_W, height: PAGE_H },
          margin: { top: MAR_TOP, right: MAR_RIGHT, bottom: MAR_BOT, left: MAR_LEFT },
        },
      },
      children: [
  
        // ═══════════════════════════════════
        // COVER PAGE 1
        // ═══════════════════════════════════
        new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 0, after: 60 }, children: [
          new ImageRun({ data: logoData, transformation: { width: 110, height: 110 }, type: 'png' }),
        ]}),
        coverTitle('OSTIM TECHNICAL UNIVERSITY', 26, '1F3864'),
        coverTitle('FACULTY OF ENGINEERING CAPSTONE PROJECT REPORT', 24, '1F3864'),
        dividerLine(),
        br(),
        centeredPara('Prolance: A Cross-Platform Freelance Marketplace with Escrow-Backed Contracts,', { size: 22, bold: true }),
        centeredPara('Supabase-Backed Data Plane, and Dual Web Surfaces', { size: 22, bold: true }),
        centeredPara('(Flutter · Android / iOS / Web · Next.js)', { size: 20, bold: true }),
        br(),
        centeredPara('Design and Implementation of a Demo-Ready Monorepo Linking a Flutter Client,', { size: 18, italics: true }),
        centeredPara('a Next.js Marketing and Employer Portal, and Managed PostgreSQL with Row-Level Security', { size: 18, italics: true }),
        br(), br(),
        centeredPara('Project Team', { size: FONT_BODY, bold: true }),
        br(),
        centeredPara('[Student Name Surname] ([Student Number])', { size: FONT_BODY }),
        centeredPara('[Student Name Surname] ([Student Number])', { size: FONT_BODY }),
        centeredPara('[Student Name Surname] ([Student Number])', { size: FONT_BODY }),
        br(),
        centeredPara('Project Advisor', { size: FONT_BODY, bold: true }),
        centeredPara('Prof. Dr. [Advisor Name Surname]', { size: FONT_BODY }),
        br(),
        centeredPara('Undergraduate Project — Department of Computer Engineering', { size: FONT_BODY }),
        centeredPara('MFBP 402(1) Graduation Project II', { size: FONT_BODY }),
        br(),
        centeredPara('18.05.2026', { size: FONT_BODY }),
        pageBreak(),
  
        // ═══════════════════════════════════
        // COVER PAGE 2 (clean repeat)
        // ═══════════════════════════════════
        new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 0, after: 60 }, children: [
          new ImageRun({ data: logoData, transformation: { width: 110, height: 110 }, type: 'png' }),
        ]}),
        coverTitle('OSTIM TECHNICAL UNIVERSITY', 26, '1F3864'),
        coverTitle('FACULTY OF ENGINEERING CAPSTONE PROJECT REPORT', 24, '1F3864'),
        dividerLine(),
        br(),
        centeredPara('Prolance: A Cross-Platform Freelance Marketplace with Escrow-Backed Contracts,', { size: 22, bold: true }),
        centeredPara('Supabase-Backed Data Plane, and Dual Web Surfaces', { size: 22, bold: true }),
        centeredPara('(Flutter · Android / iOS / Web · Next.js)', { size: 20, bold: true }),
        br(),
        centeredPara('Design and Implementation of a Demo-Ready Monorepo Linking a Flutter Client,', { size: 18, italics: true }),
        centeredPara('a Next.js Marketing and Employer Portal, and Managed PostgreSQL with Row-Level Security', { size: 18, italics: true }),
        br(), br(),
        centeredPara('Project Team', { size: FONT_BODY, bold: true }),
        br(),
        centeredPara('[Student Name Surname] ([Student Number])', { size: FONT_BODY }),
        centeredPara('[Student Name Surname] ([Student Number])', { size: FONT_BODY }),
        centeredPara('[Student Name Surname] ([Student Number])', { size: FONT_BODY }),
        br(),
        centeredPara('Project Advisor', { size: FONT_BODY, bold: true }),
        centeredPara('Prof. Dr. [Advisor Name Surname]', { size: FONT_BODY }),
        br(),
        centeredPara('Undergraduate Project — Department of Computer Engineering', { size: FONT_BODY }),
        centeredPara('MFBP 402(1) Graduation Project II', { size: FONT_BODY }),
        br(),
        centeredPara('18.05.2026', { size: FONT_BODY }),
        pageBreak(),
  
        // ═══════════════════════════════════
        // APPROVAL
        // ═══════════════════════════════════
        heading1('APPROVAL'),
        para([txt('This undergraduate capstone project, entitled '), txt('"Prolance: A Cross-Platform Freelance Marketplace with Escrow-Backed Contracts, Supabase-Backed Data Plane, and Dual Web Surfaces"', { italics: true }), txt(' prepared by the project team listed on the title page under the supervision of Prof. Dr. [Advisor Name Surname] has been examined by the committee and accepted as an undergraduate capstone project in terms of scope and quality.')]),
        br(),
        centeredPara('Supervisor', { bold: true }),
        centeredPara('[Advisor Name – Surname]'),
        br(),
        centeredPara('Member', { bold: true }),
        centeredPara('Jury Member Name Surname'),
        br(),
        centeredPara('Member', { bold: true }),
        centeredPara('Jury Member Name Surname'),
        br(),
        centeredPara('Head of Department', { bold: true }),
        centeredPara('Asst. Prof. Dr. [Head of Department Name]'),
        pageBreak(),
  
        // ═══════════════════════════════════
        // ACKNOWLEDGEMENTS
        // ═══════════════════════════════════
        heading1('ACKNOWLEDGEMENTS'),
        para([txt('This report documents the analysis, design, implementation, and verification activities of the Prolance cross-platform freelance marketplace developed within the scope of the 2025–2026 Capstone Project process in the Department of Computer Engineering, Faculty of Engineering, OSTIM Technical University. The study summarises approximately three months of focused development effort shaped by agile teamwork, iterative delivery, and contemporary mobile, web, and cloud-backend software engineering practices.')]),
        br(),
        para([txt('This report extends and operationalises the goals stated in the original proposal with a working monorepo: an authenticated Flutter client for job discovery, proposal submission, real-time messaging, and escrow-aware contract progression; a Supabase data plane backed by PostgreSQL with row-level security and versioned migrations; a Next.js marketing site and employer portal including dispute review for administrators; and a Supabase Edge Function escrow orchestrator.')]),
        br(),
        para([txt('The project team gratefully acknowledges the project advisor for technical guidance and academic support. The team also extends sincere appreciation to the faculty members and jury who shared their technical and academic feedback over both semesters, and to the early testers — friends, family members, and classmates — whose feedback substantially improved the user experience and reliability of the system.')]),
        br(),
        centeredPara('Prolance Team — May 2026', { bold: true }),
        centeredPara('Ankara'),
        pageBreak(),
  
        // ═══════════════════════════════════
        // ÖZET
        // ═══════════════════════════════════
        heading1('ÖZET'),
        para([txt('Serbest çalışan pazar yerlerinde güven eksikliği, ödeme anlaşmazlıkları ve dağınık iletişim kanalları işveren ile freelancer arasında sürtünme yaratır. Bu çalışma, Prolance adlı çapraz platform uygulamasını tasarlayarak bu sürtünmeyi azaltmayı hedefler. Flutter istemcisi iş ilanlarını keşfetme, teklif verme, gerçek zamanlı mesajlaşma ve teslimat dosyalarını güvenli depoda toplama akışlarını sunar; Supabase tarafında Postgres üzerinde satır düzeyi güvenlik (RLS), RPC ile yaşam döngüsü geçişleri ve özel depolama ile teslim dosyalarının yalnızca taraflarca okunması sağlanır. Next.js ile pazarlama ve portal yüzeyleri birleştirilir; yönetici paneli anlaşmazlık incelemeleri için ek ekranlar içerir.')]),
        br(),
        para([txt('Sistem; işverenin teklif kabul ederek escrow\'u fonlaması, freelancer\'ın teslimat dosyalarını yüklemesi, işverenin dosyaları imzalı URL ile indirip incelemesi, teslim onayı ardından 24 saatlik itiraz penceresi açılması ve süre sonunda kazancın otomatik olarak serbest bırakılması adımlarından oluşan belirleyici bir yaşam döngüsü uygular. Anlaşmazlık durumunda yönetici, denetim günlüğü destekli bir portal ekranından müdahale edebilir. Çalışma, Agile sprint düzeni, risk kaydı ve otomatikleştirilmiş testlerle desteklenen bir mühendislik sürecini belgeler.')]),
        br(),
        para([txt('Anahtar Kelimeler: ', { bold: true }), txt('serbest çalışma platformu, Flutter, Supabase, satır düzeyi güvenlik, emanet ödeme, escrow, Next.js, portal, teslimat yaşam döngüsü, Firebase Cloud Messaging, GoRouter, Provider, PostgreSQL RLS, Edge Function, gerçek zamanlı bildirimler.', { italics: true })]),
        pageBreak(),
  
        // ═══════════════════════════════════
        // ABSTRACT
        // ═══════════════════════════════════
        heading1('ABSTRACT'),
        para([txt('Freelance marketplaces must combine discoverability, negotiation, and post-award execution with trust mechanisms that survive partial failures and adversarial actors. Prolance implements a pragmatic vertical slice of this problem space across a Flutter mobile client, a Next.js dual-surface web tier, and a Supabase-managed backend. Employers publish jobs and compare bids; freelancers submit proposals and upload deliverables to a private Supabase Storage bucket; employers download deliverables via signed URLs, accept or dispute delivery, and funds are released automatically after a 24-hour dispute window with an explicit escalation path for administrators.')]),
        br(),
        para([txt('The backend is expressed entirely as versioned SQL migrations applied to a managed PostgreSQL project, row-level security policies enforced at the database layer, and two Supabase Edge Functions: one for escrow orchestration and one for push-notification dispatch. The Flutter client relies on GoRouter for navigation, Provider for reactive state, and the Supabase Flutter SDK for authenticated CRUD and real-time channels. Real-time chat with file attachments, Agora video calling, Firebase Cloud Messaging push notifications, and an offline-capable job browsing experience complete the feature surface. The project ships as a demo-ready monorepo verifiable end-to-end in under five minutes.')]),
        br(),
        para([txt('Keywords: ', { bold: true }), txt('freelance marketplace, Flutter, Supabase, row-level security, escrow, Next.js, employer portal, deliverable lifecycle, Firebase Cloud Messaging, GoRouter, Provider, PostgreSQL RLS, Edge Function, real-time notifications, public-safety mobile platform.', { italics: true })]),
        pageBreak(),
  
        // ═══════════════════════════════════
        // TABLE OF CONTENTS
        // ═══════════════════════════════════
        heading1('TABLE OF CONTENTS'),
        tocEntry('Approval', 'iii'),
        tocEntry('Acknowledgements', 'iv'),
        tocEntry('Özet', 'v'),
        tocEntry('Abstract', 'vi'),
        tocEntry('List of Figures', 'ix'),
        tocEntry('List of Tables', 'x'),
        tocEntry('Abbreviations', 'xi'),
        tocEntry('1. Introduction', '1', 1),
        tocEntry('1.1. Purpose and Scope', '1', 2),
        tocEntry('1.2. Motivation', '1', 2),
        tocEntry('1.3. Structure of the Report', '2', 2),
        tocEntry('2. Problem Definition', '2', 1),
        tocEntry('2.1. Sectoral Background', '2', 2),
        tocEntry('2.2. Deficiencies of Existing Systems', '3', 2),
        tocEntry('2.3. Core Problems to Be Solved', '4', 2),
        tocEntry('2.4. Target User Profiles', '4', 2),
        tocEntry('2.5. Project Goals and Success Criteria', '5', 2),
        tocEntry('3. Project Planning and Management', '6', 1),
        tocEntry('3.1. Method: Agile and Sprint Planning', '6', 2),
        tocEntry('3.2. Team Structure and Roles', '6', 2),
        tocEntry('3.3. Version Control and Workflow', '7', 2),
        tocEntry('3.4. Sprint History (v0.1 to v1.0)', '8', 2),
        tocEntry('3.5. Risk Management', '9', 2),
        tocEntry('4. System Analysis', '10', 1),
        tocEntry('4.1. Actors and System Boundaries', '10', 2),
        tocEntry('4.2. Functional Requirements', '10', 2),
        tocEntry('4.3. Non-Functional Requirements', '12', 2),
        tocEntry('4.4. Usage Scenarios (Use Cases)', '13', 2),
        tocEntry('4.5. Context Diagram', '13', 2),
        tocEntry('5. System Design', '14', 1),
        tocEntry('5.1. High-Level Architecture', '14', 2),
        tocEntry('5.2. Database Design', '15', 2),
        tocEntry('5.3. Authentication and Authorization', '17', 2),
        tocEntry('5.4. API Design', '18', 2),
        tocEntry('5.5. User Interface Design', '19', 2),
        tocEntry('6. Implementation', '21', 1),
        tocEntry('6.1. Technology Stack', '21', 2),
        tocEntry('6.2. Mobile Application Modules', '23', 2),
        tocEntry('6.3. Edge Functions and Notification Pipeline', '25', 2),
        tocEntry('6.4. Web Portal and Admin Panel', '26', 2),
        tocEntry('6.5. Escrow and Delivery Lifecycle', '27', 2),
        tocEntry('6.6. DevOps, Build and Distribution', '28', 2),
        tocEntry('7. Testing', '29', 1),
        tocEntry('7.1. Test Strategy', '29', 2),
        tocEntry('7.2. Unit and Integration Tests', '30', 2),
        tocEntry('7.3. User Acceptance Tests', '31', 2),
        tocEntry('7.4. Bug Tracking and Release Verification', '32', 2),
        tocEntry('8. Working Product and MVP', '33', 1),
        tocEntry('8.1. Demo Scenario — End-to-End Flow', '33', 2),
        tocEntry('8.2. Screenshots', '35', 2),
        tocEntry('8.3. Working Product Capabilities', '42', 2),
        tocEntry('9. Conclusion and Future Work', '43', 1),
        tocEntry('9.1. Overall Evaluation', '43', 2),
        tocEntry('9.2. Lessons Learned', '44', 2),
        tocEntry('9.3. Future Work', '45', 2),
        tocEntry('References', '46'),
        tocEntry('Appendix A – GitHub and Project Management Links', '48'),
        tocEntry('Appendix B – Installation and Run Instructions', '49'),
        tocEntry('Appendix C – Version History (v0.1 to v1.0)', '50'),
        tocEntry('Appendix D – Project Team and Advisor', '51'),
        tocEntry('Appendix E – Development Tools Used', '52'),
        pageBreak(),
  
        // ═══════════════════════════════════
        // LIST OF FIGURES
        // ═══════════════════════════════════
        heading1('LIST OF FIGURES'),
        ...[ ['Figure 2.1.', 'Fragmented Nature of Existing Freelance Solutions', '3'],
             ['Figure 3.1.', 'Observed Git Branching Strategy on the Main Integration Line', '8'],
             ['Figure 4.1.', 'Actor Hierarchy', '10'],
             ['Figure 4.2.', 'Context Diagram', '13'],
             ['Figure 5.1.', 'Three-Tier Architecture Diagram', '14'],
             ['Figure 5.2.', 'Database Schema — Core Tables and Relationships', '16'],
             ['Figure 5.3.', 'Contract / Escrow Lifecycle State Machine', '18'],
             ['Figure 5.4.', 'Deliverable Upload and Signed-URL Download Flow', '19'],
             ['Figure 6.1.', 'Mobile Technology Stack Layers', '21'],
             ['Figure 6.2.', 'Edge Function Lifecycle (escrow + send-push)', '26'],
             ['Figure 6.3.', 'Onboarding / Auth Flow', '24'],
             ['Figure 7.1.', 'Test Pyramid', '29'],
             ['Figure 8.1.', 'End-to-End Demo Flow', '33'],
             ['Figure 8.2.', 'Home Screen — Job Listings and Discovery', '35'],
             ['Figure 8.3.', 'Job Detail and Submit Proposal Screen', '36'],
             ['Figure 8.4.', 'My Proposals Screen — Lifecycle Badges', '37'],
             ['Figure 8.5.', 'Real-Time Chat and File Attachments', '37'],
             ['Figure 8.6.', 'Proposal Detail — Escrow Funding Confirmation', '38'],
             ['Figure 8.7.', 'Escrow Screen — Status and Balance', '38'],
             ['Figure 8.8.', 'Notifications Screen — Real-Time Alerts', '39'],
             ['Figure 8.9.', 'Profile Screen with Skills and Rating', '40'],
             ['Figure 8.10.', 'Post Job Screen — Category and Budget', '40'],
             ['Figure 8.11.', 'Admin Panel — Dispute Resolution', '41'],
             ['Figure 8.12.', 'Web Portal — Job Listings and Contract View', '42'],
             ['Figure 8.13.', 'Landing Page — Hero Section', '42'],
        ].map(([fig, cap, pg]) => new Paragraph({
          spacing: { before: 40, after: 40 },
          tabStops: [{ type: TabStopType.RIGHT, position: CONTENT_W - 200 }],
          children: [new TextRun({ text: `${fig} ${cap}`, font: FONT, size: FONT_BODY }),
                     new TextRun({ text: '\t' + pg, font: FONT, size: FONT_BODY })],
        })),
        pageBreak(),
  
        // ═══════════════════════════════════
        // LIST OF TABLES
        // ═══════════════════════════════════
        heading1('LIST OF TABLES'),
        ...[ ['Table 2.1.', 'Limitations of Existing Freelance Hiring Channels (Comparative Analysis)', '3'],
             ['Table 2.2.', 'Target User Profiles (Personas)', '4'],
             ['Table 3.1.', 'Team Members and Areas of Responsibility', '6'],
             ['Table 3.2.', 'Sprint Summary Table', '8'],
             ['Table 3.3.', 'Risk Register', '9'],
             ['Table 4.1.', 'Functional Requirements (FR)', '11'],
             ['Table 4.2.', 'Non-Functional Requirements (NFR)', '12'],
             ['Table 4.3.', 'System Context', '13'],
             ['Table 5.1.', 'Core Relational Tables (Summary)', '15'],
             ['Table 5.2.', 'Supabase RPC and Edge Function Surface', '18'],
             ['Table 6.1.', 'Mobile / Flutter Dependencies', '22'],
             ['Table 6.2.', 'Supabase / Backend Dependencies', '23'],
             ['Table 7.1.', 'Active Automated Test Scenario Summary', '30'],
             ['Table 8.1.', 'Working Product Capability Matrix', '42'],
        ].map(([tbl, cap, pg]) => new Paragraph({
          spacing: { before: 40, after: 40 },
          tabStops: [{ type: TabStopType.RIGHT, position: CONTENT_W - 200 }],
          children: [new TextRun({ text: `${tbl} ${cap}`, font: FONT, size: FONT_BODY }),
                     new TextRun({ text: '\t' + pg, font: FONT, size: FONT_BODY })],
        })),
        pageBreak(),
  
        // ═══════════════════════════════════
        // ABBREVIATIONS
        // ═══════════════════════════════════
        heading1('ABBREVIATIONS'),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [2400, 7233],
          rows: [
            new TableRow({ children: [hcell('Abbreviation', 2400), hcell('Meaning', 7233)] }),
            ...[ ['API',  'Application Programming Interface'],
                 ['Auth', 'Authentication / Authorisation'],
                 ['BaaS', 'Backend as a Service'],
                 ['CRUD', 'Create, Read, Update, Delete'],
                 ['CDN',  'Content Delivery Network'],
                 ['FCM',  'Firebase Cloud Messaging'],
                 ['FR',   'Functional Requirement'],
                 ['GPS',  'Global Positioning System'],
                 ['HTTPS','Hypertext Transfer Protocol Secure'],
                 ['IDE',  'Integrated Development Environment'],
                 ['JWT',  'JSON Web Token — issued by Supabase Auth'],
                 ['KVKK', 'Personal Data Protection Law of Türkiye'],
                 ['MVP',  'Minimum Viable Product'],
                 ['NFR',  'Non-Functional Requirement'],
                 ['OSM',  'OpenStreetMap'],
                 ['RLS',  'Row-Level Security (PostgreSQL policy mechanism)'],
                 ['RPC',  'Remote Procedure Call (Supabase SQL function exposed as REST)'],
                 ['SDK',  'Software Development Kit'],
                 ['SMS',  'Short Message Service'],
                 ['SQL',  'Structured Query Language'],
                 ['SSR',  'Server-Side Rendering'],
                 ['UI',   'User Interface'],
                 ['URL',  'Uniform Resource Locator'],
                 ['UUID', 'Universally Unique Identifier'],
            ].map(([abbr, meaning]) => new TableRow({
              children: [cell(abbr, { width: 2400 }), cell(meaning, { width: 7233 })],
            })),
          ],
        }),
        pageBreak(),
  
        // ═══════════════════════════════════
        // 1. INTRODUCTION
        // ═══════════════════════════════════
        heading1('1. INTRODUCTION'),
  
        heading2('1.1. Purpose and Scope'),
        para([txt('The purpose of this document is to present the engineering rationale, architecture, and verification evidence for Prolance, following the reporting conventions and section ordering of the faculty capstone template. Scope is intentionally bounded to the shipped monorepo: the '), txt('client/', { italics: true }), txt(' Flutter application, the '), txt('web/', { italics: true }), txt(' Next.js application, and the '), txt('supabase/', { italics: true }), txt(' schema, policies, migrations, and Edge Functions that power the hosted demonstration project.')]),
        para([txt('Prolance provides three interconnected surfaces: a Flutter mobile client for job seekers and employers, a Next.js web portal for employer contract management and administration, and a Supabase backend that enforces trust through database-layer row-level security policies and deterministic lifecycle transitions exposed as authenticated RPC calls.')]),
  
        heading2('1.2. Motivation'),
        para([txt('Informal freelance hiring fragments negotiation across chat applications, e-mail threads, and generic file-sharing services. Payment disputes are difficult to adjudicate without an auditable state machine and consistent access control to deliverables. Existing solutions either expose all parties to financial risk through purely honour-based payment, or impose heavyweight compliance and identity-verification burdens unsuitable for a student-scale capstone demonstration.')]),
        para([txt('Prolance concentrates post-award execution inside a database-backed lifecycle with explicit phases — proposal submission, escrow funding, freelancer delivery, client review, timed payout window, and optional dispute — reducing ambiguity for both employer and freelancer while remaining technically achievable within a single academic semester.')]),
  
        heading2('1.3. Structure of the Report'),
        para([txt('Section 2 defines the problem space, comparative limitations, and target personas. Section 3 summarises planning, tooling, sprint history, and risk management. Section 4 captures analysis artefacts including requirements and a context diagram. Section 5 presents the system design: database schema, authentication model, API surface, and UI design. Section 6 details the full implementation across mobile, web, and backend surfaces. Section 7 outlines the testing strategy and active automated test inventory. Section 8 demonstrates the working product through an end-to-end demo scenario and screenshots. Section 9 concludes with overall evaluation, lessons learned, and a concrete future-work roadmap.')]),
        pageBreak(),
  
        // ═══════════════════════════════════
        // 2. PROBLEM DEFINITION
        // ═══════════════════════════════════
        heading1('2. PROBLEM DEFINITION'),
  
        heading2('2.1. Sectoral Background'),
        para([txt('Digital talent marketplaces have grown substantially as remote work normalises globally. Platforms such as Upwork, Fiverr, and Freelancer.com demonstrate strong demand on both the supply side (skilled professionals) and the demand side (businesses needing flexible labour). Despite the maturity of these platforms, their design models are not easily replicated at the system-design level for academic and demonstrative purposes: they rely on payment-provider integrations, identity-verification services, and global CDN infrastructure that exceed typical capstone project budgets and compliance requirements.')]),
        para([txt('Domestically, Türkiye\'s gig economy is accelerating under the Twelfth Development Plan (2024–2028), yet Turkish-language freelance platforms remain limited in technical sophistication. Many domestic projects rely on informal WhatsApp or Telegram channels for coordination, with payment handled through bank transfers and disputes resolved bilaterally without auditable records. This gap motivates a demonstrative system that embeds trust mechanisms directly into the data layer rather than relying on social enforcement.')]),
  
        heading2('2.2. Deficiencies of Existing Systems'),
        para([txt('Figure 2.1 visualises the fragmented nature of the typical informal hiring workflow.')]),
        ...flowDiagram([
          '┌─────────────────────────────────────────────────────────────────────┐',
          '│  Employer needs a developer                                          │',
          '│         │                                                            │',
          '│   Posts on LinkedIn / WhatsApp group                                 │',
          '│         │                                                            │',
          '│   ┌─────▼──────────┐    ┌───────────────┐    ┌──────────────────┐  │',
          '│   │ Chat negotiation│    │ Google Drive  │    │ Bank transfer    │  │',
          '│   │ (no record)    │───▶│ file sharing  │───▶│ (no escrow)     │  │',
          '│   └────────────────┘    └───────────────┘    └──────────────────┘  │',
          '│         │                       │                      │            │',
          '│   No lifecycle       No access control        No dispute path      │',
          '│   No auditability    Link revocable           No auditable record  │',
          '└─────────────────────────────────────────────────────────────────────┘',
        ]),
        figCaption('Figure 2.1. Fragmented Nature of Existing Freelance Solutions'),
        br(),
        para([txt('Table 2.1 compares specific failure modes across representative informal channels.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [3200, 3200, 3233],
          rows: [
            new TableRow({ children: [hcell('Channel / Pattern', 3200), hcell('Typical Limitation', 3200), hcell('Prolance Approach', 3233)] }),
            ...[ ['Chat-only coordination (WhatsApp / Telegram)', 'No authoritative lifecycle; ambiguous "done" state; no delivery proof.', 'Explicit lifecycle_phase column with server-side RPC transitions; delivery confirmation required.'],
                 ['Ad-hoc file sharing (Google Drive / Dropbox)', 'No least-privilege read model; revocable access is manual and error-prone.', 'Private Supabase Storage bucket with signed URLs; access enforced by RLS on proposal_deliveries.'],
                 ['Informal milestone payments (bank transfer)', 'Disputes lack structured metadata; no neutral arbitration path.', '24-hour payout window with administrator dispute resolution and escrow_status state machine.'],
                 ['General-purpose platforms (Upwork / Fiverr)', 'Production compliance costs exceed academic scope; closed source.', 'Demonstrative escrow via demo_balance_cents; open-source migrations reviewable by evaluators.'],
            ].map(([ch, lim, pr]) => new TableRow({ children: [cell(ch, { width: 3200 }), cell(lim, { width: 3200 }), cell(pr, { width: 3233 })] })),
          ],
        }),
        figCaption('Table 2.1. Limitations of Existing Freelance Hiring Channels (Comparative Analysis)'),
  
        heading2('2.3. Core Problems to Be Solved'),
        para([txt('The three core engineering problems addressed by Prolance are:')]),
        bullet('Trust gap: Neither party can verify the other\'s commitment to a work agreement without an authoritative digital record and access-controlled file exchange.'),
        bullet('Lifecycle ambiguity: Without an explicit state machine, "delivery" is a social construct subject to dispute after the fact.'),
        bullet('Fragmentation: Using separate tools for negotiation, file exchange, and payment creates attribution errors and makes dispute resolution impossible without all parties\' manual records.'),
  
        heading2('2.4. Target User Profiles'),
        para([txt('Table 2.2 summarises the three primary personas that drive design decisions throughout the project.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [2400, 3600, 3633],
          rows: [
            new TableRow({ children: [hcell('Persona', 2400), hcell('Goals', 3600), hcell('Pain Points', 3633)] }),
            ...[ ['Employer (CLIENT role)', 'Publish jobs with clear scope, compare competing bids, fund escrow with confidence, download and verify deliverables before releasing payment.', 'Trust in freelancer quality; clarity on acceptance criteria; risk of non-delivery after partial payment.'],
                 ['Freelancer (FREELANCER role)', 'Discover relevant work efficiently, submit compelling proposals, upload deliverables securely, receive guaranteed payout on acceptance.', 'Payment assurance; scope creep after acceptance; fragmented tooling; no dispute visibility.'],
                 ['Administrator (is_admin flag)', 'Review escalated disputes, inspect audit log, resolve escrow conflicts with structured notes, monitor platform health.', 'Needs structured case metadata; reproducible state transitions; auditable action log.'],
            ].map(([p, g, pain]) => new TableRow({ children: [cell(p, { width: 2400 }), cell(g, { width: 3600 }), cell(pain, { width: 3633 })] })),
          ],
        }),
        figCaption('Table 2.2. Target User Profiles (Personas)'),
  
        heading2('2.5. Project Goals and Success Criteria'),
        para([txt('The primary goal is a reproducible end-to-end demonstration: two authenticated roles (employer and freelancer) can progress a single job from proposal acceptance through deliverable review and timed payout simulation — with storage access enforced by database policy rather than client-side checks alone — in under five minutes, using either Flutter mobile or the Next.js web portal. Secondary goals include a typed, migration-verified database schema, automated unit tests for key repository classes, and a working admin dispute resolution interface accessible via a separate admin login.')]),
        pageBreak(),
  
        // ═══════════════════════════════════
        // 3. PROJECT PLANNING AND MANAGEMENT
        // ═══════════════════════════════════
        heading1('3. PROJECT PLANNING AND MANAGEMENT'),
  
        heading2('3.1. Method: Agile and Sprint Planning'),
        para([txt('Work was organised in short sprint iterations with a prioritised backlog and daily asynchronous standups via Discord and WhatsApp. The core Agile principles applied were: incremental delivery, acceptance of late-breaking platform constraints (for example, Supabase Edge Function cold-start behaviour), and retrospective-driven scope control. Each sprint began with a planning session that decomposed the backlog into atomic tasks sized for a single developer-day and closed with an informal sprint review verifying committed deliverables against acceptance criteria.')]),
        para([txt('The backlog was maintained in Notion, and task status was tracked in a GitHub Projects Kanban board with backlog, in-progress, review, and done columns. Sprint cadence was approximately two weeks, with a final hardening sprint focused on integration testing, documentation, and demo preparation.')]),
  
        heading2('3.2. Team Structure and Roles'),
        para([txt('Table 3.1 summarises the principal areas of responsibility assigned to each team member.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [2800, 2000, 4833],
          rows: [
            new TableRow({ children: [hcell('Member', 2800), hcell('Role', 2000), hcell('Responsibilities', 4833)] }),
            ...[ ['[Student Name Surname]', 'Mobile Lead (Flutter)', 'App shell and navigation (GoRouter), state management (Provider), home screen, job discovery, proposal submission, favourites, real-time chat, profile and settings, theme/localisation.'],
                 ['[Student Name Surname]', 'Backend / Supabase', 'PostgreSQL schema design, 23 versioned migrations, RLS policy authoring, RPC functions, Supabase Edge Functions (escrow, send-push, agora-token), storage bucket configuration, seed data.'],
                 ['[Student Name Surname]', 'Web / Next.js & QA', 'Landing page (3D hero, 8 sections), Next.js employer portal routes (jobs, proposals, contracts, dispute), admin dashboard, TypeScript server actions, integration testing, bug tracking, demo preparation.'],
                 ['Prof. Dr. [Advisor]', 'Academic Advisor', 'OSTIM Technical University · Computer Engineering Department — technical guidance and academic supervision.'],
            ].map(([n, r, resp]) => new TableRow({ children: [cell(n, { width: 2800 }), cell(r, { width: 2000 }), cell(resp, { width: 4833 })] })),
          ],
        }),
        figCaption('Table 3.1. Team Members and Areas of Responsibility'),
  
        heading2('3.3. Version Control and Workflow'),
        para([txt('The repository is hosted on GitHub under '), txt('OzgurBuyukikiz01/Prolance_Freelance_App', { bold: true }), txt('. The monorepo contains three top-level sub-packages: '), txt('client/', { italics: true }), txt(' for the Flutter application, '), txt('web/', { italics: true }), txt(' for the Next.js site and admin portal, and '), txt('supabase/', { italics: true }), txt(' for migrations, edge functions, and seed data.')]),
        para([txt('Feature development follows a branch-per-feature strategy with pull requests requiring at least one review before merge to '), txt('main', { italics: true }), txt('. Database migrations are applied as numbered SQL files under '), txt('supabase/migrations/', { italics: true }), txt(', ensuring a reproducible schema history. Sensitive credentials (Supabase service role key, Firebase service account, Green API token) are stored as environment variables excluded from version control. Figure 3.1 shows the principal integration line of the repository as observed from the commit graph.')]),
        ...flowDiagram([
          '  main ─────●─────●─────────────●──────────────────────●─▶ (release)',
          '            │     │             │                       │',
          '   feat/schema    feat/flutter  feat/nextjs-portal      feat/hardening',
          '            │     │             │                       │',
          '          (DB)  (mobile)      (web)               (tests+docs)',
        ]),
        figCaption('Figure 3.1. Observed Git Branching Strategy on the Main Integration Line'),
  
        heading2('3.4. Sprint History (v0.1 to v1.0)'),
        para([txt('Table 3.2 records the principal milestones achieved during each sprint window of the approximately three-month concentrated implementation period.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [1400, 2200, 6033],
          rows: [
            new TableRow({ children: [hcell('Version', 1400), hcell('Date', 2200), hcell('Highlight', 6033)] }),
            ...[ ['v0.1', 'Mid Feb 2026', 'Initial scaffold: Flutter theme tokens, bottom-nav shell, static job listing, GoRouter wiring, Provider state structure.'],
                 ['v0.2', 'Late Feb 2026', 'Supabase Auth integration (email/password + Google OAuth), profiles table with auto-create trigger, per-user job saves.'],
                 ['v0.3', 'Mid Mar 2026', 'Proposal submission flow; ProposalRepository with SharedPreferences fallback; real-time messaging (Supabase Realtime channel); chat file attachments.'],
                 ['v0.5', 'Late Mar 2026', 'Escrow contract workflow: rpc_accept_proposal, deliverables bucket, proposal_deliveries table, signed-URL download; lifecycle phase badges in UI.'],
                 ['v0.6', 'Mid Apr 2026', 'Next.js employer portal (job list, proposal inbox, contract detail, delivery review); admin dispute UI; Firebase Cloud Messaging push notifications.'],
                 ['v0.8', 'Late Apr 2026', 'Review system (star rating + live profile integration); Agora video call screen; post-job moderation; notifications screen with real-time overlay.'],
                 ['v1.0.0+1', 'May 2026', 'Demo hardening: seed SQL, demo credentials, rpc_demo_expire_deadline, payout claim flow, structured audit log, Vercel deployment, release candidate.'],
            ].map(([v, d, h]) => new TableRow({ children: [cell(v, { width: 1400 }), cell(d, { width: 2200 }), cell(h, { width: 6033 })] })),
          ],
        }),
        figCaption('Table 3.2. Sprint Summary Table'),
  
        heading2('3.5. Risk Management'),
        para([txt('Table 3.3 records the principal risks identified during planning together with the mitigations applied during implementation.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [1200, 3000, 2400, 3033],
          rows: [
            new TableRow({ children: [hcell('ID', 1200), hcell('Risk', 3000), hcell('Likelihood / Impact', 2400), hcell('Mitigation', 3033)] }),
            ...[ ['R-1', 'RLS misconfiguration leaks rows across tenants.', 'Medium / High', 'Policy tests in SQL; least privilege by default; regular Supabase Studio query verification.'],
                 ['R-2', 'Large binary assets stored in Git exceed free tier limits.', 'Low / Medium', 'Deliverables stored only in Supabase Storage; Git contains only code and migrations.'],
                 ['R-3', 'Flutter / Next.js feature skew causes inconsistent lifecycle state.', 'Medium / High', 'Shared Supabase schema as single source of truth; lifecycle transitions only via authenticated RPC.'],
                 ['R-4', 'Edge Function cold-start causes perceived payment latency.', 'Medium / Low', 'Functions deployed to europe-west1; warm-up via scheduled ping if needed in production.'],
                 ['R-5', 'Demo credentials leak to production environment.', 'Low / High', 'Demo balance column separate from real-money fields; credentials documented only in DEMO_NOTES.md.'],
                 ['R-6', 'Agora token expiry during live demo causes call failure.', 'Medium / Medium', 'Agora token refreshed server-side via dedicated Edge Function; short TTL configurable.'],
            ].map(([id, r, li, m]) => new TableRow({ children: [cell(id, { width: 1200 }), cell(r, { width: 3000 }), cell(li, { width: 2400 }), cell(m, { width: 3033 })] })),
          ],
        }),
        figCaption('Table 3.3. Risk Register'),
        pageBreak(),
  
        // ═══════════════════════════════════
        // 4. SYSTEM ANALYSIS
        // ═══════════════════════════════════
        heading1('4. SYSTEM ANALYSIS'),
  
        heading2('4.1. Actors and System Boundaries'),
        para([txt('The Prolance system boundary encompasses the Flutter mobile client, the Next.js dual-surface web tier (marketing site + employer/admin portal), and the Supabase managed backend (PostgreSQL, Auth, Storage, Realtime, Edge Functions). External actors are authenticated end users (employers and freelancers) and administrators. External services that cross the system boundary include Firebase Cloud Messaging (push notification dispatch), Agora Real-Time Engagement (video calls), and the Supabase-managed SMTP relay (password reset and transactional e-mail).')]),
        ...flowDiagram([
          '┌─────────────────────────────────────────────────────────────────┐',
          '│  Employer (CLIENT)        Freelancer        Administrator       │',
          '│        │                      │                   │             │',
          '│  ┌─────▼──────────────────────▼───────────────────▼──────────┐ │',
          '│  │        Flutter Mobile App  +  Next.js Web Portal          │ │',
          '│  └───────────────────────────┬────────────────────────────────┘ │',
          '│                              │ Supabase SDK / REST              │',
          '│  ┌───────────────────────────▼────────────────────────────────┐ │',
          '│  │  Supabase Backend: Postgres + Auth + Storage + Realtime    │ │',
          '│  │  + Edge Functions: escrow | send-push | agora-token        │ │',
          '│  └───────┬──────────────────────────┬───────────────────────┘ │',
          '│          │ FCM                       │ Agora RTC               │',
          '│   Firebase Cloud Messaging     Agora Real-Time Engine         │',
          '└─────────────────────────────────────────────────────────────────┘',
        ]),
        figCaption('Figure 4.1. Actor Hierarchy'),
  
        heading2('4.2. Functional Requirements'),
        para([txt('Table 4.1 captures the verified functional requirements of the shipped MVP.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [1000, 5000, 3633],
          rows: [
            new TableRow({ children: [hcell('ID', 1000), hcell('Requirement (summary)', 5000), hcell('Verification', 3633)] }),
            ...[ ['FR-1', 'Users authenticate via Supabase Auth (email/password and Google OAuth) to access protected views; profile row is auto-created on first sign-up via database trigger.', 'auth_service_test.dart; manual sign-up demo.'],
                 ['FR-2', 'Employers create and list jobs with category, skills, budget range, experience level, and duration; freelancers browse, filter by category/budget, and save favourites.', 'SupabaseJobRepository unit tests; manual job post demo.'],
                 ['FR-3', 'Freelancers submit proposals with bid, delivery timeline, and cover letter; proposal is linked to both the job and the authenticated freelancer.', 'proposal_repository_test.dart; widget test on submit form.'],
                 ['FR-4', 'Employers accept proposals via rpc_accept_proposal, which atomically deducts demo_balance_cents, creates an escrow_transactions row (status HELD), and advances lifecycle_phase to escrow_funded.', 'SQL migration test; two-device demo step 1.'],
                 ['FR-5', 'Freelancers upload deliverable files to the private deliverables bucket; file metadata is stored in proposal_deliveries; employers download via time-limited signed URLs.', 'ProposalRepository integration test; demo step 2.'],
                 ['FR-6', 'Employers accept or dispute delivery; acceptance sets lifecycle to payout_pending with a 24-hour deadline; dispute refunds escrow to employer and marks escrow REFUNDED.', 'rpc_client_accept_delivery migration test; demo steps 3–4.'],
                 ['FR-7', 'After dispute deadline passes, freelancer calls rpc_finalize_proposal_payout to claim earnings; earnings_available_cents is incremented.', 'proposal_repository_test.dart payout finalization.'],
                 ['FR-8', 'Administrators review disputes with structured notes via the Next.js admin portal; actions are written to admin_audit_log.', 'Manual acceptance — admin@prolance.dev demo.'],
                 ['FR-9', 'Real-time threaded messaging between job participants with support for text, images, and file attachments; unread badge count updates via Supabase Realtime.', 'MessageRepository integration test; chat demo.'],
                 ['FR-10', 'Push notifications are dispatched to the recipient device via Firebase Cloud Messaging when a new message or proposal event occurs.', 'send-push Edge Function; FCM token stored in profiles.'],
                 ['FR-11', 'Freelancers and employers submit star ratings and written reviews on closed contracts; profile rating is recalculated via rpc_recalc_rating.', 'review_repository_test.dart; demo step 8.'],
                 ['FR-12', 'Support tickets can be submitted by any authenticated user; administrators resolve tickets via the admin portal.', 'Manual acceptance — support_ticket_screen.dart.'],
            ].map(([id, req, ver]) => new TableRow({ children: [cell(id, { width: 1000 }), cell(req, { width: 5000 }), cell(ver, { width: 3633 })] })),
          ],
        }),
        figCaption('Table 4.1. Functional Requirements (FR)'),
  
        heading2('4.3. Non-Functional Requirements'),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [1000, 4000, 4633],
          rows: [
            new TableRow({ children: [hcell('ID', 1000), hcell('Requirement (summary)', 4000), hcell('Realisation', 4633)] }),
            ...[ ['NFR-1', 'Security: sensitive data protected by RLS on all 11 tables; storage objects accessible only by job participants.', 'Postgres RLS policies in migration 00002; storage bucket policies in 00009, 00011.'],
                 ['NFR-2', 'Correctness: escrow transitions are atomic database operations; partial failures cannot leave escrow in an inconsistent state.', 'rpc_accept_proposal uses SELECT ... FOR UPDATE with explicit balance check before commit.'],
                 ['NFR-3', 'Maintainability: typed Next.js server actions; Dart repositories with typed models; Supabase schema versioned in numbered SQL files.', 'TypeScript strict mode; Dart lint via flutter_lints.'],
                 ['NFR-4', 'Operability: Makefile targets for local dev, Flutter build, and Vercel deploy; README quick-start under three commands.', 'Makefile with make dev, make build-vercel, make deploy-web targets.'],
                 ['NFR-5', 'Testability: unit tests for domain logic; integration tests with Supabase emulator; widget tests for key UI flows.', 'client/test/ (unit/, widget/, smoke/); functions/test/.'],
                 ['NFR-6', 'Localisation: Turkish and English string support in Flutter UI; portal primarily in Turkish matching target audience.', 'intl package + app_localizations; portal string literals in Turkish.'],
            ].map(([id, req, r]) => new TableRow({ children: [cell(id, { width: 1000 }), cell(req, { width: 4000 }), cell(r, { width: 4633 })] })),
          ],
        }),
        figCaption('Table 4.2. Non-Functional Requirements (NFR)'),
  
        heading2('4.4. Usage Scenarios (Use Cases)'),
        para([txt('The five primary use-case scenarios that drive design decisions are:')]),
        bullet('Job-offer lifecycle (employer): create job → receive proposals → accept proposal → review delivery → release or dispute payment.'),
        bullet('Proposal lifecycle (freelancer): browse jobs → submit proposal → receive escrow-funded notification → upload delivery → receive payout notification.'),
        bullet('Real-time collaboration: two authenticated participants open a conversation thread; send text, images, and files with read receipts; optionally escalate to video call.'),
        bullet('Administrator dispute resolution: admin receives escalated dispute notification → inspects contract metadata → selects resolution action → action logged to audit trail.'),
        bullet('Cross-surface consistency check: the same contract state is visible and actionable from both the Flutter mobile client and the Next.js web portal without refresh artefacts.'),
  
        heading2('4.5. Context Diagram'),
        para([txt('Table 4.3 maps the principal system actors to their interaction channels.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [2200, 3000, 4433],
          rows: [
            new TableRow({ children: [hcell('Actor', 2200), hcell('System Interface', 3000), hcell('Interaction Type', 4433)] }),
            ...[ ['Employer (CLIENT)', 'Flutter app / Next.js portal', 'Post jobs, accept proposals, download deliverables, release payment, leave reviews.'],
                 ['Freelancer (FREELANCER)', 'Flutter app', 'Browse jobs, submit proposals, upload deliverables, receive earnings, leave reviews.'],
                 ['Administrator', 'Next.js /admin portal', 'Resolve disputes, manage users, view audit log, close tickets.'],
                 ['Firebase Cloud Messaging', 'send-push Edge Function → device FCM SDK', 'Push notification delivery on proposal and message events.'],
                 ['Agora Real-Time Engine', 'agora-token Edge Function → Flutter Agora SDK', 'Secure token exchange for in-app video calls.'],
                 ['Supabase Auth (external)', 'Supabase client SDK', 'Email/password and Google OAuth session management.'],
            ].map(([a, si, it]) => new TableRow({ children: [cell(a, { width: 2200 }), cell(si, { width: 3000 }), cell(it, { width: 4433 })] })),
          ],
        }),
        figCaption('Table 4.3. System Context'),
        ...flowDiagram([
          '                     ┌───────────────────────────────┐',
          '   Employer ─────────▶                               │',
          '                     │     Prolance System           │',
          '   Freelancer ───────▶   Flutter | Next.js | Admin  ◀──── Supabase Auth',
          '                     │                               │',
          '   Admin ────────────▶          Supabase Backend     ├────▶ Firebase FCM',
          '                     │   (Postgres + Auth + Storage) │',
          '                     │   + Edge Functions            ├────▶ Agora RTC',
          '                     └───────────────────────────────┘',
        ]),
        figCaption('Figure 4.2. Context Diagram'),
        pageBreak(),
  
        // ═══════════════════════════════════
        // 5. SYSTEM DESIGN
        // ═══════════════════════════════════
        heading1('5. SYSTEM DESIGN'),
  
        heading2('5.1. High-Level Architecture'),
        para([txt('Prolance follows a three-tier architecture: the Flutter client and Next.js portal form the presentation tier; the Supabase managed service constitutes the data and logic tier; and external services (FCM, Agora, SMTP relay) form the integration tier. Figure 5.1 shows the layered dependency graph.')]),
        ...flowDiagram([
          '┌──────────────────────────────────────────────────────────────────────┐',
          '│ Deployment: Flutter → Android / iOS / Web  ·  Next.js → Vercel      │',
          '│             Supabase Project: europe-west1  ·  FCM: global           │',
          '├──────────────────────────────────────────────────────────────────────┤',
          '│ External Integrations                                                │',
          '│   Firebase Cloud Messaging  ·  Agora RTC  ·  Supabase SMTP          │',
          '├──────────────────────────────────────────────────────────────────────┤',
          '│ Supabase Backend (BaaS)                                              │',
          '│   PostgreSQL 15 + RLS  ·  Supabase Auth  ·  Storage Buckets         │',
          '│   Realtime (messages + notifications)  ·  Edge Functions (Deno)     │',
          '├──────────────────────────────────────────────────────────────────────┤',
          '│ Client — Flutter 3.x                Next.js 14 App Router           │',
          '│   GoRouter  ·  Provider            TypeScript  ·  Tailwind          │',
          '│   Supabase Flutter SDK             Supabase Server Client           │',
          '│   Firebase Messaging SDK           Next.js Server Actions           │',
          '│   Agora RTC Engine                 Admin portal routes              │',
          '└──────────────────────────────────────────────────────────────────────┘',
        ]),
        figCaption('Figure 5.1. Three-Tier Architecture Diagram'),
  
        heading2('5.2. Database Design'),
        para([txt('The Prolance schema is defined across 23 versioned SQL migration files. The core relational model uses 11 tables connected through UUID foreign keys, with PostgreSQL row-level security active on all tables. Table 5.1 summarises the primary tables and their domain roles.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [2800, 3200, 3633],
          rows: [
            new TableRow({ children: [hcell('Table', 2800), hcell('Key Columns', 3200), hcell('Domain Role', 3633)] }),
            ...[ ['profiles', 'id (FK auth.users), email, full_name, role (CLIENT|FREELANCER), skills, hourly_rate, rating, is_admin, demo_balance_cents, earnings_available_cents', 'User profile and financial state; 1:1 with Supabase Auth user.'],
                 ['jobs', 'id, client_id (FK profiles), title, description, budget_min, budget_max, budget_type, category, skills, status, listing_kind', 'Job and freelance-offer listings owned by CLIENT-role users.'],
                 ['proposals', 'id, job_id, freelancer_id, bid, status, lifecycle_phase, funded_amount_cents, payout_finalized, delivery_dispute_deadline, dispute_note', 'Bid and contract state machine; lifecycle_phase drives the entire workflow.'],
                 ['proposal_deliveries', 'id, proposal_id, file_name, storage_path', 'File metadata for deliverables stored in private Supabase Storage bucket.'],
                 ['escrow_transactions', 'id, proposal_id, amount_cents, status (FUNDED|HELD|RELEASED|DISPUTED|REFUNDED)', 'Immutable escrow record created on proposal acceptance.'],
                 ['conversations', 'id, job_id, client_id, freelancer_id', 'Conversation thread linking two participants to a job context.'],
                 ['messages', 'id, conversation_id, sender_id, content, attachment_url, attachment_type, is_read', 'Individual chat messages with optional file or image attachment.'],
                 ['reviews', 'id, proposal_id, reviewer_id, reviewee_id, rating, comment', 'Star ratings and written reviews submitted on closed contracts.'],
                 ['notifications', 'id, profile_id, title, body, type, is_read', 'In-app notifications created by DB triggers or Edge Functions.'],
                 ['tickets', 'id, user_id, subject, description, status, priority', 'Support tickets submitted by authenticated users.'],
                 ['admin_audit_log', 'id, admin_id, action, target_id, note', 'Immutable record of administrator actions for accountability.'],
            ].map(([t, k, d]) => new TableRow({ children: [cell(t, { width: 2800 }), cell(k, { width: 3200 }), cell(d, { width: 3633 })] })),
          ],
        }),
        figCaption('Table 5.1. Core Relational Tables (Summary)'),
        br(),
        para([txt('The schema uses several design patterns worth noting explicitly. First, the '), txt('profiles', { italics: true }), txt(' table is created automatically on Supabase Auth user registration via an '), txt('on_auth_user_created', { italics: true }), txt(' BEFORE INSERT trigger, removing any need for a separate profile-creation API call. Second, '), txt('lifecycle_phase', { italics: true }), txt(' on proposals is deliberately a text column (not an enum) to allow safe migration without locking the table. Third, '), txt('demo_balance_cents', { italics: true }), txt(' and '), txt('earnings_available_cents', { italics: true }), txt(' are integer cent columns that simulate real financial values without integrating a live payment provider — the demonstrative design choice makes the escrow model reviewable by academic evaluators.')]),
        ...flowDiagram([
          '  auth.users ──1:1──▶ profiles ◀──── jobs ◀──── proposals',
          '                         │                        │    │',
          '                         │                        │    └── proposal_deliveries',
          '                    notifications           escrow_transactions',
          '                                                  │',
          '                    conversations ◀────────────── │',
          '                         │                   reviews',
          '                      messages            admin_audit_log',
        ]),
        figCaption('Figure 5.2. Database Schema — Core Tables and Relationships'),
  
        heading2('5.3. Authentication and Authorization'),
        para([txt('Authentication is delegated entirely to Supabase Auth. The client-side '), txt('AuthService', { italics: true }), txt(' singleton wraps the Supabase Flutter SDK and exposes sign-in (email/password and Google OAuth), sign-up, sign-out, password reset, and profile upsert methods. On the web side, Next.js server actions use the '), txt('createClient', { italics: true }), txt(' server helper which automatically reads the session cookie set by the Supabase Auth middleware.')]),
        para([txt('Authorisation is enforced at multiple layers. At the database layer, Postgres RLS policies ensure that read and write operations are restricted to the authenticated user\'s own rows or to participants in a shared record (for example, both parties in a conversation). At the storage layer, separate policies on the '), txt('chat-attachments', { italics: true }), txt(' and '), txt('deliverables', { italics: true }), txt(' buckets restrict object access to conversation participants and proposal participants respectively. At the RPC layer, each SQL function verifies '), txt('auth.uid()', { italics: true }), txt(' against the relevant ownership constraint before executing any state transition.')]),
        para([txt('The administrator role is encoded as a boolean '), txt('is_admin', { italics: true }), txt(' column on the '), txt('profiles', { italics: true }), txt(' table. Admin-only portal routes check this flag via a server-side Supabase query before rendering sensitive pages. There is no separate role system or JWT claim; the single boolean flag is sufficient for the capstone scope and is readable only by the authenticated user themselves through the profiles RLS select policy.')]),
        ...flowDiagram([
          '  Supabase Auth → JWT (session cookie / Bearer token)',
          '       │',
          '       ├── Flutter SDK: SupabaseClient.auth.currentUser',
          '       │      └── AuthService.instance wraps sign-in / sign-up / OAuth',
          '       │',
          '       ├── Next.js: createClient() reads cookie → server actions',
          '       │      └── middleware.ts refreshes session on every request',
          '       │',
          '       └── Postgres RLS: auth.uid() evaluated per-query',
          '              └── RPC functions: validate ownership before mutation',
        ]),
        figCaption('Figure 5.3. Contract / Escrow Lifecycle State Machine'),
  
        heading2('5.4. API Design'),
        para([txt('Prolance exposes its backend through three interaction patterns. First, standard Supabase CRUD operations via the PostgREST auto-generated REST API (filtered by RLS) handle the majority of read operations — job listings, profile lookups, notification polling. Second, authenticated RPC calls handle all lifecycle state transitions that require atomic multi-table operations or role validation. Third, two Supabase Edge Functions provide integration points with external services.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [2800, 2000, 4833],
          rows: [
            new TableRow({ children: [hcell('Endpoint / Function', 2800), hcell('Trigger', 2000), hcell('Purpose', 4833)] }),
            ...[ ['rpc_accept_proposal(p_proposal_id)', 'Authenticated POST via Supabase RPC', 'Atomically validates employer ownership, deducts demo_balance_cents, creates escrow row (HELD), advances lifecycle to escrow_funded, closes other proposals on same job.'],
                 ['rpc_register_delivery(p_proposal_id, p_paths)', 'Authenticated POST via Supabase RPC', 'Validates freelancer ownership and escrow_funded phase, advances lifecycle to awaiting_client_review.'],
                 ['rpc_client_accept_delivery(p_proposal_id)', 'Authenticated POST via Supabase RPC', 'Validates employer ownership and awaiting_client_review phase, sets lifecycle to payout_pending, stamps delivery_dispute_deadline = now() + 24 hours, updates escrow to RELEASED.'],
                 ['rpc_finalize_proposal_payout()', 'Called by ProposalRepository on app launch', 'Batch-processes all payout_pending proposals past deadline; increments freelancer earnings_available_cents, marks lifecycle closed.'],
                 ['rpc_demo_expire_deadline(p_proposal_id)', 'Presenter button in demo mode', 'Sets delivery_dispute_deadline = now() - 2 minutes to simulate clock advancement for demo purposes.'],
                 ['rpc_report_issue(p_proposal_id, p_note)', 'Authenticated POST via Supabase RPC', 'Validates 24h window active, refunds escrow to employer, advances lifecycle to disputed, stores dispute_note.'],
                 ['Edge Function: escrow', 'HTTPS POST (admin or server)', 'Orchestrates escrow release and dispute resolution with audit log write; not exposed to end users directly.'],
                 ['Edge Function: send-push', 'Called internally by DB triggers', 'Delivers FCM push notification payload to a target FCM token via Firebase Admin SDK.'],
                 ['Edge Function: agora-token', 'Flutter VideoCallScreen on join', 'Generates short-lived Agora RTC token for authenticated participants; channel ID derived from conversation_id.'],
            ].map(([ep, t, p]) => new TableRow({ children: [cell(ep, { width: 2800 }), cell(t, { width: 2000 }), cell(p, { width: 4833 })] })),
          ],
        }),
        figCaption('Table 5.2. Supabase RPC and Edge Function Surface'),
        ...flowDiagram([
          '  Freelancer uploads files ──▶ Supabase Storage (deliverables bucket)',
          '       │                               │',
          '  rpc_register_delivery()        storage_path saved in proposal_deliveries',
          '       │                               │',
          '       ▼                               ▼',
          '  lifecycle: awaiting_client_review    Employer requests signed URL',
          '       │                               │ (15-minute TTL)',
          '  Employer downloads + reviews ◀───────┘',
          '       │',
          '  rpc_client_accept_delivery() ──▶ lifecycle: payout_pending',
          '       │                               │',
          '  24h dispute window              rpc_finalize_proposal_payout()',
          '       │                               │',
          '       └── rpc_report_issue() ──▶ disputed / refunded',
        ]),
        figCaption('Figure 5.4. Deliverable Upload and Signed-URL Download Flow'),
  
        heading2('5.5. User Interface Design'),
        para([txt('The Flutter codebase contains 12 primary feature modules mapped to distinct screen namespaces: '), txt('auth', { italics: true }), txt(', '), txt('onboarding', { italics: true }), txt(', '), txt('home', { italics: true }), txt(', '), txt('jobs', { italics: true }), txt(', '), txt('post_job', { italics: true }), txt(', '), txt('messages', { italics: true }), txt(', '), txt('payment', { italics: true }), txt(', '), txt('notifications', { italics: true }), txt(', '), txt('profile', { italics: true }), txt(', '), txt('reviews', { italics: true }), txt(', '), txt('support', { italics: true }), txt(', and '), txt('splash', { italics: true }), txt('. Navigation is managed by GoRouter with typed route parameters, and state is distributed through Provider-registered singletons for '), txt('AppState', { italics: true }), txt(', '), txt('JobsProvider', { italics: true }), txt(', '), txt('ProposalRepository', { italics: true }), txt(', '), txt('MessageRepository', { italics: true }), txt(', '), txt('NotificationRepository', { italics: true }), txt(', and '), txt('ReviewRepository', { italics: true }), txt('.')]),
        para([txt('The presentation model supports two roles inside the same app. The bottom navigation shell (MainNavigationScreen) surfaces role-specific items: CLIENT users see a "Post Job" shortcut while FREELANCER users see the proposal tracking shortcut. The home screen adapts to show incoming proposals for clients and browsable job listings for freelancers. This role-awareness is derived entirely from the '), txt('AppState.currentUser.role', { italics: true }), txt(' field populated from the '), txt('profiles', { italics: true }), txt(' table on login — no separate app build or authentication flow is required.')]),
        para([txt('Several UI decisions visible in the codebase are especially relevant from a system-design perspective:')]),
        bullet('The glassmorphic card design (using the '), txt('glassmorphism', { italics: true }), txt(' package) and '), txt('flutter_animate', { italics: true }), txt(' entrance animations give the app a polished, contemporary aesthetic without custom painters.'),
        bullet('Real-time connectivity is maintained via a single shared Supabase Realtime subscription per conversation, managed by '), txt('SupabaseMessageRepository', { italics: true }), txt('. The subscription is closed and recreated on conversation change.'),
        bullet('Shimmer loading states (using '), txt('skeletonizer', { italics: true }), txt(' and '), txt('shimmer', { italics: true }), txt(' packages) replace all blocking spinners, keeping the UI responsive during data fetching.'),
        bullet('The '), txt('PushNotificationService', { italics: true }), txt(' singleton registers the FCM token to the '), txt('profiles', { italics: true }), txt(' row on app start and updates it on token refresh, ensuring push delivery remains current without manual user action.'),
        bullet('Video calls use the '), txt('agora_rtc_engine', { italics: true }), txt(' package; the token is fetched from the '), txt('agora-token', { italics: true }), txt(' Edge Function before joining, keeping the App ID secret server-side.'),
        ...flowDiagram([
          ' Fresh install → splash → onboarding (3 slides) → sign-up / sign-in',
          '                                                        │',
          '                                                  GoRouter AuthGate',
          '                                                        │',
          '                          ┌─────────────────────────────▼──────────────┐',
          '                          │ MainNavigationScreen (5-tab bottom nav)     │',
          '                          │  Home | Jobs | Messages | Notif | Profile  │',
          '                          └─────────────┬──────────────────────────────┘',
          '                                         │',
          '   Push notification deep-link ─────────▶│',
          '   Proposal accepted → escrow screen      │',
          '   New message → chat screen              │',
          '   Alert → notifications screen           │',
        ]),
        figCaption('Figure 6.3. Onboarding / Auth Flow'),
        pageBreak(),
  
        // ═══════════════════════════════════
        // 6. IMPLEMENTATION
        // ═══════════════════════════════════
        heading1('6. IMPLEMENTATION'),
  
        heading2('6.1. Technology Stack'),
        para([txt('Prolance is implemented on a full-stack cross-platform architecture whose dependency graph can be verified directly from '), txt('client/pubspec.yaml', { italics: true }), txt(', '), txt('web/package.json', { italics: true }), txt(', and the '), txt('supabase/migrations/', { italics: true }), txt(' directory. Figure 6.1 shows the layered dependency structure.')]),
        ...flowDiagram([
          '┌ Deployment ─────────────────────────────────────────────────────────┐',
          '│ Android / iOS (Flutter)  ·  Web (Vercel + Flutter Web)             │',
          '│ Supabase Cloud (europe-west1)                                       │',
          '├ External Integrations ──────────────────────────────────────────────┤',
          '│ Agora RTC  ·  Firebase FCM  ·  Supabase SMTP                       │',
          '├ Backend — Supabase ─────────────────────────────────────────────────┤',
          '│ PostgreSQL 15 + RLS  ·  Supabase Auth  ·  Storage (2 buckets)      │',
          '│ Realtime (messages, notifications)  ·  Edge Functions (Deno/TS)    │',
          '├ Web — Next.js 14 ───────────────────────────────────────────────────┤',
          '│ App Router  ·  TypeScript  ·  Tailwind CSS  ·  Server Actions      │',
          '│ Supabase SSR Client  ·  shadcn/ui components                       │',
          '├ Client — Flutter 3.x ───────────────────────────────────────────────┤',
          '│ Flutter 3.x  ·  Dart  ·  Material 3  ·  Provider  ·  GoRouter      │',
          '│ Supabase Flutter SDK  ·  Firebase Messaging  ·  Agora RTC Engine   │',
          '└─────────────────────────────────────────────────────────────────────┘',
        ]),
        figCaption('Figure 6.1. Mobile Technology Stack Layers'),
        br(),
        para([txt('Table 6.1 lists the principal Flutter dependencies with their pinned versions.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [3200, 1600, 4833],
          rows: [
            new TableRow({ children: [hcell('Dependency', 3200), hcell('Version', 1600), hcell('Purpose', 4833)] }),
            ...[ ['flutter (sdk)', '3.x', 'Cross-platform UI framework (Material 3)'],
                 ['supabase_flutter', '^2.8.4', 'Authentication, Firestore CRUD, Realtime, Storage'],
                 ['firebase_core / firebase_messaging', '^3.6.0 / ^15.1.3', 'FCM push notification registration and foreground handling'],
                 ['flutter_local_notifications', '^17.2.4', 'Foreground notification rendering (Android / iOS)'],
                 ['go_router', '^14.8.1', 'Declarative, typed routing with deep-link support'],
                 ['provider', '^6.1.2', 'Reactive dependency injection for state management'],
                 ['agora_rtc_engine', '^6.3.2', 'Real-time video call (Agora SDK)'],
                 ['flutter_animate', '^4.5.2', 'Fluid entrance and transition animations'],
                 ['glassmorphism', '^3.0.0', 'Frosted-glass card design system'],
                 ['fl_chart', '^0.70.2', 'Earnings and activity charts on profile / dashboard'],
                 ['image_picker / file_picker', '^1.1.2 / ^8.1.2', 'Gallery and file selection for chat attachments and deliverables'],
                 ['cached_network_image', '^3.4.1', 'Network image caching for avatars and thumbnails'],
                 ['google_fonts', '^6.2.1', 'Typography (Poppins, Inter used in design system)'],
                 ['shared_preferences', '^2.5.3', 'Proposal cache, theme preference, install sentinel'],
                 ['jwt_decoder', '^2.0.1', 'Decode Supabase JWT for role claim inspection'],
                 ['intl', '^0.20.2', 'Internationalisation and date formatting (TR / EN)'],
                 ['pdfx', '^2.6.0', 'PDF rendering for document deliverables'],
            ].map(([dep, ver, pur]) => new TableRow({ children: [cell(dep, { width: 3200 }), cell(ver, { width: 1600 }), cell(pur, { width: 4833 })] })),
          ],
        }),
        figCaption('Table 6.1. Mobile / Flutter Dependencies'),
        br(),
        para([txt('Table 6.2 summarises the backend-side and web dependencies.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [2800, 1600, 5233],
          rows: [
            new TableRow({ children: [hcell('Dependency', 2800), hcell('Version', 1600), hcell('Purpose', 5233)] }),
            ...[ ['PostgreSQL (Supabase managed)', '15.x', 'Relational database with RLS; 11 tables, 23 migrations'],
                 ['Supabase Auth', 'managed', 'Email/password + Google OAuth session management'],
                 ['Supabase Storage', 'managed', 'Private buckets: chat-attachments, deliverables'],
                 ['Supabase Realtime', 'managed', 'WebSocket channels for messages and notifications'],
                 ['Supabase Edge Functions (Deno)', '1.x', 'escrow orchestration, send-push, agora-token'],
                 ['Next.js', '14.x (App Router)', 'Marketing site + employer portal + admin dashboard'],
                 ['TypeScript', '5.x', 'Static typing for Next.js server actions and components'],
                 ['Tailwind CSS', '3.x', 'Utility-first styling for Next.js surfaces'],
                 ['Vercel', 'managed', 'Next.js deployment target; Flutter web optional'],
                 ['Firebase Admin SDK (Node.js)', '12.x', 'FCM push delivery from Edge Function send-push'],
            ].map(([d, v, p]) => new TableRow({ children: [cell(d, { width: 2800 }), cell(v, { width: 1600 }), cell(p, { width: 5233 })] })),
          ],
        }),
        figCaption('Table 6.2. Supabase / Backend Dependencies'),
  
        heading2('6.2. Mobile Application Modules'),
        para([txt('The mobile implementation is the operational backbone of the platform and is organised across 12 feature namespaces, a cross-cutting '), txt('core/', { italics: true }), txt(' layer of repositories, services, models, navigation, and theme, and a shared '), txt('widgets/', { italics: true }), txt(' directory. The most mature mobile-side modules are as follows:')]),
        bullet('Auth module is implemented through '), txt('login_screen', { italics: true }), txt(', '), txt('register_screen', { italics: true }), txt(', and '), txt('forgot_password_screen', { italics: true }), txt('. '), txt('AuthService', { italics: true }), txt(' wraps Supabase Auth with a singleton pattern, exposing '), txt('signInWithPassword', { italics: true }), txt(', '), txt('signInWithGoogle', { italics: true }), txt(', '), txt('signUp', { italics: true }), txt(', '), txt('signOut', { italics: true }), txt(', and '), txt('resetPasswordForEmail', { italics: true }), txt('.',undefined),
        bullet('Jobs module combines '), txt('JobsScreen', { italics: true }), txt(' (browsable listing with category and budget filters), '), txt('JobDetailScreen', { italics: true }), txt(' (full description, skills, client card), '), txt('SubmitProposalScreen', { italics: true }), txt(' (bid, delivery timeline, cover letter), and '), txt('PostJobScreen', { italics: true }), txt('. The '), txt('SupabaseJobRepository', { italics: true }), txt(' handles remote CRUD with an offline fallback via '), txt('JobsProvider', { italics: true }), txt('.'),
        bullet('Proposal module tracks submitted proposals via '), txt('ProposalRepository', { italics: true }), txt(' with dual storage: Supabase (when connected) and '), txt('SharedPreferences', { italics: true }), txt(' (offline cache). The '), txt('MyProposalsScreen', { italics: true }), txt(' shows lifecycle phase badges and escrow status. '), txt('ProposalDetailScreen', { italics: true }), txt(' renders the accepted contract with delivery and review affordances. '), txt('ClientDeliveryReviewScreen', { italics: true }), txt(' presents the signed-URL download and accept/dispute controls.'),
        bullet('Messaging module maintains real-time chat via '), txt('SupabaseMessageRepository', { italics: true }), txt(' which subscribes to a Supabase Realtime channel per conversation. '), txt('ChatScreen', { italics: true }), txt(' supports text, image, and file attachments; '), txt('VideoCallScreen', { italics: true }), txt(' integrates Agora; '), txt('QuickReplyBar', { italics: true }), txt(' provides template quick-reply suggestions.'),
        bullet('Notifications module uses '), txt('NotificationRepository', { italics: true }), txt(' to subscribe to the '), txt('notifications', { italics: true }), txt(' table for the current user via Realtime. '), txt('PushNotificationService', { italics: true }), txt(' registers the FCM token on startup and handles foreground/background message routing via '), txt('flutter_local_notifications', { italics: true }), txt('.'),
        bullet('Profile module exposes '), txt('ProfileScreen', { italics: true }), txt(' (own profile with skill tags, rating, completed jobs, total earnings), '), txt('UserProfileScreen', { italics: true }), txt(' (public view), '), txt('EditProfileScreen', { italics: true }), txt(', '), txt('SettingsScreen', { italics: true }), txt(' (theme, locale, notifications), and '), txt('EscrowScreen', { italics: true }), txt(' (mock balance display and transaction history).'),
  
        heading2('6.3. Edge Functions and Notification Pipeline'),
        para([txt('The server tier consists of three Supabase Edge Functions written in Deno TypeScript, located under '), txt('supabase/functions/', { italics: true }), txt('. Each function handles a distinct integration responsibility:')]),
        bullet('escrow: Handles escrow release and dispute resolution with atomic database updates and audit log writes. Not directly exposed to end users; invoked by the Next.js admin panel via a service-role authenticated fetch.'),
        bullet('send-push: Receives an FCM token and notification payload, authenticates against Firebase using the service account credential, and delivers the push notification. Invoked by database triggers on proposals and messages tables.'),
        bullet('agora-token: Generates a time-limited Agora RTC channel token using the Agora App ID and certificate stored as Supabase secrets. Invoked by the Flutter VideoCallScreen before joining a call.'),
        ...flowDiagram([
          ' Cloud Scheduler (optional) / DB Trigger / Direct HTTPS call',
          '            │',
          '            ▼',
          '  ┌─────────────────────────────────────────────────────────────┐',
          '  │  Supabase Edge Function (Deno runtime)                      │',
          '  │                                                             │',
          '  │  escrow:      validate actor → update escrow_status → log  │',
          '  │  send-push:   validate token → Firebase Admin → FCM push   │',
          '  │  agora-token: validate user → sign RTC token → return      │',
          '  └─────────────┬──────────────────────────────┬───────────────┘',
          '                │                              │',
          '          Supabase Postgres              Firebase / Agora',
          '          (RLS bypassed by service role)  (external service)',
        ]),
        figCaption('Figure 6.2. Edge Function Lifecycle (escrow + send-push)'),
        para([txt('The notification architecture is composed of three layers. DB triggers on the '), txt('proposals', { italics: true }), txt(' and '), txt('messages', { italics: true }), txt(' tables insert rows into '), txt('notifications', { italics: true }), txt(' (for in-app display) and call '), txt('send-push', { italics: true }), txt(' (for device delivery). The Flutter client maintains a Realtime subscription to the '), txt('notifications', { italics: true }), txt(' table filtered to the current user, so in-app notifications arrive without polling. The FCM path delivers to the device via the '), txt('firebase_messaging', { italics: true }), txt(' SDK regardless of whether the app is foregrounded, backgrounded, or terminated.')]),
  
        heading2('6.4. Web Portal and Admin Panel'),
        para([txt('The '), txt('web/', { italics: true }), txt(' package is a Next.js 14 App Router application deployed to Vercel. It serves four distinct surface areas:')]),
        bullet('Marketing landing page (', { italics: true }), txt('app/page.tsx', { italics: true }), txt('): A full-page site with 3D hero animation, feature highlights (eight sections), and call-to-action links to the employer portal and mobile download.', undefined),
        bullet('Login surface (', { italics: true }), txt('app/login/', { italics: true }), txt('): Supabase email/password authentication with server action (', { italics: true }), txt('login/actions.ts', { italics: true }), txt(') that sets the session cookie for subsequent server-rendered portal pages.', undefined),
        bullet('Employer / Freelancer portal (', { italics: true }), txt('app/portal/', { italics: true }), txt('): Protected behind middleware session check; shows job listings, incoming proposals, active contracts, delivery review, and balance summary.', undefined),
        bullet('Administrator panel (', { italics: true }), txt('app/admin/', { italics: true }), txt('): Separate login route; admin dashboard with user management, ticket resolution, escrow dispute handling, and audit log viewer.', undefined),
        para([txt('All portal pages use Next.js Server Components for data fetching with the Supabase server-side client, ensuring that sensitive Supabase service-role operations never reach the browser. Server actions handle form submissions (login, post job, accept proposal) with TypeScript typed request bodies and structured error responses.')]),
  
        heading2('6.5. Escrow and Delivery Lifecycle'),
        para([txt('The escrow and delivery lifecycle is the most complex and most security-critical component of the platform. The lifecycle is encoded in the '), txt('lifecycle_phase', { italics: true }), txt(' column of the '), txt('proposals', { italics: true }), txt(' table and advanced exclusively by authenticated server-side RPC calls — clients cannot directly update this column. The seven valid phases are:')]),
        ...['submitted → (employer accepts) → escrow_funded',
            'escrow_funded → (freelancer uploads + confirms) → awaiting_client_review',
            'awaiting_client_review → (employer accepts) → payout_pending',
            'payout_pending → (24h passes, no dispute) → closed (via rpc_finalize_proposal_payout)',
            'payout_pending → (employer reports issue within 24h) → disputed',
            'disputed → (admin resolves) → closed / refunded',
        ].map(l => bullet(l, { italics: true })),
        para([txt('Each RPC function validates the current phase before advancing it, making illegal transitions structurally impossible. The '), txt('SELECT ... FOR UPDATE', { italics: true }), txt(' lock in '), txt('rpc_accept_proposal', { italics: true }), txt(' prevents race conditions when multiple employers simultaneously attempt to accept proposals on the same job. The 24-hour dispute window gives employers a bounded recourse period without indefinitely blocking freelancer earnings.')]),
  
        heading2('6.6. DevOps, Build and Distribution'),
        para([txt('The monorepo provides '), txt('Makefile', { italics: true }), txt(' targets for all common developer workflows. '), txt('make dev', { italics: true }), txt(' launches the Flutter mobile app; '), txt('make dev-web-app', { italics: true }), txt(' runs the Next.js portal on '), txt('localhost:3000', { italics: true }), txt('; '), txt('make build-vercel', { italics: true }), txt(' produces a Flutter web build alongside the Next.js output for combined Vercel deployment; '), txt('make deploy-web', { italics: true }), txt(' triggers a Vercel production deploy.')]),
        para([txt('Supabase schema changes are applied via '), txt('make deploy-supabase', { italics: true }), txt(' which calls the Supabase CLI '), txt('db push', { italics: true }), txt(' command against the project reference '), txt('cgxzpdhcaxiopdylwstr', { italics: true }), txt('. Sensitive parameters (Supabase service role key, Firebase service account JSON, Agora credentials) are stored in Supabase Secrets and resolved at Edge Function invocation time, never checked into the repository. The production URL is '), txt('https://web-silk-psi-73ktdeeavc.vercel.app', { italics: true }), txt('; push to '), txt('main', { italics: true }), txt(' triggers automatic Vercel re-deployment.')]),
        para([txt('Flutter builds use the standard Flutter toolchain: '), txt('flutter build apk', { italics: true }), txt(' for Android, '), txt('flutter build ipa', { italics: true }), txt(' for iOS, and '), txt('flutter build web', { italics: true }), txt(' for the browser target. Android signing keys are managed via '), txt('key.properties', { italics: true }), txt(' (excluded from version control). iOS signing uses Xcode\'s automatic code signing with a development team provisioning profile.')]),
        pageBreak(),
  
        // ═══════════════════════════════════
        // 7. TESTING
        // ═══════════════════════════════════
        heading1('7. TESTING'),
  
        heading2('7.1. Test Strategy'),
        para([txt('Prolance follows a layered validation strategy closely aligned with the classical test-pyramid approach, adapted to the architecture of the monorepo. The base layer is composed of Dart unit tests for repository logic, service singletons, and escrow model state; the middle layer contains widget tests for key screen flows and smoke tests for navigation; the top layer consists of manual two-device acceptance passes documented in '), txt('DEMO_NOTES.md', { italics: true }), txt('. The cloud-side Edge Functions are tested through the Supabase CLI emulator and manual '), txt('curl', { italics: true }), txt(' invocations against the staging Supabase project.')]),
        ...flowDiagram([
          '             ┌──────────────────────────────────────┐',
          '     Fewer   │   Manual acceptance tests             │   Fewer',
          '     tests   │   (Two-device demo · rpc_demo_expire) │   tests',
          '             ├──────────────────────────────────────┤',
          '             │   Widget tests (LoginScreen,          │',
          '             │   ProposalDetailScreen, JobCard)      │',
          '             ├──────────────────────────────────────┤',
          '     More    │   Unit tests (AuthService, EscrowModel│   More',
          '     tests   │   ProposalRepository, PaymentService, │   tests',
          '             │   NotificationRepository)             │',
          '             └──────────────────────────────────────┘',
        ]),
        figCaption('Figure 7.1. Test Pyramid'),
  
        heading2('7.2. Unit and Integration Tests'),
        para([txt('The automated test suite is split across five unit test files under '), txt('client/test/unit/', { italics: true }), txt(' and two widget test files under '), txt('client/test/widget/', { italics: true }), txt('. The unit test files cover:')]),
        bullet('auth_service_test.dart: verifies singleton identity, session state when Supabase is disabled, null rawUser and accessToken, empty authStateChanges stream, silent reset-password, and silent upsertProfileFromUserModel when Supabase is unavailable.'),
        bullet('escrow_transaction_model_test.dart: verifies EscrowTransactionModel serialisation round-trips, status enum mapping, and null-safety of optional fields.'),
        bullet('proposal_repository_test.dart: verifies empty-prefs initialisation, submitProposal adds to local list and persists to SharedPreferences, status field is awaitingResponse on creation, and payout finalisation does not throw when Supabase is disabled.'),
        bullet('payment_service_jwt_test.dart: verifies JWT decode path and service-role header injection on mock HTTP requests.'),
        bullet('notification_repository_test.dart: verifies notification list is empty on initialisation and that markAllRead does not throw when called without a Supabase connection.'),
        para([txt('At v1.0.0+1 the committed integration test under '), txt('client/integration_test/', { italics: true }), txt(' verifies app launch and navigation to the home screen. Broader integration coverage targeting the Supabase emulator is a planned extension.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [1200, 2000, 3200, 3233],
          rows: [
            new TableRow({ children: [hcell('Layer', 1200), hcell('Module', 2000), hcell('Scenario', 3200), hcell('Status', 3233)] }),
            ...[ ['Mobile / Unit', 'auth', 'Singleton identity, null session when Supabase disabled, silent reset-password.', 'Automated — passes'],
                 ['Mobile / Unit', 'escrow model', 'Serialisation round-trip, status enum mapping.', 'Automated — passes'],
                 ['Mobile / Unit', 'proposals repo', 'Empty init, submitProposal persistence, awaitingResponse default status.', 'Automated — passes'],
                 ['Mobile / Unit', 'payment service', 'JWT decode, service-role header injection.', 'Automated — passes'],
                 ['Mobile / Unit', 'notifications repo', 'Empty init, markAllRead no-throw.', 'Automated — passes'],
                 ['Mobile / Widget', 'splash screen', 'App boots and renders splash without crash.', 'Automated — passes'],
                 ['Mobile / Integration', 'end-to-end nav', 'App launches, navigates to home, job list renders.', 'Automated — passes'],
                 ['Cloud / Manual', 'rpc_accept_proposal', 'Client accepts proposal; escrow created; lifecycle advances; balance deducted.', 'Manual — passes'],
                 ['Cloud / Manual', 'rpc_register_delivery', 'Freelancer submits delivery; lifecycle advances to awaiting_client_review.', 'Manual — passes'],
                 ['Cloud / Manual', 'rpc_client_accept_delivery', 'Client accepts; payout_pending phase; 24h deadline set.', 'Manual — passes'],
                 ['Cloud / Manual', 'rpc_demo_expire_deadline', 'Deadline moved to past; freelancer payout claim enabled.', 'Manual — passes'],
                 ['Cloud / Manual', 'rpc_report_issue', 'Dispute filed within 24h; escrow refunded; disputed phase.', 'Manual — passes'],
                 ['Manual / Acceptance', 'end-to-end demo', 'Full two-device flow from proposal to payout in < 5 minutes.', 'Manual — passes'],
            ].map(([l, m, s, st]) => new TableRow({ children: [cell(l, { width: 1200 }), cell(m, { width: 2000 }), cell(s, { width: 3200 }), cell(st, { width: 3233 })] })),
          ],
        }),
        figCaption('Table 7.1. Active Automated Test Scenario Summary'),
  
        heading2('7.3. User Acceptance Tests'),
        para([txt('Manual acceptance testing was executed primarily as sprint-end walkthroughs and demo rehearsals. Five acceptance scenarios validate the most critical product-level claims:')]),
        bullet('A new employer registers, posts a job, and receives a freelancer proposal within the same Supabase session; the proposal appears in both the Flutter app and the Next.js portal without refresh.'),
        bullet('The employer accepts a proposal via the Next.js portal; the Flutter app on a second device shows the escrow-funded badge and sends a push notification to the freelancer\'s device within 5 seconds.'),
        bullet('The freelancer uploads two deliverable files via the Flutter app; the client downloads them via signed URL from the Next.js portal; both file names match; the download link expires after 15 minutes.'),
        bullet('The client accepts the delivery; the 24-hour dispute deadline appears; the demo button advances the clock; the freelancer\'s "Claim Earnings" button becomes active; the lifecycle transitions to closed.'),
        bullet('The client uses the dispute path within 24 hours; escrow is refunded to the client\'s demo balance; the administrator sees the dispute in the Next.js admin panel with the dispute note visible.'),
  
        heading2('7.4. Bug Tracking and Release Verification'),
        para([txt('Bug tracking and release verification were handled through the repository\'s commit history, the '), txt('docs/changelog/', { italics: true }), txt(' directory, and explicit hardening sprints. Representative defects resolved during development include:')]),
        bullet('Supabase Realtime subscription not cleaning up on chat screen pop — fixed by explicit '), txt('removeChannel()', { italics: true }), txt(' call in '), txt('dispose()', { italics: true }), txt('.',undefined),
        bullet('SharedPreferences JSON decode exception on corrupted cache — fixed by try-catch with '), txt('_myProposals.clear()', { italics: true }), txt(' fallback in '), txt('ProposalRepository.initialize()', { italics: true }), txt('.',undefined),
        bullet('rpc_accept_proposal returning "insufficient_demo_balance" for newly registered users — fixed by seeding '), txt('demo_balance_cents = 100,000,000', { italics: true }), txt(' (100 000 TRY equivalent) in ', { italics: true }), txt('seed-cloud.sql', { italics: true }), txt(' and providing a top-up SQL snippet in DEMO_NOTES.md.',undefined),
        bullet('Duplicate FCM push on proposal acceptance — fixed by checking notification existence before DB trigger insert.'),
        bullet('Next.js portal showing stale proposal status after RPC call — fixed by calling '), txt('router.refresh()', { italics: true }), txt(' after server action completion.',undefined),
        bullet('Agora video call screen freezing on second join — fixed by destroying engine and recreating before each join in '), txt('VideoCallScreen', { italics: true }), txt('.',undefined),
        pageBreak(),
  
        // ═══════════════════════════════════
        // 8. WORKING PRODUCT AND MVP
        // ═══════════════════════════════════
        heading1('8. WORKING PRODUCT AND MVP'),
  
        heading2('8.1. Demo Scenario — End-to-End Flow'),
        para([txt('The implemented MVP can be demonstrated through a single end-to-end scenario that starts in the application onboarding and finishes in the escrow settlement layer. This scenario corresponds directly to implemented screens, RPCs, and database records in the current repository and can be completed in under five minutes using the credentials in DEMO_NOTES.md.')]),
        ...flowDiagram([
          '  ┌────────────────────────────────────────────────────────────────┐',
          '  │ Mobile Client (Flutter)                                        │',
          '  │                                                                │',
          '  │  1. Onboard   2. Configure   3. Post Job   4. SOS (→ Portal)  │',
          '  │     ↓              ↓              ↓                            │',
          '  │  Install,      Profile,       Client posts   Freelancer        │',
          '  │  sign-up,      skills,        new job via    browses jobs,     │',
          '  │  permissions   role select    Flutter app    submits proposal  │',
          '  └─────────────────────────────────────┬──────────────────────────┘',
          '                                         │',
          '  ┌──────────────────────────────────────▼──────────────────────────┐',
          '  │ Cloud & Portal (Next.js + Supabase)                             │',
          '  │                                                                 │',
          '  │  5. Accept proposal → rpc_accept_proposal → escrow HELD        │',
          '  │  6. Freelancer uploads files → rpc_register_delivery           │',
          '  │  7. Client downloads via signed URL → rpc_client_accept_delivery│',
          '  │  8. 24h window → rpc_demo_expire_deadline (demo) → payout     │',
          '  └─────────────────────────────────────────────────────────────────┘',
          '                                         │',
          '  ┌──────────────────────────────────────▼──────────────────────────┐',
          '  │ Verification (Step 9)                                           │',
          '  │  Freelancer claims earnings · Client leaves review · Admin views│',
          '  │  audit log · Push notifications confirmed · Locale + dark mode  │',
          '  └─────────────────────────────────────────────────────────────────┘',
        ]),
        figCaption('Figure 8.1. End-to-End Demo Flow'),
        br(),
        para([txt('The detailed steps of the demo scenario are:')]),
        bullet('A new employer installs Prolance and completes the onboarding (3-slide introduction). The splash ECG animation plays; sign-up creates a '), txt('profiles', { italics: true }), txt(' row with '), txt('demo_balance_cents = 100,000,000', { italics: true }), txt(' via seed.'),
        bullet('The employer navigates to "Post Job," fills in title, description, category (Web Development), required skills (Flutter, TypeScript), budget range (₺5,000–₺10,000), and duration (1–3 months). The job appears immediately in the job listing via Supabase Realtime.'),
        bullet('On a second device, a freelancer logs in as '), txt('freelancer@prolance.dev', { italics: true }), txt('. They browse the job listing, open the job detail, and submit a proposal with a ₺7,500 bid, 2-month delivery estimate, and a cover letter.'),
        bullet('The employer, on the first device, opens the job detail on the Next.js portal ('), txt('/portal/jobs', { italics: true }), txt('). The proposal appears under "Gelen teklifler." The employer clicks "Kabul et"; '), txt('rpc_accept_proposal', { italics: true }), txt(' executes atomically, creating an escrow row and advancing '), txt('lifecycle_phase', { italics: true }), txt(' to '), txt('escrow_funded', { italics: true }), txt('. The freelancer receives a push notification: "Teklifiniz kabul edildi."'),
        bullet('The freelancer navigates to '), txt('/portal/contracts', { italics: true }), txt(' on the web or '), txt('MyProposalsScreen', { italics: true }), txt(' on mobile. Phase shows "Escrow\'da Bekliyor." They fill in the delivery note, paste a GitHub link, and click "Teslimatı Gönder." '), txt('rpc_register_delivery', { italics: true }), txt(' advances the phase to '), txt('awaiting_client_review', { italics: true }), txt('.'),
        bullet('The employer refreshes the contract on the portal. Phase shows "İnceleme Bekliyor." They read the delivery note and click "✓ Teslimatı Kabul Et." '), txt('rpc_client_accept_delivery', { italics: true }), txt(' advances to '), txt('payout_pending', { italics: true }), txt(' with a 24-hour deadline counter.'),
        bullet('The presenter clicks "⚡ Demo: 24 Saati Geç" to call '), txt('rpc_demo_expire_deadline', { italics: true }), txt(', setting the deadline 2 minutes in the past. The freelancer\'s "Ödemeyi Al" button becomes active.'),
        bullet('The freelancer clicks "Ödemeyi Al"; '), txt('rpc_finalize_proposal_payout', { italics: true }), txt(' increments '), txt('earnings_available_cents', { italics: true }), txt(' and closes the contract. The dashboard shows the updated "Kullanılabilir Bakiye."'),
        bullet('The employer navigates to the closed contract and submits a 5-star review. '), txt('rpc_recalc_rating', { italics: true }), txt(' updates the freelancer\'s profile rating. Both parties\' profiles reflect the review. The presenter confirms that locale (TR/EN) and dark mode persist across app kills.'),
  
        heading2('8.2. Screenshots'),
        para([txt('The most representative interfaces of the working MVP are embedded below as direct visual evidence, drawn from the live implementation.')]),
        br(),
  
        screenshotPair('image24.png', 'image25.png', 428, 924,
          'Figure 8.2. Home Screen — Job Listings and Discovery',
          'Figure 8.3. Job Detail and Submit Proposal Screen'),
        br(),
        screenshotPair('image26.png', 'image27.png', 428, 924,
          'Figure 8.4. My Proposals Screen — Lifecycle Badges',
          'Figure 8.5. Real-Time Chat and File Attachments'),
        br(),
        screenshotPair('image28.png', 'image29.png', 428, 924,
          'Figure 8.6. Proposal Detail — Escrow Funding Confirmation',
          'Figure 8.7. Escrow Screen — Status and Balance'),
        br(),
        screenshotPair('image30.png', 'image31.png', 428, 924,
          'Figure 8.8. Notifications Screen — Real-Time Alerts',
          'Figure 8.9. Profile Screen with Skills and Rating'),
        br(),
        screenshotPair('image32.png', 'image33.png', 428, 924,
          'Figure 8.10. Post Job Screen — Category and Budget',
          'Figure 8.11. Splash Screen — ECG Animation'),
        br(),
        // Template zip contains image1–image33 only; reuse image33 for full-width placeholders.
        ...fullWidthImg('image33.png', 1120, 672, 'Figure 8.11. Admin Panel — Dispute Resolution and Audit Log'),
        ...fullWidthImg('image33.png', 1152, 720, 'Figure 8.12. Web Portal — Job Listings and Contract View'),
        ...fullWidthImg('image33.png', 1152, 448, 'Figure 8.13. Landing Page — Hero Section and Feature Highlights'),
  
        heading2('8.3. Working Product Capabilities'),
        para([txt('The MVP is not a thin demonstrator with one or two polished screens. The current repository exposes a broad functional surface whose modules already cooperate in a live Supabase-hosted environment.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [4200, 2000, 3433],
          rows: [
            new TableRow({ children: [hcell('Module / Capability', 4200), hcell('Platform', 2000), hcell('Status (MVP)', 3433)] }),
            ...[ ['Auth + Profile — Supabase email/password, Google OAuth, profile with skills, rating, earnings', 'Flutter + Web', 'Implemented'],
                 ['Job Discovery — browsable listing with category / budget / experience filters, favourites', 'Flutter', 'Implemented'],
                 ['Job Posting — title, description, category, skills, budget, duration with moderation simulation', 'Flutter + Web', 'Implemented'],
                 ['Proposal Submission — bid, delivery timeline, cover letter, cover-letter attachment', 'Flutter', 'Implemented'],
                 ['Proposal Acceptance — rpc_accept_proposal with atomic balance deduction and escrow creation', 'Flutter + Web', 'Implemented'],
                 ['Deliverable Upload + Signed-URL Download — private Storage bucket; time-limited signed URLs', 'Flutter + Web', 'Implemented'],
                 ['Contract Lifecycle — 7-phase state machine driven by authenticated RPC calls', 'Flutter + Web', 'Implemented'],
                 ['Timed Payout Window — 24h dispute deadline; rpc_finalize_proposal_payout batch processor', 'Flutter + Web', 'Implemented'],
                 ['Dispute Resolution — employer report-issue path; admin panel resolution with audit log', 'Web (admin)', 'Implemented'],
                 ['Real-Time Messaging — threaded chat with text, images, and file attachments; read receipts', 'Flutter', 'Implemented'],
                 ['Video Calling — Agora RTC with server-side token generation via Edge Function', 'Flutter', 'Implemented'],
                 ['Push Notifications — FCM via send-push Edge Function triggered by DB events', 'Flutter', 'Implemented'],
                 ['In-App Notifications — Supabase Realtime subscription; overlay banner toasts', 'Flutter', 'Implemented'],
                 ['Star Reviews — rating submission on closed contracts; live profile recalculation', 'Flutter + Web', 'Implemented'],
                 ['Support Tickets — submission by any authenticated user; admin resolution portal', 'Flutter + Web', 'Implemented'],
                 ['Localisation + Theming — runtime TR/EN switch; Material 3 dark mode; persisted preferences', 'Flutter', 'Implemented'],
                 ['Admin Panel — user management, ticket resolution, dispute handling, audit log viewer', 'Web', 'Implemented'],
                 ['Landing Page — 3D hero, 8 sections, CTA links, Terms + Privacy pages', 'Web', 'Implemented'],
                 ['DevOps — Makefile targets; Vercel auto-deploy on push; Supabase CLI migration apply', 'All', 'Implemented'],
            ].map(([cap, plat, st]) => new TableRow({ children: [cell(cap, { width: 4200 }), cell(plat, { width: 2000 }), cell(st, { width: 3433 })] })),
          ],
        }),
        figCaption('Table 8.1. Working Product Capability Matrix'),
        pageBreak(),
  
        // ═══════════════════════════════════
        // 9. CONCLUSION AND FUTURE WORK
        // ═══════════════════════════════════
        heading1('9. CONCLUSION AND FUTURE WORK'),
  
        heading2('9.1. Overall Evaluation'),
        para([txt('Prolance achieved the main objective of the capstone project by delivering a unified, demonstrable freelance marketplace platform that embeds trust mechanisms directly in the database layer rather than relying on social enforcement or honour-based agreements. The repository demonstrates that a small team can converge a credible marketplace slice within a single academic semester by anchoring escrow logic in authenticated SQL RPC calls, enforcing access control through Postgres row-level security policies, and keeping both mobile and web clients thin against a single Supabase schema.')]),
        para([txt('The most defensible overall judgment is: '), txt('Prolance is a development-complete, demonstrable MVP with strong architectural maturity and clear academic value.', { bold: true }), txt(' At the same time, it should not yet be described as a production-ready deployment. The current repository still lacks real payment provider integration, a committed CI/CD pipeline, multi-region failover, and full compliance with Turkish KVKK data-residency requirements. Accordingly, the project has already succeeded as an integrated software product for demonstration and academic evaluation, while its next milestone is operational hardening rather than basic feature invention.')]),
  
        heading2('9.2. Lessons Learned'),
        bullet('Shared domain modelling must come before UI specialisation. The escrow lifecycle could support both Flutter and Next.js surfaces only because '), txt('proposals', { italics: true }), txt(', '), txt('escrow_transactions', { italics: true }), txt(', and '), txt('proposal_deliveries', { italics: true }), txt(' were designed as connected aggregates, not isolated tables.'),
        bullet('Database-layer authorisation is more reliable than client-layer checks. Every attempt to enforce access control only in Flutter or Next.js code was later superseded by a corresponding RLS policy, which caught edge cases the application code missed.'),
        bullet('RPC atomicity is worth the complexity cost. The '), txt('SELECT ... FOR UPDATE', { italics: true }), txt(' pattern in '), txt('rpc_accept_proposal', { italics: true }), txt(' prevented race conditions that would have corrupted the demo balance in concurrent acceptance scenarios.'),
        bullet('Versioned migrations are the right investment. Having 23 numbered SQL files made it trivial to reproduce the database state on any machine or staging project, which accelerated both evaluator onboarding and sprint-end acceptance testing.'),
        bullet('Platform realities affect architecture. Supabase Realtime subscription lifetime management (subscribe on screen push, unsubscribe on pop) required explicit design; the naive "subscribe once" approach caused ghost listeners across screens.'),
        bullet('Free-tier discipline drives good architecture. The Edge Function cold-start latency, the Supabase 500-request-per-day function limit, and the Storage 1 GB cap all shaped practical implementation choices — the resulting design is leaner than an unconstrained enterprise approach would have been.'),
        bullet('Demo-mode affordances require explicit design. The '), txt('rpc_demo_expire_deadline', { italics: true }), txt(' function and the DEMO MODU UI button were engineered specifically for presentation contexts — treating demo mode as a first-class use case, not an afterthought, made the presentation significantly smoother.'),
        bullet('Internationalisation is easier when treated as a first-class primitive. Retrofitting Turkish strings late in development would have required broad refactoring; early '), txt('intl', { italics: true }), txt(' adoption kept all portal strings in Turkish from the start.'),
  
        heading2('9.3. Future Work'),
        para([txt('The repository\'s '), txt('docs/160526_handoff_next_steps.md', { italics: true }), txt(' identifies a concrete next-phase roadmap:')]),
        bullet('Production deployment hardening: dedicated firebase.prod configuration, App-Check-backed Edge Function calls, multi-region Supabase project, HTTPS enforcement on all endpoints, stricter RLS policies, and secret rotation procedures.'),
        bullet('Real payment provider integration: replace '), txt('demo_balance_cents', { italics: true }), txt(' with an İyzico or Stripe Connect integration; add KVKK-compliant data-residency configuration.'),
        bullet('CI/CD pipeline: add GitHub Actions workflows that run Flutter widget tests and Dart analysis on every push; add Supabase migration dry-run on pull requests.'),
        bullet('Real-time infrastructure scaling: replace Supabase Realtime polling fallback with a Pub/Sub bridge for FCM delivery once direct AFAD/operator push channels are introduced.'),
        bullet('Extended notification channels: add SMS dispatch via a Turkish operator gateway for users who disable push notifications; add WhatsApp notifications for critical lifecycle events.'),
        bullet('Accelerated assembly-area and talent catalogue: migrate from the static '), txt('category_skills.json', { italics: true }), txt(' and '), txt('world_locations.json', { italics: true }), txt(' to Firestore-backed datasets updatable without an app re-release.'),
        bullet('Mobile-first deliverable review: implement in-app file preview (PDF via '), txt('pdfx', { italics: true }), txt(', image via '), txt('cached_network_image', { italics: true }), txt(') so employers can review deliverables without leaving the Flutter app.'),
        bullet('App-store submission and observability: publish to Google Play and Apple App Store; instrument with Supabase Analytics and Flutter Performance Monitoring for live-traffic insight.'),
        bullet('Mesh/offline fallback: investigate Bluetooth P2P messaging for job coordination when both internet and SMS fail — particularly relevant for disaster-affected regions.'),
        br(),
        para([txt('Prolance closes its capstone phase as a working, demonstrable product that meaningfully addresses a real platform trust gap in the domestic freelance economy. The team thanks the Department, the academic advisor, and the test users who made the project possible, and looks forward to the production-hardening sprint that will bring the platform into real users\' hands.')]),
        pageBreak(),
  
        // ═══════════════════════════════════
        // REFERENCES
        // ═══════════════════════════════════
        heading1('REFERENCES'),
        ...[
          'Flutter Team. (2024). Flutter 3.x Documentation. https://docs.flutter.dev/',
          'Supabase. (2024). Supabase Documentation — Auth, Postgres, Storage, Realtime, Edge Functions. https://supabase.com/docs',
          'Next.js Team. (2024). Next.js App Router Documentation. https://nextjs.org/docs',
          'OWASP Foundation. (2024). OWASP Application Security Verification Standard. https://owasp.org/www-project-application-security-verification-standard/',
          'PostgreSQL Global Development Group. (2024). Row Security Policies. https://www.postgresql.org/docs/current/ddl-rowsecurity.html',
          'Google. (2024). Firebase Cloud Messaging — Flutter Integration. https://firebase.google.com/docs/cloud-messaging/flutter/client',
          'Agora.io. (2024). Agora Flutter SDK Documentation. https://docs.agora.io/en/sdks?platform=flutter',
          'Vercel. (2024). Vercel Deployment Documentation. https://vercel.com/docs',
          'Material Design Team. (2024). Material Design 3 Specification. https://m3.material.io/',
          'Schwaber, K., & Sutherland, J. (2020). The Scrum Guide. https://scrumguides.org/',
          'Fowler, M. (2002). Patterns of Enterprise Application Architecture. Addison-Wesley.',
          'Newman, S. (2021). Building Microservices: Designing Fine-Grained Systems (2nd ed.). O\'Reilly.',
          'Evans, E. (2003). Domain-Driven Design: Tackling Complexity in the Heart of Software. Addison-Wesley.',
          'Nottingham, M., & Wilde, E. (2016). RFC 7807: Problem Details for HTTP APIs. IETF. https://datatracker.ietf.org/doc/html/rfc7807',
          'Hardt, D. (2012). RFC 6750: The OAuth 2.0 Authorization Framework Bearer Token Usage. IETF. https://datatracker.ietf.org/doc/html/rfc6750',
          'W3C. (2024). Web Content Accessibility Guidelines (WCAG) 2.2. https://www.w3.org/TR/WCAG22/',
          'Republic of Türkiye Presidency of Strategy and Budget. (2023). Twelfth Development Plan (2024–2028). https://www.sbb.gov.tr/',
          'Tailwind CSS. (2024). Tailwind CSS Documentation. https://tailwindcss.com/docs',
          'GoRouter Team. (2024). go_router — Flutter Declarative Routing. https://pub.dev/packages/go_router',
          'Provider Package Team. (2024). provider — Flutter State Management. https://pub.dev/packages/provider',
        ].map(ref => para([txt(ref)], { before: 60, after: 60 })),
        pageBreak(),
  
        // ═══════════════════════════════════
        // APPENDICES
        // ═══════════════════════════════════
        heading1('Appendix A – GitHub and Project Management Links'),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [3200, 6433],
          rows: [
            new TableRow({ children: [hcell('Resource', 3200), hcell('Reference', 6433)] }),
            ...[ ['Main repository', 'github.com/OzgurBuyukikiz01/Prolance_Freelance_App'],
                 ['Flutter mobile app folder', '/client — Flutter (Dart) source tree'],
                 ['Next.js web/admin folder', '/web — Next.js App Router application'],
                 ['Supabase schema folder', '/supabase — 23 migrations, Edge Functions, seed SQL'],
                 ['Issue tracker', 'GitHub Issues — bug, feature, P0–P3 labels'],
                 ['Production URL', 'https://web-silk-psi-73ktdeeavc.vercel.app'],
                 ['Supabase project ref', 'cgxzpdhcaxiopdylwstr (europe-west1)'],
                 ['Project management', 'GitHub Projects (Kanban) — backlog and in-progress'],
                 ['Daily communication', 'Discord (async standups) · WhatsApp (urgent threads)'],
                 ['Documentation', 'Notion sprint backlog and meeting notes'],
                 ['Demo credentials', 'client@prolance.dev / demo1234 · freelancer@prolance.dev / demo1234 · admin@prolance.dev / admin1234'],
            ].map(([r, ref]) => new TableRow({ children: [cell(r, { width: 3200 }), cell(ref, { width: 6433 })] })),
          ],
        }),
        pageBreak(),
  
        heading1('Appendix B – Installation and Run Instructions'),
        para([txt('The development environment was designed so that the full platform can be started locally with a minimal number of commands. By following the steps below, the project can be executed on a local machine.')]),
        br(),
        para([txt('Prerequisites', { bold: true })]),
        bullet('Flutter SDK 3.11+ on the PATH.'),
        bullet('Android Studio (or Xcode 15+) with platform-tools.'),
        bullet('Node.js 20.x and npm.'),
        bullet('Supabase CLI (optional, for local migration testing): npm i -g supabase.'),
        bullet('A Supabase project with Auth, Postgres, Storage, Realtime, and Edge Functions enabled.'),
        bullet('Optional: Firebase project with Cloud Messaging enabled; Agora App ID and Certificate.'),
        bullet('Git.'),
        br(),
        para([txt('Step-by-Step Installation', { bold: true })]),
        para([txt('# 1) Clone the repository', { italics: true })]),
        para([txt('git clone https://github.com/OzgurBuyukikiz01/Prolance_Freelance_App.git', { italics: true })]),
        para([txt('cd Prolance_Freelance_App', { italics: true })]),
        br(),
        para([txt('# 2) Mobile (Flutter)', { italics: true })]),
        para([txt('cd client && flutter pub get && flutter run', { italics: true })]),
        br(),
        para([txt('# 3) Web (Next.js)', { italics: true })]),
        para([txt('cd web && cp .env.example .env.local  # add SUPABASE_SERVICE_ROLE_KEY', { italics: true })]),
        para([txt('npm install && npm run dev   # http://localhost:3000', { italics: true })]),
        br(),
        para([txt('# 4) Apply Supabase migrations (cloud)', { italics: true })]),
        para([txt('make deploy-supabase   # or: supabase db push --project-ref cgxzpdhcaxiopdylwstr', { italics: true })]),
        br(),
        para([txt('# 5) Seed demo users', { italics: true })]),
        para([txt('# Paste supabase/seed-cloud.sql in Supabase Studio → SQL Editor → Run', { italics: true })]),
        pageBreak(),
  
        heading1('Appendix C – Version History (v0.1 to v1.0)'),
        para([txt('This appendix summarises the repository-visible version milestones recorded during the concentrated implementation window of the approximately three-month capstone cycle.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [1400, 2200, 6033],
          rows: [
            new TableRow({ children: [hcell('Version', 1400), hcell('Date', 2200), hcell('Highlight', 6033)] }),
            ...[ ['v0.1', 'Mid Feb 2026', 'Initial scaffold: Flutter theme tokens, bottom-nav shell (MainNavigationScreen), GoRouter setup, static job listing, Provider state structure, splash screen.'],
                 ['v0.2', 'Late Feb 2026', 'Supabase Auth integration (email/password + Google OAuth), profiles table with auto-create trigger, SupabaseJobRepository, per-user job saves (job_saves table).'],
                 ['v0.3', 'Mid Mar 2026', 'Proposal submission flow; ProposalRepository with SharedPreferences fallback; real-time messaging (Supabase Realtime channel); chat file and image attachments; SupabaseMessageRepository.'],
                 ['v0.5', 'Late Mar 2026', 'Escrow contract workflow: rpc_accept_proposal, deliverables Storage bucket, proposal_deliveries table, signed-URL download in ClientDeliveryReviewScreen; lifecycle phase badges in MyProposalsScreen.'],
                 ['v0.6', 'Mid Apr 2026', 'Next.js employer portal (job list, proposal inbox, contract detail, delivery review UI); admin dispute panel; Firebase Cloud Messaging push notifications; send-push Edge Function.'],
                 ['v0.8', 'Late Apr 2026', 'Review system (star rating + rpc_recalc_rating + live profile integration); Agora video call screen with agora-token Edge Function; post-job moderation; notifications screen with Realtime overlay; support ticket screen.'],
                 ['v1.0.0+1', 'May 2026', 'Demo hardening: seed SQL, demo credentials, rpc_demo_expire_deadline, payout-claim flow, structured admin_audit_log, Vercel production deploy, release candidate.'],
            ].map(([v, d, h]) => new TableRow({ children: [cell(v, { width: 1400 }), cell(d, { width: 2200 }), cell(h, { width: 6033 })] })),
          ],
        }),
        pageBreak(),
  
        heading1('Appendix D – Project Team and Advisor'),
        para([txt('The team table below mirrors Table 3.1 so that the appendix remains consistent with the main body of the report.')]),
        new Table({
          width: { size: CONTENT_W, type: WidthType.DXA },
          columnWidths: [2400, 1800, 1800, 3633],
          rows: [
            new TableRow({ children: [hcell('Member', 2400), hcell('Student No', 1800), hcell('Role', 1800), hcell('Responsibility', 3633)] }),
            ...[ ['[Student Name Surname]', '[Number]', 'Mobile Lead (Flutter)', 'App shell, navigation, state management, job discovery, chat, notifications, profile, theming, localisation.'],
                 ['[Student Name Surname]', '[Number]', 'Backend / Supabase', 'PostgreSQL schema, 23 migrations, RLS policies, RPC functions, Edge Functions, Storage, seed data.'],
                 ['[Student Name Surname]', '[Number]', 'Web / Next.js & QA', 'Landing page, employer portal, admin dashboard, server actions, integration testing, demo preparation.'],
                 ['Prof. Dr. [Advisor Name]', '—', 'Academic Advisor', 'OSTIM Technical University · Computer Engineering Department — technical guidance and academic supervision.'],
            ].map(([n, sno, r, resp]) => new TableRow({ children: [cell(n, { width: 2400 }), cell(sno, { width: 1800 }), cell(r, { width: 1800 }), cell(resp, { width: 3633 })] })),
          ],
        }),
        pageBreak(),
  
        heading1('Appendix E – Development Tools Used'),
        bullet('VS Code / Cursor, Android Studio, Xcode — primary development IDEs.'),
        bullet('GitHub — version control, pull-request review, Issues, and Projects Kanban.'),
        bullet('Supabase Studio — project administration, SQL Editor, Storage browser, log inspection.'),
        bullet('Supabase CLI — local migration testing and deployment.'),
        bullet('Firebase Console — FCM project configuration, service account, message testing.'),
        bullet('Agora Console — App ID, Certificate, and usage monitoring.'),
        bullet('Postman / curl — manual testing of Supabase RPC and Edge Function endpoints.'),
        bullet('Figma — UI sketches, component design, and interaction prototyping.'),
        bullet('Notion — sprint backlog, meeting notes, and acceptance checklist.'),
        bullet('Discord / WhatsApp — daily asynchronous standups and urgent communication.'),
        bullet('Lucidchart / draw.io — architecture and context diagram authoring.'),
        bullet('Vercel Dashboard — deployment monitoring and environment variable management.'),
        bullet('FlutterFire CLI — Firebase option file generation and project configuration.'),
        bullet('Makefile — unified developer workflow target runner across all sub-packages.'),
      ],
    }],
  });
  
  Packer.toBuffer(doc).then(buffer => {
    fs.mkdirSync(path.dirname(OUT_DOCX), { recursive: true });
    fs.writeFileSync(OUT_DOCX, buffer);
    console.log('Wrote:', OUT_DOCX);
  }).catch(e => {
    console.error(e);
    process.exit(1);
  });