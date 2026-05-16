import { AuthForm } from '@/components/auth/AuthForm';

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string; tab?: string }>;
}) {
  const params = await searchParams;
  const tab = params.tab === 'signup' ? 'signup' : 'login';

  return <AuthForm initialTab={tab} errorMsg={params.error} />;
}
