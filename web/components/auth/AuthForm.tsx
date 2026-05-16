'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Eye, EyeOff } from 'lucide-react';
import { login, signup } from '@/app/login/actions';
import { AnimatedCharactersAuthPanel } from '@/components/ui/animated-characters-auth-panel';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { cn } from '@/lib/utils';

type AuthFormProps = {
  initialTab: 'login' | 'signup';
  errorMsg?: string;
};

export function AuthForm({ initialTab, errorMsg }: AuthFormProps) {
  const [tab, setTab] = useState<'login' | 'signup'>(initialTab);
  const [isTyping, setIsTyping] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [pending, setPending] = useState(false);

  return (
    <div className="min-h-screen bg-hero-gradient">
      <div className="pointer-events-none fixed inset-0 -z-10">
        <div className="absolute -top-32 -left-32 h-[480px] w-[480px] rounded-full bg-brand/10 blur-3xl" />
        <div className="absolute bottom-0 right-0 h-[360px] w-[360px] rounded-full bg-indigo-100/60 blur-3xl" />
      </div>

      <div className="mx-auto grid min-h-screen max-w-6xl items-center gap-8 px-4 py-12 lg:grid-cols-2 lg:px-8">
        <div className="hidden lg:block">
          <AnimatedCharactersAuthPanel
            isTyping={isTyping}
            showPassword={showPassword}
            hasError={Boolean(errorMsg)}
          />
        </div>

        <div className="w-full max-w-md justify-self-center">
          <Link href="/" className="mb-8 flex items-center justify-center gap-2 lg:justify-start">
            <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-brand text-lg font-black text-white shadow-brand">
              P
            </span>
            <span className="text-2xl font-extrabold text-slate-900">Prolance</span>
          </Link>

          <div className="rounded-3xl border border-slate-100 bg-white p-8 shadow-card">
            <div className="mb-6 flex rounded-xl bg-slate-100 p-1">
              {(['login', 'signup'] as const).map((t) => (
                <button
                  key={t}
                  type="button"
                  onClick={() => setTab(t)}
                  className={cn(
                    'flex-1 rounded-lg py-2 text-center text-sm font-semibold transition-all',
                    tab === t ? 'bg-white text-slate-900 shadow-card' : 'text-slate-500 hover:text-slate-700',
                  )}
                >
                  {t === 'login' ? 'Giriş Yap' : 'Kayıt Ol'}
                </button>
              ))}
            </div>

            {errorMsg && (
              <div className="mb-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
                {decodeURIComponent(errorMsg)}
              </div>
            )}

            {tab === 'login' ? (
              <form action={login} className="flex flex-col gap-4" onSubmit={() => setPending(true)}>
                <Field label="E-posta" name="email" type="email" onFocus={() => setIsTyping(true)} onBlur={() => setIsTyping(false)} />
                <PasswordField
                  showPassword={showPassword}
                  onToggle={() => setShowPassword((v) => !v)}
                  onFocus={() => setIsTyping(true)}
                  onBlur={() => setIsTyping(false)}
                />
                <Button type="submit" className="mt-2 w-full" disabled={pending}>
                  {pending ? 'Giriş yapılıyor…' : 'Giriş Yap'}
                </Button>
                <p className="mt-1 text-center text-xs text-slate-400">
                  Hesabın yok mu?{' '}
                  <button type="button" className="font-medium text-brand hover:underline" onClick={() => setTab('signup')}>
                    Kayıt ol
                  </button>
                </p>
              </form>
            ) : (
              <form action={signup} className="flex flex-col gap-4" onSubmit={() => setPending(true)}>
                <Field label="Ad Soyad" name="full_name" type="text" onFocus={() => setIsTyping(true)} onBlur={() => setIsTyping(false)} />
                <Field label="E-posta" name="email" type="email" onFocus={() => setIsTyping(true)} onBlur={() => setIsTyping(false)} />
                <PasswordField
                  showPassword={showPassword}
                  onToggle={() => setShowPassword((v) => !v)}
                  onFocus={() => setIsTyping(true)}
                  onBlur={() => setIsTyping(false)}
                />
                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="role">Hesap Türü</Label>
                  <select
                    id="role"
                    name="role"
                    className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                    defaultValue="FREELANCER"
                  >
                    <option value="FREELANCER">Freelancer</option>
                    <option value="CLIENT">İşveren</option>
                  </select>
                </div>
                <Button type="submit" className="mt-2 w-full" disabled={pending}>
                  {pending ? 'Kayıt olunuyor…' : 'Kayıt Ol'}
                </Button>
                <p className="mt-1 text-center text-xs text-slate-400">
                  Zaten hesabın var mı?{' '}
                  <button type="button" className="font-medium text-brand hover:underline" onClick={() => setTab('login')}>
                    Giriş yap
                  </button>
                </p>
              </form>
            )}

            <Button type="button" variant="outline" className="mt-4 w-full" disabled title="Yakında">
              Google ile giriş — Yakında
            </Button>

            <p className="mt-6 text-center text-xs text-slate-400">
              Devam ederek{' '}
              <Link href="/terms" className="text-brand hover:underline">
                Kullanım Koşulları
              </Link>{' '}
              ve{' '}
              <Link href="/privacy" className="text-brand hover:underline">
                Gizlilik Politikası
              </Link>
              &apos;nı kabul etmiş olursunuz.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

function Field({
  label,
  name,
  type,
  onFocus,
  onBlur,
}: {
  label: string;
  name: string;
  type: string;
  onFocus?: () => void;
  onBlur?: () => void;
}) {
  return (
    <div className="flex flex-col gap-1.5">
      <Label htmlFor={name}>{label}</Label>
      <Input id={name} name={name} type={type} required onFocus={onFocus} onBlur={onBlur} />
    </div>
  );
}

function PasswordField({
  showPassword,
  onToggle,
  onFocus,
  onBlur,
}: {
  showPassword: boolean;
  onToggle: () => void;
  onFocus?: () => void;
  onBlur?: () => void;
}) {
  return (
    <div className="flex flex-col gap-1.5">
      <Label htmlFor="password">Şifre</Label>
      <div className="relative">
        <Input
          id="password"
          name="password"
          type={showPassword ? 'text' : 'password'}
          required
          className="pr-10"
          onFocus={onFocus}
          onBlur={onBlur}
        />
        <button
          type="button"
          className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
          onClick={onToggle}
          aria-label={showPassword ? 'Şifreyi gizle' : 'Şifreyi göster'}
        >
          {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
        </button>
      </div>
    </div>
  );
}
