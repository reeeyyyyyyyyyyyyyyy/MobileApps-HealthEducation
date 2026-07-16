import React, { useEffect, useRef, useState } from 'react';
import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import { Link } from 'lucide-react';
import InputModal from './InputModal';

export default function RichTextEditor({ 
  value, 
  onChange, 
  label = 'Konten Edukasi',
  className = '',
  editable = true,
}) {
  const [showLinkModal, setShowLinkModal] = useState(false);
  const editor = useEditor({
    extensions: [StarterKit],
    content: value || '',
    editable,
    onUpdate: ({ editor }) => onChange(editor.getHTML()),
    editorProps: {
      attributes: { class: 'prose prose-sm prose-slate max-w-none focus:outline-none min-h-[300px] p-4', spellcheck: 'true' },
    },
  });

  useEffect(() => {
    if (editor && value && editor.getHTML() !== value) {
      editor.commands.setContent(value, false);
    }
  }, [value, editor]);

  if (!editor) return null;

  const handleLinkConfirm = (url) => {
    editor.chain().focus().extendMarkRange('link').setLink({ href: url }).run();
    setShowLinkModal(false);
  };

  const activeClass = (name, attrs) => editor.isActive(name, attrs) ? 'bg-teal-100 text-teal-700 shadow-sm' : 'text-slate-500 hover:bg-sand-100 hover:text-slate-700';

  return (
    <div className={className}>
      <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">{label}</label>

      <div className="bg-white border border-sand-200 rounded-xl overflow-hidden">
        <div className="p-2 bg-sand-50 border-b border-sand-200 flex flex-wrap gap-1">
          <button type="button" onClick={() => editor.chain().focus().toggleBold().run()} className={`p-1.5 rounded-lg ${activeClass('bold')}`} title="Bold"><span className="font-bold text-sm">B</span></button>
          <button type="button" onClick={() => editor.chain().focus().toggleItalic().run()} className={`p-1.5 rounded-lg ${activeClass('italic')}`} title="Italic"><span className="italic text-sm">I</span></button>
          <button type="button" onClick={() => editor.chain().focus().toggleStrike().run()} className={`p-1.5 rounded-lg ${activeClass('strike')}`} title="Strikethrough"><span className="line-through text-sm">S</span></button>
          <div className="w-px h-6 bg-sand-300 mx-1" />
          <button type="button" onClick={() => editor.chain().focus().toggleHeading({ level: 1 }).run()} className={`p-1.5 rounded-lg text-xs font-bold ${activeClass('heading', { level: 1 })}`} title="H1">H1</button>
          <button type="button" onClick={() => editor.chain().focus().toggleHeading({ level: 2 }).run()} className={`p-1.5 rounded-lg text-xs font-bold ${activeClass('heading', { level: 2 })}`} title="H2">H2</button>
          <button type="button" onClick={() => editor.chain().focus().toggleHeading({ level: 3 }).run()} className={`p-1.5 rounded-lg text-xs font-bold ${activeClass('heading', { level: 3 })}`} title="H3">H3</button>
          <div className="w-px h-6 bg-sand-300 mx-1" />
          <button type="button" onClick={() => editor.chain().focus().toggleBulletList().run()} className={`p-1.5 rounded-lg ${activeClass('bulletList')}`} title="Bullet">
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><circle cx="4" cy="6" r="1.5"/><circle cx="4" cy="12" r="1.5"/><circle cx="4" cy="18" r="1.5"/></svg>
          </button>
          <button type="button" onClick={() => editor.chain().focus().toggleOrderedList().run()} className={`p-1.5 rounded-lg ${activeClass('orderedList')}`} title="Numbered">
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="10" y1="6" x2="21" y2="6"/><line x1="10" y1="12" x2="21" y2="12"/><line x1="10" y1="18" x2="21" y2="18"/><text x="3" y="9" fontSize="8" fontWeight="bold" fill="currentColor">1</text><text x="3" y="16" fontSize="8" fontWeight="bold" fill="currentColor">2</text></svg>
          </button>
          <div className="w-px h-6 bg-sand-300 mx-1" />
          <button type="button" onClick={() => editor.chain().focus().toggleBlockquote().run()} className={`p-1.5 rounded-lg ${activeClass('blockquote')}`} title="Quote">
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M3 21c3 0 7-1 7-8V5c0-1.25-.756-2.017-2-2H4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2 1 0 1 0 1 1v1c0 1-1 2-2 2s-1 .008-1 1.031V20c0 1 0 1 1 1z"/><path d="M15 21c3 0 7-1 7-8V5c0-1.25-.757-2.017-2-2h-4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2h.75c0 2.25.25 4-2.75 4v3c0 1 0 1 1 1z"/></svg>
          </button>
          <button type="button" onClick={() => setShowLinkModal(true)} className="p-1.5 rounded-lg text-slate-500 hover:bg-sand-100 hover:text-slate-700" title="Link"><Link className="w-4 h-4" /></button>
        </div>
        <EditorContent editor={editor} />
        <div className="px-4 py-2 bg-sand-50 border-t border-sand-200 text-xs text-slate-400 flex justify-between">
          <span>{editor.getText?.()?.length || 0} karakter</span>
          <span>{editor.getText?.()?.split(/\s+/).filter(Boolean).length || 0} kata</span>
        </div>
      </div>

      <InputModal open={showLinkModal} onClose={() => setShowLinkModal(false)} onConfirm={handleLinkConfirm} title="Tambah Tautan" fields={[{ label: 'URL', type: 'url', placeholder: 'https://contoh.com' }]} />
    </div>
  );
}