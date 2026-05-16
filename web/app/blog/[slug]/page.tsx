import Link from 'next/link';
import { notFound } from 'next/navigation';
import {
  blogPosts,
  formatBlogDate,
  getPostBySlug,
  getRelatedPosts,
} from '@/content/blog/posts';
import MarketingPageShell from '@/components/marketing/MarketingPageShell';
import MarketingSiteChrome from '@/components/marketing/MarketingSiteChrome';

type PageProps = {
  params: Promise<{ slug: string }>;
};

export async function generateStaticParams() {
  return blogPosts.map((post) => ({ slug: post.slug }));
}

export async function generateMetadata({ params }: PageProps) {
  const { slug } = await params;
  const post = getPostBySlug(slug);
  if (!post) {
    return { title: 'Yazı bulunamadı | Prolance Blog' };
  }
  return {
    title: `${post.title} | Prolance Blog`,
    description: post.excerpt,
  };
}

export default async function BlogPostPage({ params }: PageProps) {
  const { slug } = await params;
  const post = getPostBySlug(slug);
  if (!post) {
    notFound();
  }

  const related = getRelatedPosts(post);

  return (
    <MarketingSiteChrome>
      <MarketingPageShell
        eyebrow="Blog"
        title={post.title}
        subtitle={
          <>
            {formatBlogDate(post.publishedAt)} · {post.author}
          </>
        }
      >
        <div className="prose prose-slate max-w-none">
          <Link
            href="/blog"
            className="inline-block text-sm text-slate-500 hover:text-indigo-600 mb-8 no-underline"
          >
            ← Blog
          </Link>

          <div className="flex flex-wrap gap-2 mb-8">
            {post.tags.map((tag) => (
              <span
                key={tag}
                className="px-2.5 py-0.5 rounded-full bg-indigo-50 text-indigo-700 text-xs font-medium"
              >
                {tag}
              </span>
            ))}
          </div>

          <div className="space-y-4">
            {post.body.map((para, i) => (
              <p key={i} className="text-slate-600 leading-relaxed text-[15px] m-0">
                {para}
              </p>
            ))}
          </div>

          {related.length > 0 ? (
            <section className="mt-16 pt-10 border-t border-slate-100">
              <h2 className="text-lg font-bold text-slate-800 mb-6">İlgili yazılar</h2>
              <ul className="space-y-4 list-none p-0 m-0">
                {related.map((r) => (
                  <li key={r.slug}>
                    <Link
                      href={`/blog/${r.slug}`}
                      className="block p-4 rounded-xl border border-slate-100 hover:border-indigo-200 no-underline"
                    >
                      <p className="font-semibold text-slate-800 mb-1">{r.title}</p>
                      <p className="text-slate-500 text-sm m-0">{r.excerpt}</p>
                    </Link>
                  </li>
                ))}
              </ul>
            </section>
          ) : null}
        </div>
      </MarketingPageShell>
    </MarketingSiteChrome>
  );
}
