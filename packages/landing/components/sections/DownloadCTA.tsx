'use client';

import { motion } from 'framer-motion';

export default function DownloadCTA() {
  return (
    <section id="download" className="py-24 bg-gradient-to-br from-indigo-50 via-white to-violet-50">
      <div className="max-w-5xl mx-auto px-6 text-center">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="flex flex-col items-center gap-6"
        >
          <span className="inline-block bg-brand-light text-brand text-xs font-semibold px-3 py-1.5 rounded-full border border-brand/20">
            Ücretsiz İndir
          </span>
          <h2 className="text-3xl md:text-5xl font-extrabold text-slate-900 max-w-2xl leading-tight">
            Prolance&apos;ı bugün{' '}
            <span className="bg-gradient-to-r from-brand to-indigo-500 bg-clip-text text-transparent">
              indir, güvende çalış
            </span>
          </h2>
          <p className="text-slate-500 max-w-md text-base">
            iOS ve Android için ücretsiz. Kayıt olmak 30 saniye sürer.
          </p>

          {/* Buttons + QR */}
          <div className="flex flex-col sm:flex-row items-center gap-6 mt-4">
            {/* App Store */}
            <a
              href="#"
              className="flex items-center gap-3 bg-slate-900 hover:bg-slate-700 text-white px-6 py-4 rounded-2xl transition-colors shadow-lg min-w-[180px]"
            >
              <svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor">
                <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.7 9.05 7.4c1.29.08 2.21.75 3.01.75.79 0 2.27-.93 3.83-.79 1.5.12 2.91.73 3.72 1.96-3.44 2.05-2.87 6.56.44 7.96zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
              </svg>
              <div className="flex flex-col leading-none text-left">
                <span className="text-[10px] text-slate-300">Download on the</span>
                <span className="text-base font-semibold">App Store</span>
              </div>
            </a>

            {/* Google Play */}
            <a
              href="#"
              className="flex items-center gap-3 bg-white border-2 border-slate-200 hover:border-brand text-slate-800 px-6 py-4 rounded-2xl transition-all shadow-card min-w-[180px]"
            >
              <svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor" className="text-green-600">
                <path d="M3.18 23.76c.34.2.73.22 1.1.04l12.04-6.96-2.64-2.64-10.5 9.56zM20.62 9.38a2.1 2.1 0 0 0-.92-1.76L17.22 6.3l-2.94 2.94 2.94 2.94 2.42-1.4c.6-.34.98-.97.98-1.4zM1.24.34C1.04.58.92.93.92 1.35v21.3c0 .42.12.77.32 1.01l.06.06 11.94-11.94v-.28L1.3.28zM14.28 8.28L3.18.34l10.5 9.58 2.64-2.64z" />
              </svg>
              <div className="flex flex-col leading-none text-left">
                <span className="text-[10px] text-slate-400">Get it on</span>
                <span className="text-base font-semibold">Google Play</span>
              </div>
            </a>

            {/* QR Placeholder */}
            <div className="hidden sm:flex flex-col items-center gap-2">
              <div className="w-20 h-20 bg-white border-2 border-slate-200 rounded-xl p-2 shadow-card">
                {/* QR CSS art */}
                <div className="w-full h-full grid grid-cols-4 grid-rows-4 gap-0.5">
                  {[1,1,1,0, 1,0,1,0, 1,1,1,1, 0,1,0,1].map((v, idx) => (
                    <div key={idx} className={`rounded-[2px] ${v ? 'bg-slate-900' : 'bg-transparent'}`} />
                  ))}
                </div>
              </div>
              <span className="text-[10px] text-slate-400 font-medium">QR ile indir</span>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
