'use client';

import { useFormStatus } from 'react-dom';
import { updateProfile, uploadAvatar } from '@/app/portal/profile/actions';

function SaveButton() {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className="w-full bg-brand hover:bg-brand-dark disabled:opacity-60 text-white font-semibold py-3 rounded-xl transition-colors"
    >
      {pending ? 'Saving…' : 'Save Profile'}
    </button>
  );
}

type ProfileFormProps = {
  profile: {
    full_name: string;
    title: string;
    bio: string;
    location: string;
    website: string;
    hourly_rate: number;
    role: string;
    skills: unknown;
    avatar_url: string;
    email: string | null;
  };
};

function parseSkills(raw: unknown): string {
  if (Array.isArray(raw)) return raw.map(String).join(', ');
  return '';
}

export function ProfileForm({ profile }: ProfileFormProps) {
  return (
    <div className="space-y-6">
      <form action={uploadAvatar} className="flex items-center gap-4">
        <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-brand to-indigo-500 flex items-center justify-center text-white text-2xl font-extrabold overflow-hidden shrink-0">
          {profile.avatar_url ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={profile.avatar_url} alt="" className="w-full h-full object-cover" />
          ) : (
            profile.full_name.charAt(0).toUpperCase()
          )}
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-300 mb-1">Avatar</label>
          <input
            type="file"
            name="avatar"
            accept="image/*"
            className="text-xs text-slate-400"
          />
          <button
            type="submit"
            className="mt-2 text-xs font-semibold text-brand hover:text-brand-dark"
          >
            Upload
          </button>
        </div>
      </form>

      <form action={updateProfile} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-slate-300 mb-1">Email</label>
          <p className="text-sm text-slate-400">{profile.email ?? '—'}</p>
        </div>
        <div>
          <label htmlFor="full_name" className="block text-sm font-medium text-slate-300 mb-1">
            Full Name
          </label>
          <input
            id="full_name"
            name="full_name"
            defaultValue={profile.full_name}
            required
            className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30"
          />
        </div>
        <div>
          <label htmlFor="role" className="block text-sm font-medium text-slate-300 mb-1">
            Role
          </label>
          <select
            id="role"
            name="role"
            defaultValue={profile.role}
            className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30"
          >
            <option value="FREELANCER">Freelancer</option>
            <option value="CLIENT">Client</option>
          </select>
        </div>
        <div>
          <label htmlFor="title" className="block text-sm font-medium text-slate-300 mb-1">
            Title
          </label>
          <input
            id="title"
            name="title"
            defaultValue={profile.title}
            className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30"
          />
        </div>
        <div>
          <label htmlFor="bio" className="block text-sm font-medium text-slate-300 mb-1">
            Bio
          </label>
          <textarea
            id="bio"
            name="bio"
            rows={4}
            defaultValue={profile.bio}
            className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-4 py-2.5 text-sm resize-y focus:outline-none focus:ring-2 focus:ring-brand/30"
          />
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label htmlFor="location" className="block text-sm font-medium text-slate-300 mb-1">
              Location
            </label>
            <input
              id="location"
              name="location"
              defaultValue={profile.location}
              className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30"
            />
          </div>
          <div>
            <label htmlFor="hourly_rate" className="block text-sm font-medium text-slate-300 mb-1">
              Hourly Rate ($)
            </label>
            <input
              id="hourly_rate"
              name="hourly_rate"
              type="number"
              min={0}
              defaultValue={profile.hourly_rate}
              className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30"
            />
          </div>
        </div>
        <div>
          <label htmlFor="website" className="block text-sm font-medium text-slate-300 mb-1">
            Website
          </label>
          <input
            id="website"
            name="website"
            type="url"
            defaultValue={profile.website}
            className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30"
          />
        </div>
        <div>
          <label htmlFor="skills" className="block text-sm font-medium text-slate-300 mb-1">
            Skills (comma separated)
          </label>
          <input
            id="skills"
            name="skills"
            defaultValue={parseSkills(profile.skills)}
            className="w-full rounded-xl border border-white/10 bg-white/5 text-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-brand/30"
          />
        </div>
        <SaveButton />
      </form>
    </div>
  );
}
