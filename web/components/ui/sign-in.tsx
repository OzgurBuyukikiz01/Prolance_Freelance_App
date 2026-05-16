'use client';

import React, { useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { Eye, EyeOff } from 'lucide-react';
import { Label } from '@/components/ui/label';
import { cn } from '@/lib/utils';

/** Default hero (Unsplash, stable path). Override via `heroImageSrc`. */
export const DEFAULT_AUTH_HERO =
  'https://images.unsplash.com/photo-1642615835477-d303d7dc9ee9?w=2160&q=80';

export interface Testimonial {
  avatarSrc: string;
  name: string;
  handle: string;
  text: string;
}

export type AuthMode = 'login' | 'signup';

export interface SignInPageProps {
  /** Giriş veya kayıt formu. */
  mode: AuthMode;
  /** Sekme / mod değiştir (diğer form). */
  onModeChange?: (mode: AuthMode) => void;
  /** Sunucu eylemi: giriş. */
  loginAction?: (formData: FormData) => void | Promise<void>;
  /** Sunucu eylemi: kayıt. */
  signupAction?: (formData: FormData) => void | Promise<void>;
  /** Form gönderilirken düğmeleri kilitle */
  pending?: boolean;
  /** Gönderilmeye başlayınca (optimistik) */
  onSubmitStart?: () => void;
  title?: React.ReactNode;
  description?: React.ReactNode;
  heroImageSrc?: string;
  testimonials?: Testimonial[];
  /** Hata parametresinden (`?error=`) URL-decode sonrası */
  errorMsg?: string | null;
  /** Google ile devam — şimdilik kapalı (Yakında). */
  googleDisabled?: boolean;
  /** Google için isteğe bağlı geriçağırım (ileride OAuth). */
  onGoogleSignIn?: () => void;
  /** Şifre sıfırlama (ileride `/forgot-password` vb.) */
  onResetPassword?: () => void;
  className?: string;
}

const GoogleIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 48 48" aria-hidden>
    <path
      fill="#FFC107"
      d="M43.611 20.083H42V20H24v8h11.303c-1.649 4.657-6.08 8-11.303 8-6.627 0-12-5.373-12-12s12-5.373 12-12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 12.955 4 4 12.955 4 24s8.955 20 20 20 20-8.955 20-20c0-2.641-.21-5.236-.611-7.743z"
    />
    <path
      fill="#FF3D00"
      d="M6.306 14.691l6.571 4.819C14.655 15.108 18.961 12 24 12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 16.318 4 9.656 8.337 6.306 14.691z"
    />
    <path
      fill="#4CAF50"
      d="M24 44c5.166 0 9.86-1.977 13.409-5.192l-6.19-5.238C29.211 35.091 26.715 36 24 36c-5.202 0-9.619-3.317-11.283-7.946l-6.522 5.025C9.505 39.556 16.227 44 24 44z"
    />
    <path
      fill="#1976D2"
      d="M43.611 20.083H42V20H24v8h11.303c-.792 2.237-2.231 4.166-4.087 5.571l6.19 5.238C42.022 35.026 44 30.038 44 24c0-2.641-.21-5.236-.611-7.743z"
    />
  </svg>
);

const GlassInputWrapper = ({ children }: { children: React.ReactNode }) => (
  <div className="rounded-2xl border border-border bg-foreground/[0.04] backdrop-blur-sm transition-colors focus-within:border-primary/55 focus-within:bg-primary/[0.07] dark:bg-muted/30">
    {children}
  </div>
);

const TestimonialCard = ({ testimonial, delayClass }: { testimonial: Testimonial; delayClass: string }) => (
  <div
    className={cn(
      'animate-testimonial-in flex items-start gap-3 rounded-3xl border border-border/60 bg-card/50 p-5 shadow-sm backdrop-blur-xl dark:bg-zinc-900/45 w-64',
      delayClass,
    )}
  >
    <Image
      src={testimonial.avatarSrc}
      width={40}
      height={40}
      className="h-10 w-10 rounded-2xl object-cover"
      alt=""
    />
    <div className="text-sm leading-snug">
      <p className="flex items-center gap-1 font-medium">{testimonial.name}</p>
      <p className="text-muted-foreground">{testimonial.handle}</p>
      <p className="mt-1 text-foreground/80">{testimonial.text}</p>
    </div>
  </div>
);

/** Prolance — cam / iki sütun auth düzeni (giriş + kayıt). */
export function SignInPage({
  mode,
  onModeChange,
  loginAction,
  signupAction,
  pending = false,
  onSubmitStart,
  title,
  description,
  heroImageSrc = DEFAULT_AUTH_HERO,
  testimonials = [],
  errorMsg,
  googleDisabled = true,
  onGoogleSignIn,
  onResetPassword,
  className,
}: SignInPageProps) {
  const [showPassword, setShowPassword] = useState(false);

  const isLogin = mode === 'login';
  const resolvedTitle =
    title ??
    (isLogin ? (
      <span className="font-light tracking-tighter text-foreground">Tekrar hoş geldin</span>
    ) : (
      <span className="font-light tracking-tighter text-foreground">Prolance&apos;a katıl</span>
    ));

  const resolvedDescription =
    description ??
    (isLogin
      ? 'Hesabına giriş yaparak işleri, mesajları ve escrow&apos;unu yönet.'
      : 'Freelancer veya işveren olarak güvenli ödemeler ve tekliflerle devam et.');

  const formAction = isLogin ? loginAction : signupAction;

  return (
    <div className={cn('flex min-h-[100dvh] w-full flex-col bg-background font-sans md:flex-row md:max-h-none', className)}>
      <section className="relative flex flex-1 flex-col overflow-y-auto px-6 py-10 md:justify-center md:overflow-visible md:p-8">
        <div className="mx-auto mb-8 flex w-full max-w-md shrink-0 items-center gap-2">
          <Link href="/" className="flex items-center gap-2 text-foreground">
            <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary text-lg font-black text-primary-foreground shadow-brand">
              P
            </span>
            <span className="text-xl font-extrabold">Prolance</span>
          </Link>
        </div>

        <div className="mx-auto w-full max-w-md">
          <div className="mb-8 flex rounded-2xl border border-border/80 bg-muted/40 p-1">
            {(['login', 'signup'] as const).map((t) => (
              <button
                key={t}
                type="button"
                onClick={() => onModeChange?.(t)}
                className={cn(
                  'flex-1 rounded-xl py-2.5 text-center text-sm font-semibold transition-all',
                  mode === t ? 'bg-background text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground',
                )}
              >
                {t === 'login' ? 'Giriş Yap' : 'Kayıt Ol'}
              </button>
            ))}
          </div>

          <div className="flex flex-col gap-6">
            <h1 className="auth-animate-el auth-delay-100 text-4xl font-semibold leading-tight md:text-5xl">{resolvedTitle}</h1>
            <p className="auth-animate-el auth-delay-200 text-muted-foreground">{resolvedDescription}</p>

            {errorMsg ? (
              <div className="auth-animate-el auth-delay-250 rounded-2xl border border-destructive/30 bg-destructive/10 px-4 py-3 text-sm text-destructive">
                {errorMsg}
              </div>
            ) : null}

            <form
              key={mode}
              className="space-y-5"
              action={formAction}
              onSubmit={(e) => {
                // Sunucu eylemi yoksa (demo) yenilemeyi engelle
                if (!formAction) e.preventDefault();
                else onSubmitStart?.();
              }}
            >
              {!isLogin && (
                <div className="auth-animate-el auth-delay-275">
                  <Label htmlFor="full_name" className="mb-2 block text-sm font-medium text-muted-foreground">
                    Ad Soyad
                  </Label>
                  <GlassInputWrapper>
                    <input
                      id="full_name"
                      name="full_name"
                      type="text"
                      required={!isLogin}
                      placeholder="Adınız ve soyadınız"
                      className="w-full rounded-2xl bg-transparent p-4 text-sm focus:outline-none"
                      disabled={pending}
                      autoComplete="name"
                    />
                  </GlassInputWrapper>
                </div>
              )}

              <div className="auth-animate-el auth-delay-300">
                <Label htmlFor="email" className="mb-2 block text-sm font-medium text-muted-foreground">
                  E-posta
                </Label>
                <GlassInputWrapper>
                  <input
                    id="email"
                    name="email"
                    type="email"
                    placeholder="ornek@eposta.com"
                    required
                    className="w-full rounded-2xl bg-transparent p-4 text-sm focus:outline-none"
                    disabled={pending}
                    autoComplete={isLogin ? 'email' : 'email'}
                  />
                </GlassInputWrapper>
              </div>

              <div className="auth-animate-el auth-delay-400">
                <Label htmlFor="password" className="mb-2 block text-sm font-medium text-muted-foreground">
                  Şifre
                </Label>
                <GlassInputWrapper>
                  <div className="relative">
                    <input
                      id="password"
                      name="password"
                      type={showPassword ? 'text' : 'password'}
                      placeholder="••••••••"
                      required
                      className="w-full rounded-2xl bg-transparent p-4 pr-12 text-sm focus:outline-none"
                      disabled={pending}
                      autoComplete={isLogin ? 'current-password' : 'new-password'}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword((v) => !v)}
                      className="absolute inset-y-0 right-3 flex items-center rounded-md outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring"
                      aria-label={showPassword ? 'Şifreyi gizle' : 'Şifreyi göster'}
                    >
                      {showPassword ? (
                        <EyeOff className="h-5 w-5 text-muted-foreground transition-colors hover:text-foreground" />
                      ) : (
                        <Eye className="h-5 w-5 text-muted-foreground transition-colors hover:text-foreground" />
                      )}
                    </button>
                  </div>
                </GlassInputWrapper>
              </div>

              {!isLogin && (
                <div className="auth-animate-el auth-delay-425">
                  <Label htmlFor="role" className="mb-2 block text-sm font-medium text-muted-foreground">
                    Hesap Türü
                  </Label>
                  <GlassInputWrapper>
                    <select
                      id="role"
                      name="role"
                      disabled={pending}
                      defaultValue="FREELANCER"
                      className="w-full cursor-pointer rounded-2xl bg-transparent p-4 text-sm focus:outline-none"
                    >
                      <option value="FREELANCER">Freelancer</option>
                      <option value="CLIENT">İşveren</option>
                    </select>
                  </GlassInputWrapper>
                </div>
              )}

              {isLogin && (
                <div className="auth-animate-el auth-delay-450 flex flex-col gap-4 text-sm sm:flex-row sm:items-center sm:justify-between">
                  <label className="flex cursor-pointer items-center gap-3">
                    <input type="checkbox" name="rememberMe" disabled={pending} className="rounded border-input" />
                    <span className="text-foreground/90">Beni hatırla</span>
                  </label>
                  <button
                    type="button"
                    onClick={() => onResetPassword?.()}
                    className="text-left font-medium text-primary hover:underline sm:text-right"
                  >
                    Şifremi unuttum
                  </button>
                </div>
              )}

              <button
                type="submit"
                disabled={pending || !formAction}
                className="auth-animate-el auth-delay-550 w-full rounded-2xl bg-primary py-4 font-medium text-primary-foreground transition-colors hover:bg-primary/90 disabled:opacity-70"
              >
                {pending ? (isLogin ? 'Giriş yapılıyor…' : 'Kayıt olunuyor…') : isLogin ? 'Giriş Yap' : 'Kayıt Ol'}
              </button>
            </form>

              <div className="auth-animate-el auth-delay-620 relative flex items-center justify-center">
                <span className="w-full border-t border-border" />
                <span className="absolute bg-background px-4 text-sm text-muted-foreground">veya</span>
              </div>

              <button
                type="button"
                disabled={googleDisabled}
                onClick={() => !googleDisabled && onGoogleSignIn?.()}
                className="auth-animate-el auth-delay-700 flex w-full items-center justify-center gap-3 rounded-2xl border border-border py-4 transition-colors hover:bg-secondary disabled:cursor-not-allowed disabled:opacity-60"
              >
                <GoogleIcon />
                Google ile giriş {googleDisabled ? '— Yakında' : ''}
              </button>

              <p className="auth-animate-el auth-delay-800 text-center text-sm text-muted-foreground">
                {isLogin ? (
                  <>
                    Hesabın yok mu?{' '}
                    <button type="button" className="font-medium text-primary hover:underline" onClick={() => onModeChange?.('signup')}>
                      Kayıt ol
                    </button>
                  </>
                ) : (
                  <>
                    Zaten hesabın var mı?{' '}
                    <button type="button" className="font-medium text-primary hover:underline" onClick={() => onModeChange?.('login')}>
                      Giriş yap
                    </button>
                  </>
                )}
              </p>

              <p className="auth-animate-el auth-delay-900 text-center text-xs text-muted-foreground">
                Devam ederek{' '}
                <Link href="/terms" className="text-primary hover:underline">
                  Kullanım Koşulları
                </Link>{' '}
                ve{' '}
                <Link href="/privacy" className="text-primary hover:underline">
                  Gizlilik Politikası
                </Link>
                &apos;nı kabul etmiş olursun.
              </p>
          </div>
        </div>
      </section>

      <section className="relative hidden flex-1 p-4 md:flex md:min-h-[100dvh] md:flex-col">
        <div className="relative min-h-[calc(100dvh-2rem)] flex-1">
          <div
            className="auth-slide-right auth-delay-300 absolute inset-0 rounded-3xl bg-cover bg-center shadow-inner ring-1 ring-border/60"
            style={{ backgroundImage: `url(${heroImageSrc})` }}
            aria-hidden
          />
          {testimonials.length > 0 && (
            <div className="absolute bottom-8 left-1/2 flex w-full max-w-full -translate-x-1/2 justify-center gap-4 px-8">
              <TestimonialCard testimonial={testimonials[0]!} delayClass="auth-delay-950" />
              {testimonials[1] ? (
                <div className="hidden xl:flex">
                  <TestimonialCard testimonial={testimonials[1]} delayClass="auth-delay-1050" />
                </div>
              ) : null}
              {testimonials[2] ? (
                <div className="hidden 2xl:flex">
                  <TestimonialCard testimonial={testimonials[2]} delayClass="auth-delay-1150" />
                </div>
              ) : null}
            </div>
          )}
        </div>
      </section>
    </div>
  );
}
