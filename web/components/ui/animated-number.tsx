'use client';

import { useEffect, useRef, useState } from 'react';
import { motion, useSpring, useTransform } from 'framer-motion';

type AnimatedNumberProps = {
  value: number;
  className?: string;
  decimals?: number;
  prefix?: string;
  suffix?: string;
};

export function AnimatedNumber({
  value,
  className,
  decimals = 0,
  prefix = '',
  suffix = '',
}: AnimatedNumberProps) {
  const spring = useSpring(0, { stiffness: 75, damping: 18 });
  const display = useTransform(spring, (v) => {
    const formatted =
      decimals > 0 ? v.toFixed(decimals) : Math.round(v).toLocaleString('tr-TR');
    return `${prefix}${formatted}${suffix}`;
  });
  const [text, setText] = useState(`${prefix}0${suffix}`);
  const mounted = useRef(false);

  useEffect(() => {
    spring.set(value);
  }, [spring, value]);

  useEffect(() => {
    const unsub = display.on('change', (v) => setText(v));
    if (!mounted.current) {
      mounted.current = true;
      spring.jump(value);
    }
    return () => unsub();
  }, [display, spring, value]);

  return (
    <motion.span className={className} aria-live="polite">
      {text}
    </motion.span>
  );
}
