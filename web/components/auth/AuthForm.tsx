'use client';

import { useState } from 'react';
import { login, signup } from '@/app/login/actions';
import { SignInPage, DEFAULT_AUTH_HERO, type Testimonial } from '@/components/ui/sign-in';

/** Marketing / sosyal kanıt — görsel blok sağ kolonda gösterilir. */
const SAMPLE_TESTIMONIALS_TR: Testimonial[] = [
  {
    avatarSrc: 'https://randomuser.me/api/portraits/women/57.jpg',
    name: 'Selin Koç',
    handle: '@selindigital',
    text: 'Escrow güvencesi işimi çok rahatlattı. Ödeme ve iletişim tek yerde.',
  },
  {
    avatarSrc: 'https://randomuser.me/api/portraits/men/64.jpg',
    name: 'Kerem Öztürk',
    handle: '@keremtasarim',
    text: 'Müşteriyle anlaşıp teklif vermek sade ve şeffaf. Öneririm.',
  },
  {
    avatarSrc: 'https://randomuser.me/api/portraits/men/32.jpg',
    name: 'Burak Çelik',
    handle: '@burakkod',
    text: 'Uzaktan iş platformları arasında güven hissini en çok burada yakaladım.',
  },
];

type AuthFormProps = {
  initialTab: 'login' | 'signup';
  errorMsg?: string;
};

function decodeError(raw?: string): string | undefined {
  if (!raw) return undefined;
  try {
    return decodeURIComponent(raw);
  } catch {
    return raw;
  }
}

export function AuthForm({ initialTab, errorMsg }: AuthFormProps) {
  const [tab, setTab] = useState<'login' | 'signup'>(initialTab);
  const [pending, setPending] = useState(false);

  return (
    <SignInPage
      mode={tab}
      onModeChange={setTab}
      loginAction={login}
      signupAction={signup}
      pending={pending}
      onSubmitStart={() => setPending(true)}
      errorMsg={decodeError(errorMsg)}
      heroImageSrc={DEFAULT_AUTH_HERO}
      testimonials={SAMPLE_TESTIMONIALS_TR}
      googleDisabled
      onResetPassword={() => {
        window.location.href = `mailto:support@prolance.app?subject=${encodeURIComponent('Prolance — şifre sıfırlama')}&body=${encodeURIComponent('Kayıtlı e-postam: ')}`;
      }}
    />
  );
}
