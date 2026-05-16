import { createServiceClient } from '@/lib/supabaseAdmin';
import { approveJob } from './[id]/actions';
import { JobRejectForm } from '@/components/admin/JobRejectForm';

export const dynamic = 'force-dynamic';

export default async function JobsModerationPage() {
  const sb = createServiceClient();

  const { data: jobs, error } = await sb
    .from('jobs')
    .select(
      'id, title, category, status, client_name, budget_min, budget_max, posted_date, rejection_reason',
    )
    .eq('status', 'pending_review')
    .order('posted_date', { ascending: false })
    .limit(100);

  return (
    <div className="p-8 max-w-5xl">
      <div className="mb-6">
        <h1 className="text-2xl font-extrabold text-white">İlan Moderasyonu</h1>
        <p className="text-slate-400 text-sm mt-1">
          İnceleme bekleyen kullanıcı ilanları ({(jobs ?? []).length})
        </p>
      </div>

      {error && (
        <div className="bg-red-500/10 border border-red-500/30 text-red-400 px-4 py-3 rounded-xl text-sm mb-4">
          {error.message}
        </div>
      )}

      <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-slate-800 text-slate-400 text-left">
              <th className="px-4 py-3 font-medium">Başlık</th>
              <th className="px-4 py-3 font-medium">Kategori</th>
              <th className="px-4 py-3 font-medium">İşveren</th>
              <th className="px-4 py-3 font-medium">Bütçe</th>
              <th className="px-4 py-3 font-medium">Tarih</th>
              <th className="px-4 py-3 font-medium">İşlem</th>
            </tr>
          </thead>
          <tbody>
            {(jobs ?? []).map((job) => (
              <tr
                key={job.id as string}
                className="border-b border-slate-800/50 hover:bg-slate-800/40 transition-colors align-top"
              >
                <td className="px-4 py-3 text-white font-medium max-w-[200px]">
                  {job.title as string}
                </td>
                <td className="px-4 py-3 text-slate-400">{job.category as string}</td>
                <td className="px-4 py-3 text-slate-400">{job.client_name as string}</td>
                <td className="px-4 py-3 text-slate-400 text-xs whitespace-nowrap">
                  ₺{Number(job.budget_min).toLocaleString()} – ₺
                  {Number(job.budget_max).toLocaleString()}
                </td>
                <td className="px-4 py-3 text-slate-500 text-xs whitespace-nowrap">
                  {new Date(job.posted_date as string).toLocaleDateString('tr-TR')}
                </td>
                <td className="px-4 py-3">
                  <div className="flex flex-col gap-2 items-start">
                    <form action={approveJob}>
                      <input type="hidden" name="job_id" value={job.id as string} />
                      <button
                        type="submit"
                        className="text-emerald-400 hover:text-emerald-300 text-xs font-semibold transition-colors"
                      >
                        Onayla
                      </button>
                    </form>
                    <JobRejectForm jobId={job.id as string} />
                  </div>
                </td>
              </tr>
            ))}
            {(jobs ?? []).length === 0 && (
              <tr>
                <td colSpan={6} className="px-4 py-8 text-center text-slate-500 text-sm">
                  Bekleyen ilan yok.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
