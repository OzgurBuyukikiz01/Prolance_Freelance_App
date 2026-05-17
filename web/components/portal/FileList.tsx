'use client';

import { Download, FileText } from 'lucide-react';
import { formatRelativeTime } from '@/lib/portal/format';

type FileListProps = {
  files: Array<{
    id: string;
    file_name: string;
    storage_path: string;
    created_at: string;
  }>;
};

export function FileList({ files }: FileListProps) {
  const getDownloadUrl = (storagePath: string) => {
    // Generate Supabase Storage URL for downloads
    // This will be replaced with actual signed URL when integrated with Supabase
    if (storagePath.startsWith('deliveries/')) {
      return `/api/download?path=${encodeURIComponent(storagePath)}`;
    }
    return storagePath;
  };

  if (files.length === 0) {
    return (
      <div className="text-center py-8 text-slate-500 text-sm">
        Henüz dosya yüklenmedi.
      </div>
    );
  }

  return (
    <div className="space-y-2">
      <div className="grid grid-cols-1 gap-2">
        {files.map((file) => (
          <div
            key={file.id}
            className="flex items-center justify-between p-3 bg-slate-50 rounded-lg border border-slate-200 hover:bg-slate-100 hover:border-slate-300 transition-colors group"
          >
            <div className="flex items-center gap-3 flex-1 min-w-0">
              <FileText className="w-4 h-4 text-slate-400 shrink-0" />
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-slate-900 truncate group-hover:text-brand">
                  {file.file_name}
                </p>
                <p className="text-xs text-slate-500">
                  {formatRelativeTime(file.created_at)}
                </p>
              </div>
            </div>
            <a
              href={getDownloadUrl(file.storage_path)}
              target="_blank"
              rel="noopener noreferrer"
              className="ml-2 p-1.5 text-slate-400 hover:text-brand transition-colors shrink-0"
              aria-label="İndir"
              onClick={(e) => {
                // For now, this will open the file. Later, we'll add proper download handling
                e.preventDefault();
                window.open(getDownloadUrl(file.storage_path), '_blank');
              }}
            >
              <Download className="w-4 h-4" />
            </a>
          </div>
        ))}
      </div>
    </div>
  );
}
