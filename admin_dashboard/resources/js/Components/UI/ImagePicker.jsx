import React, { useState, useRef, useCallback } from 'react';
import { Image, Upload, X, Loader2, Check, AlertCircle } from 'lucide-react';

export default function ImagePicker({ 
  value, 
  onChange, 
  label = 'Ikon Modul', 
  accept = 'image/*',
  maxSize = 2 * 1024 * 1024, // 2MB
  className = '' 
}) {
  const [preview, setPreview] = useState(value);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState('');
  const fileInputRef = useRef(null);

  const validateFile = (file) => {
    if (!file.type.startsWith('image/')) {
      setError('File harus berupa gambar');
      return false;
    }
    if (file.size > maxSize) {
      setError(`Ukuran file maksimal ${maxSize / 1024 / 1024}MB`);
      return false;
    }
    return true;
  };

  const handleFileSelect = useCallback((e) => {
    const file = e.target.files[0];
    if (!file) return;
    
    setError('');
    if (!validateFile(file)) return;

    setUploading(true);
    const reader = new FileReader();
    reader.onload = (event) => {
      const base64 = event.target.result;
      setPreview(base64);
      onChange(base64);
      setUploading(false);
    };
    reader.readAsDataURL(file);
  }, [onChange]);

  const handleRemove = () => {
    setPreview(null);
    onChange('');
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  const triggerFileInput = () => fileInputRef.current?.click();

  return (
    <div className={className}>
      <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">
        {label}
      </label>
      
      <input type="file" ref={fileInputRef} accept={accept} onChange={handleFileSelect} className="hidden" />

      <div className="space-y-3">
        {/* Preview Area */}
        <div className="relative">
          {preview ? (
            <div className="relative aspect-square rounded-2xl overflow-hidden border-2 border-sand-200 bg-sand-50">
              <img 
                src={preview} 
                alt="Preview ikon" 
                className="w-full h-full object-cover"
              />
              <button
                type="button"
                onClick={handleRemove}
                className="absolute top-2 right-2 p-1.5 bg-brick-600/90 text-white rounded-full hover:bg-brick-700 transition-colors shadow-lg"
                aria-label="Hapus gambar"
              >
                <X className="w-4 h-4" />
              </button>
              {uploading && (
                <div className="absolute inset-0 bg-white/80 flex items-center justify-center">
                  <Loader2 className="w-6 h-6 text-teal-600 animate-spin" />
                </div>
              )}
            </div>
          ) : (
            <button
              type="button"
              onClick={triggerFileInput}
              className="w-full aspect-square rounded-2xl border-2 border-dashed border-sand-300 bg-sand-50 flex flex-col items-center justify-center gap-2 text-slate-400 hover:border-teal-400 hover:bg-teal-50 hover:text-teal-600 transition-all cursor-pointer"
            >
              <Upload className="w-8 h-8" />
              <span className="text-sm font-semibold">Klik atau tarik gambar di sini</span>
              <span className="text-xs text-slate-500">PNG, JPG, WebP · Maks 2MB</span>
            </button>
          )}
        </div>

        {error && (
          <p className="text-xs font-bold text-brick-500 flex items-center gap-1">
            <AlertCircle className="w-3.5 h-3.5" />
            {error}
          </p>
        )}

        {preview && (
          <p className="text-xs text-slate-400 text-center">
            Gambar akan dikompres & dioptimalkan otomatis saat disimpan
          </p>
        )}
      </div>
    </div>
  );
}