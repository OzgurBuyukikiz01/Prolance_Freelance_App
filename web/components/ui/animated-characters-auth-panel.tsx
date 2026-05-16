'use client';

import { motion } from 'framer-motion';

type AnimatedCharactersAuthPanelProps = {
  isTyping?: boolean;
  showPassword?: boolean;
  hasError?: boolean;
};

export function AnimatedCharactersAuthPanel({
  isTyping = false,
  showPassword = false,
  hasError = false,
}: AnimatedCharactersAuthPanelProps) {
  return (
    <motion.div
      className="relative flex h-full min-h-[320px] w-full items-center justify-center overflow-hidden rounded-3xl bg-gradient-to-br from-brand via-indigo-500 to-violet-600 p-8"
      initial={{ opacity: 0, scale: 0.98 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.5 }}
    >
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_30%_20%,rgba(255,255,255,0.25),transparent_50%)]" />
      <div className="relative flex items-end justify-center gap-6">
        <Character
          color="#FDE68A"
          eyeOffset={showPassword ? { x: 8, y: -4 } : isTyping ? { x: 2, y: 0 } : { x: 0, y: 0 }}
          mouth={hasError ? 'sad' : isTyping ? 'talk' : 'smile'}
          delay={0}
        />
        <Character
          color="#A7F3D0"
          eyeOffset={showPassword ? { x: -6, y: -6 } : { x: 0, y: 0 }}
          mouth={showPassword ? 'surprise' : 'smile'}
          delay={0.1}
          scale={1.15}
        />
        <Character
          color="#BFDBFE"
          eyeOffset={isTyping ? { x: -3, y: 2 } : { x: 0, y: 0 }}
          mouth={hasError ? 'sad' : 'smile'}
          delay={0.2}
        />
      </div>
      <motion.p
        className="absolute bottom-6 left-0 right-0 text-center text-sm font-medium text-white/90"
        animate={{ opacity: isTyping ? 1 : 0.75 }}
      >
        Güvenli giriş, escrow koruması
      </motion.p>
    </motion.div>
  );
}

function Character({
  color,
  eyeOffset,
  mouth,
  delay,
  scale = 1,
}: {
  color: string;
  eyeOffset: { x: number; y: number };
  mouth: 'smile' | 'sad' | 'talk' | 'surprise';
  delay: number;
  scale?: number;
}) {
  return (
    <motion.div
      className="relative"
      style={{ scale }}
      animate={{ y: [0, -6, 0] }}
      transition={{ duration: 2.5, repeat: Infinity, delay, ease: 'easeInOut' }}
    >
      <motion.div
        className="h-24 w-20 rounded-[2rem] shadow-lg"
        style={{ backgroundColor: color }}
        animate={mouth === 'talk' ? { scaleY: [1, 1.03, 1] } : {}}
        transition={{ duration: 0.3, repeat: mouth === 'talk' ? Infinity : 0 }}
      />
      <div className="absolute left-1/2 top-8 flex -translate-x-1/2 gap-3">
        <motion.div
          className="h-3 w-3 rounded-full bg-slate-900"
          animate={{ x: eyeOffset.x, y: eyeOffset.y }}
        />
        <motion.div
          className="h-3 w-3 rounded-full bg-slate-900"
          animate={{ x: eyeOffset.x, y: eyeOffset.y }}
        />
      </div>
      <div className="absolute left-1/2 top-14 -translate-x-1/2">
        {mouth === 'smile' && (
          <div className="h-2 w-6 rounded-b-full border-b-2 border-slate-900" />
        )}
        {mouth === 'sad' && (
          <motion.div
            className="h-2 w-6 rounded-t-full border-t-2 border-slate-900"
            initial={{ rotate: 180 }}
          />
        )}
        {mouth === 'talk' && (
          <motion.div
            className="h-3 w-4 rounded-full bg-slate-900"
            animate={{ scaleY: [1, 0.6, 1] }}
            transition={{ duration: 0.25, repeat: Infinity }}
          />
        )}
        {mouth === 'surprise' && <motion.div className="h-3 w-3 rounded-full bg-slate-900" />}
      </div>
    </motion.div>
  );
}
