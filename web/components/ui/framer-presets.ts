import type { Variants, Transition } from 'framer-motion';

const spring: Transition = { type: 'spring', stiffness: 400, damping: 28 };
const ease: Transition   = { duration: 0.3, ease: [0.16, 1, 0.3, 1] };

export const fadeInUp: Variants = {
  initial: { opacity: 0, y: 12 },
  animate: { opacity: 1, y: 0,  transition: ease },
  exit:    { opacity: 0, y: -8, transition: { duration: 0.2 } },
};

export const fadeIn: Variants = {
  initial: { opacity: 0 },
  animate: { opacity: 1, transition: ease },
  exit:    { opacity: 0, transition: { duration: 0.15 } },
};

export const scaleIn: Variants = {
  initial: { opacity: 0, scale: 0.92 },
  animate: { opacity: 1, scale: 1,    transition: ease },
  exit:    { opacity: 0, scale: 0.95, transition: { duration: 0.15 } },
};

export const slideInLeft: Variants = {
  initial: { opacity: 0, x: -16 },
  animate: { opacity: 1, x: 0,   transition: ease },
  exit:    { opacity: 0, x: 16,  transition: { duration: 0.2 } },
};

export const slideInRight: Variants = {
  initial: { opacity: 0, x: 16 },
  animate: { opacity: 1, x: 0,   transition: ease },
};

export const staggerContainer: Variants = {
  animate: {
    transition: { staggerChildren: 0.08, delayChildren: 0.05 },
  },
};

export const staggerItem: Variants = {
  initial: { opacity: 0, y: 10 },
  animate: { opacity: 1, y: 0,  transition: ease },
};

// Hover / tap interaction helpers (spread directly on motion components)
export const hoverLift = {
  whileHover: { y: -3, scale: 1.01 },
  transition: spring,
};

export const hoverGlow = {
  whileHover: { scale: 1.02 },
  transition: spring,
};

export const tapScale = {
  whileTap: { scale: 0.97 },
  transition: spring,
};
