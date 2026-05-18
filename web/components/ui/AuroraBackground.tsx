'use client';

import { motion } from 'framer-motion';

export function AuroraBackground() {
  return (
    <>
      {/* Aurora orbs — fixed behind all content */}
      <div className="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
        {/* Violet orb — top left */}
        <motion.div
          className="aurora-orb w-[700px] h-[700px]"
          style={{
            background: 'radial-gradient(ellipse at center, rgba(114,72,254,0.50) 0%, transparent 70%)',
            top: '-15%',
            left: '-10%',
          }}
          animate={{
            x: [0, 80, 0],
            y: [0, -40, 0],
            scale: [1, 1.15, 1],
            opacity: [0.7, 0.9, 0.7],
          }}
          transition={{ duration: 12, repeat: Infinity, ease: 'easeInOut' }}
        />

        {/* Coral orb — top right */}
        <motion.div
          className="aurora-orb w-[500px] h-[500px]"
          style={{
            background: 'radial-gradient(ellipse at center, rgba(255,88,51,0.38) 0%, transparent 70%)',
            top: '5%',
            right: '-5%',
          }}
          animate={{
            x: [0, -60, 0],
            y: [0, 60, 0],
            scale: [1, 1.2, 1],
            opacity: [0.6, 0.8, 0.6],
          }}
          transition={{ duration: 16, repeat: Infinity, ease: 'easeInOut' }}
        />

        {/* Indigo orb — middle */}
        <motion.div
          className="aurora-orb w-[600px] h-[600px]"
          style={{
            background: 'radial-gradient(ellipse at center, rgba(79,70,229,0.42) 0%, transparent 70%)',
            top: '40%',
            left: '30%',
          }}
          animate={{
            x: [0, 40, -40, 0],
            y: [0, 30, -20, 0],
            scale: [1, 0.9, 1.1, 1],
            opacity: [0.5, 0.7, 0.5],
          }}
          transition={{ duration: 10, repeat: Infinity, ease: 'easeInOut' }}
        />

        {/* Cyan orb — bottom left */}
        <motion.div
          className="aurora-orb w-[450px] h-[450px]"
          style={{
            background: 'radial-gradient(ellipse at center, rgba(6,182,212,0.28) 0%, transparent 70%)',
            bottom: '10%',
            left: '5%',
          }}
          animate={{
            x: [0, 50, 0],
            y: [0, -50, 0],
            scale: [1, 1.1, 1],
            opacity: [0.4, 0.6, 0.4],
          }}
          transition={{ duration: 14, repeat: Infinity, ease: 'easeInOut' }}
        />
      </div>

      {/* Grain texture overlay */}
      <div className="grain-overlay" aria-hidden />
    </>
  );
}
