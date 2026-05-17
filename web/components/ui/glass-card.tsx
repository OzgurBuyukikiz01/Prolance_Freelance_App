import React from 'react';
import { cn } from '@/lib/utils';

type GlowColor = 'coral' | 'violet' | 'mint' | false;
type CardVariant = 'default' | 'strong' | 'subtle';

interface GlassCardProps extends React.HTMLAttributes<HTMLElement> {
  variant?: CardVariant;
  glow?: GlowColor;
  as?: string;
}

const variantClass: Record<CardVariant, string> = {
  default: 'glass-card',
  strong:  'glass-card-strong',
  subtle:  'glass-card-subtle',
};

const glowClass: Record<Exclude<GlowColor, false>, string> = {
  coral:  'glow-coral',
  violet: 'glow-violet',
  mint:   'glow-mint',
};

export function GlassCard({
  variant = 'default',
  glow = false,
  as = 'div',
  className,
  children,
  ...props
}: GlassCardProps) {
  return React.createElement(
    as,
    {
      className: cn(
        variantClass[variant],
        glow && glowClass[glow],
        'transition-all duration-300',
        className,
      ),
      ...props,
    },
    children,
  );
}
