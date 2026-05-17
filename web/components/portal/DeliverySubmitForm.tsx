'use client';

import { useState, useRef } from 'react';
import { submitDelivery } from '@/app/portal/contracts/[id]/actions';
import { Upload, X } from 'lucide-react';

type DeliverySubmitFormProps = {
  proposalId: string;
};

export function DeliverySubmitForm({ proposalId }: DeliverySubmitFormProps) {
  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);
  const [isDragging, setIsDragging] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = (files: FileList) => {
    const newFiles = Array.from(files);
    const totalFiles = selectedFiles.length + newFiles.length;

    if (totalFiles > 10) {
      alert('Maksimum 10 dosya yükleyebilirsiniz.');
      return;
    }

    setSelectedFiles([...selectedFiles, ...newFiles]);
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    handleFileSelect(e.dataTransfer.files);
  };

  const removeFile = (index: number) => {
    setSelectedFiles(selectedFiles.filter((_, i) => i !== index));
  };

  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + ' ' + sizes[i];
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);

    const formData = new FormData();
    formData.append('proposal_id', proposalId);

    const noteInput = (e.currentTarget.elements.namedItem('note') as HTMLTextAreaElement);
    formData.append('note', noteInput.value);

    selectedFiles.forEach((file) => {
      formData.append('files', file);
    });

    await submitDelivery(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <input type="hidden" name="proposal_id" value={proposalId} />

      <div>
        <label className="block text-sm font-medium text-slate-700 mb-1.5">
          Teslimat Notu <span className="text-red-500">*</span>
        </label>
        <textarea
          name="note"
          rows={4}
          required
          minLength={5}
          placeholder="Teslim ettiğiniz çalışmayı açıklayın..."
          className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand resize-none"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-slate-700 mb-1.5">
          Dosyalar <span className="text-red-500">*</span>
          <span className="text-xs text-slate-500 font-normal ml-1">
            (1-10 dosya, maksimum 50MB)
          </span>
        </label>

        <input
          ref={fileInputRef}
          type="file"
          multiple
          onChange={(e) => e.target.files && handleFileSelect(e.target.files)}
          className="hidden"
        />

        <div
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          onClick={() => fileInputRef.current?.click()}
          className={`border-2 border-dashed rounded-xl p-6 text-center cursor-pointer transition-colors ${
            isDragging
              ? 'border-brand bg-brand/5'
              : 'border-slate-200 bg-slate-50 hover:bg-slate-100'
          }`}
        >
          <Upload className="w-8 h-8 text-slate-400 mx-auto mb-2" />
          <p className="text-sm font-medium text-slate-700">
            Dosyaları buraya sürükleyin veya tıklayın
          </p>
          <p className="text-xs text-slate-500 mt-1">
            PDF, DOC, DOCX, XLS, XLSX, ZIP, görseller, metin dosyaları
          </p>
        </div>
      </div>

      {selectedFiles.length > 0 && (
        <div className="space-y-2">
          <p className="text-sm font-medium text-slate-700">
            Seçili dosyalar ({selectedFiles.length}/10)
          </p>
          <div className="space-y-2 max-h-48 overflow-y-auto">
            {selectedFiles.map((file, index) => (
              <div
                key={`${file.name}-${index}`}
                className="flex items-center justify-between p-3 bg-slate-50 rounded-lg border border-slate-200"
              >
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-slate-900 truncate">
                    {file.name}
                  </p>
                  <p className="text-xs text-slate-500">
                    {formatFileSize(file.size)}
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => removeFile(index)}
                  className="ml-2 p-1 text-slate-400 hover:text-red-500 transition-colors"
                  aria-label="Dosyayı kaldır"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      <button
        type="submit"
        disabled={isSubmitting || selectedFiles.length === 0}
        className="w-full sm:w-auto px-6 py-2.5 rounded-xl bg-brand hover:bg-brand-dark disabled:opacity-50 disabled:cursor-not-allowed text-white text-sm font-semibold transition-colors"
      >
        {isSubmitting ? 'Yükleniyor...' : 'Teslimatı Gönder'}
      </button>
    </form>
  );
}
