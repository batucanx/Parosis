import PageHeading from '../components/PageHeading.jsx'
import { ArrowLeft } from '../components/Icons.jsx'

export default function WellEditScreen({ well, onBack }) {
  return (
    <div className="screen-in flex flex-col gap-5 px-5 pb-6 pt-2">
      <PageHeading
        title={well?.ad ?? 'Kuyu Düzenle'}
        subtitle="Kuyu bilgilerini güncelleyin"
        onBack={onBack}
      />

      {/* Yakında gelecek içerik placeholder */}
      <div className="glass flex flex-col items-center justify-center gap-3 rounded-[1.4rem] px-6 py-14 text-center">
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" className="text-ink-faint" aria-hidden="true">
          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
          <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5Z" />
        </svg>
        <p className="text-[15px] font-bold text-ink">Düzenleme Ekranı</p>
        <p className="text-[13px] font-medium text-ink-soft">
          Bu bölüm yakında aktif olacak.
        </p>
      </div>
    </div>
  )
}
