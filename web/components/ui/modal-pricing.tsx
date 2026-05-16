'use client';

import { useState } from 'react';
import { Check } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { PRICING_PLANS, type PricingPlan } from '@/lib/pricing-plans';
import { cn } from '@/lib/utils';

type ModalPricingProps = {
  triggerLabel?: string;
  triggerClassName?: string;
};

export function ModalPricing({
  triggerLabel = 'Planı yükselt',
  triggerClassName,
}: ModalPricingProps) {
  const [open, setOpen] = useState(false);

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline" className={triggerClassName}>
          {triggerLabel}
        </Button>
      </DialogTrigger>
      <DialogContent className="max-h-[90vh] overflow-y-auto sm:max-w-3xl">
        <DialogHeader>
          <DialogTitle>Prolance planları</DialogTitle>
          <DialogDescription>
            Escrow korumalı ödemeler ve gelişmiş iş yönetimi. Ödeme entegrasyonu yakında — şimdilik
            bilgilendirme amaçlıdır.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-4 sm:grid-cols-3">
          {PRICING_PLANS.map((plan) => (
            <PlanCard key={plan.id} plan={plan} onSelect={() => setOpen(false)} />
          ))}
        </div>
      </DialogContent>
    </Dialog>
  );
}

function PlanCard({ plan, onSelect }: { plan: PricingPlan; onSelect: () => void }) {
  return (
    <div
      className={cn(
        'flex flex-col rounded-2xl border p-5',
        plan.highlighted ? 'border-brand bg-brand-light/40 shadow-brand' : 'border-slate-200 bg-white',
      )}
    >
      <h3 className="text-lg font-bold text-slate-900">{plan.name}</h3>
      <p className="mt-1 text-2xl font-extrabold text-brand">
        {plan.price}
        <span className="text-sm font-medium text-slate-500">{plan.period}</span>
      </p>
      <p className="mt-2 text-xs text-slate-500">{plan.description}</p>
      <ul className="mt-4 flex flex-1 flex-col gap-2 text-sm text-slate-600">
        {plan.features.map((f) => (
          <li key={f} className="flex items-start gap-2">
            <Check className="mt-0.5 h-4 w-4 shrink-0 text-brand" />
            {f}
          </li>
        ))}
      </ul>
      <Button
        className="mt-5 w-full"
        variant={plan.highlighted ? 'default' : 'outline'}
        type="button"
        onClick={onSelect}
        disabled={plan.id === 'free'}
      >
        {plan.cta}
      </Button>
    </div>
  );
}
