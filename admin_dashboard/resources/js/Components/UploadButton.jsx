import React, { useState, useRef } from 'react';
import { Upload, Loader2 } from 'lucide-react';
import { router } from '@inertiajs/react';
import { useToast } from '@/hooks/useToast';

export default function UploadButton() {
  const [uploading, setUploading] = useState(false);
  const fileInputRef = useRef(null);
  const { success, error } = useToast();

  const handleFileSelect = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const ext = file.name.split('.').pop().toLowerCase();
    if (!['md', 'txt', 'pdf', 'docx'].includes(ext)) {
      error('Format harus .md, .txt, .pdf, atau .docx');
      e.target.value = '';
      return;
    }

    setUploading(true);
    const formData = new FormData();
    formData.append('file', file);

    try {
      const res = await fetch('/admin/upload/parse', {
        method: 'POST',
        headers: { 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.content },
        body: formData,
      });

      if (res.ok) {
        success('File diproses, alihkan ke form...');
        window.location.href = '/admin/modules/create';
      } else {
        const data = await res.json().catch(() => ({}));
        error(data.message || 'Gagal memproses file');
      }
    } catch (err) {
      error('Gagal mengupload file');
    }

    setUploading(false);
    e.target.value = '';
  };

  return (
    <>
      <input ref={fileInputRef} type="file" accept=".md,.txt,.pdf,.docx" onChange={handleFileSelect} className="hidden" />
      <button type="button" onClick={() => fileInputRef.current?.click()} disabled={uploading}
        className="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-bold text-teal-700 bg-teal-50 border border-teal-200 hover:bg-teal-100 active:scale-98 transition-all rounded-xl w-full sm:w-auto justify-center"
      >
        {uploading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Upload className="w-4 h-4" />}
        {uploading ? 'Memproses...' : 'Upload .md/.pdf/.docx'}
      </button>
    </>
  );
}