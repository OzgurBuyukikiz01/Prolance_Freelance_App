import { createServerClient, type CookieOptions } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

import { getSupabaseAnonKey, getSupabaseUrl } from '@/lib/supabase/env';

const ADMIN_PREFIXES = [
  '/dashboard',
  '/jobs',
  '/tickets',
  '/disputes',
  '/users',
  '/audit',
];

const ADMIN_LOGIN = '/admin/login';

function isAdminRoute(pathname: string): boolean {
  return ADMIN_PREFIXES.some(
    (prefix) => pathname === prefix || pathname.startsWith(`${prefix}/`),
  );
}

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(getSupabaseUrl(), getSupabaseAnonKey(), {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet: { name: string; value: string; options: CookieOptions }[]) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        supabaseResponse = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) =>
          supabaseResponse.cookies.set(name, value, options),
        );
      },
    },
  });

  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Admin panel routes
  if (isAdminRoute(pathname)) {
    if (!user) {
      const url = request.nextUrl.clone();
      url.pathname = ADMIN_LOGIN;
      return NextResponse.redirect(url);
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('is_admin')
      .eq('id', user.id)
      .single();

    if (!profile?.is_admin) {
      const url = request.nextUrl.clone();
      url.pathname = ADMIN_LOGIN;
      url.searchParams.set('error', 'Bu panele erişim yetkiniz yok.');
      await supabase.auth.signOut();
      return NextResponse.redirect(url);
    }

    return supabaseResponse;
  }

  if (pathname === ADMIN_LOGIN) {
    if (user) {
      const url = request.nextUrl.clone();
      url.pathname = '/dashboard';
      return NextResponse.redirect(url);
    }
    return supabaseResponse;
  }

  // Landing: protect /portal
  if (pathname.startsWith('/portal') && !user) {
    const url = request.nextUrl.clone();
    url.pathname = '/login';
    return NextResponse.redirect(url);
  }

  // Landing: logged-in user on /login → portal
  if (pathname === '/login' && user) {
    const url = request.nextUrl.clone();
    url.pathname = '/portal';
    return NextResponse.redirect(url);
  }

  return supabaseResponse;
}

export const config = {
  matcher: [
    '/portal/:path*',
    '/login',
    '/admin/login',
    '/dashboard/:path*',
    '/jobs/:path*',
    '/tickets/:path*',
    '/disputes/:path*',
    '/users/:path*',
    '/audit/:path*',
  ],
};
