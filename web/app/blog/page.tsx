import Link from 'next/link';
import { blogPosts, formatBlogDate } from '@/content/blog/posts';
import MarketingPageShell from '@/components/marketing/MarketingPageShell';
import MarketingSiteChrome from '@/components/marketing/MarketingSiteChrome';

export const metadata = {
  title: 'Blog | Prolance',
  description: 'Prolance blog: escrow, freelance ipuçları ve platform güncellemeleri.',
};

export default function BlogPage() {
  const sorted = [...blogPosts].sort(
    (a, b) => new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime(),
  );

  return (
    <MarketingSiteChrome>
      <MarketingPageShell
        eyebrow="Şirket"
        title="Blog"
        subtitle="Escrow, freelance dünyası ve Prolance haberleri."
      >
        <div className="grid gap-6">
          {sorted.map((post) => (
            <article
              key={post.slug}
              className="p-6 rounded-2xl border border-slate-100 bg-white hover:border-indigo-200 hover:shadow-sm transition-all"
            >
              <div className="flex flex-wrap items-center gap-2 text-xs text-slate-500 mb-3">
                <time dateTime={post.publishedAt}>{formatBlogDate(post.publishedAt)}</time>
                <span aria-hidden>·</span>
                <span>{post.author}</span>
              </div>
              <h2 className="text-xl font-bold text-slate-800 mb-2">
                <Link
                  href={`/blog/${post.slug}`}
                  className="hover:text-indigo-600 transition-colors no-underline"
                >
                  {post.title}
                </Link>
              </h2>
              <p className="text-slate-600 text-[15px] leading-relaxed mb-4">{post.excerpt}</p>
              <div className="flex flex-wrap gap-2 mb-4">
                {post.tags.map((tag) => (
                  <span
                    key={tag}
                    className="px-2.5 py-0.5 rounded-full bg-indigo-50 text-indigo-700 text-xs font-medium"
                  >
                    {tag}
                  </span>
                ))}
              </div>
              <Link
                href={`/blog/${post.slug}`}
                className="text-sm font-semibold text-indigo-600 hover:text-indigo-800"
              >
                Devamını oku →
              </Link>
            </article>
          ))}
        </div>
      </MarketingPageShell>
    </MarketingSiteChrome>
  );
}
