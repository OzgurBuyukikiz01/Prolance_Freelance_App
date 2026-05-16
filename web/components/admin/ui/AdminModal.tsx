'use client';

import * as Dialog from '@radix-ui/react-dialog';
import type { ReactNode } from 'react';

type AdminModalProps = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  description?: string;
  children: ReactNode;
};

export function AdminModal({
  open,
  onOpenChange,
  title,
  description,
  children,
}: AdminModalProps) {
  return (
    <Dialog.Root open={open} onOpenChange={onOpenChange}>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40" />
        <Dialog.Content className="fixed inset-x-4 top-1/2 z-50 mx-auto max-w-lg -translate-y-1/2 rounded-2xl border border-slate-700 bg-slate-900 p-6 shadow-xl focus:outline-none">
          <Dialog.Title className="text-lg font-bold text-white">{title}</Dialog.Title>
          {description ? (
            <Dialog.Description className="mt-1 text-sm text-slate-400">
              {description}
            </Dialog.Description>
          ) : null}
          <div className="mt-4">{children}</div>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
