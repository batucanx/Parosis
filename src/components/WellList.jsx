import { useMemo, useState } from 'react'
import { Search, MapPin, Play, Gauge, Thermometer, Bolt, Signal, Droplet } from './Icons.jsx'
import { wells } from '../data.js'

/* Aktif = yeşil, Deaktif = kırmızı */
const toneClass = {
  green: 'bg-brand-100/90 text-brand-700 border-brand-200',
  gray:  'bg-red-100/90   text-red-600   border-red-200',
}
const toneDot = {
  green: 'bg-brand-500',
  gray:  'bg-red-500',
}

const badgeIcon = {
  Pompa:      Gauge,
  Termik:     Thermometer,
  Enerji:     Bolt,
  Haberleşme: Signal,
}

export default function WellList({ onStart, startedId, onWellEdit, onNavigate }) {
  const [query, setQuery] = useState('')

  const results = useMemo(() => {
    const q = query.trim().toLocaleLowerCase('tr-TR')
    if (!q) return wells
    return wells.filter((w) =>
      [w.ad, w.il, w.ilce].some((f) => f.toLocaleLowerCase('tr-TR').includes(q)),
    )
  }, [query])

  return (
    <div className="flex flex-col gap-3.5">
      {/* Arama kutusu */}
      <div className="glass flex h-[46px] items-center gap-3 rounded-xl px-4">
        <Search className="h-4.5 w-4.5 shrink-0 text-ink-faint" />
        <input
          type="search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Kuyu Ara"
          aria-label="Kuyu ara"
          className="w-full bg-transparent text-[14px] font-semibold tracking-tight text-ink outline-none placeholder:font-medium placeholder:text-ink-faint"
        />
      </div>

      {results.length === 0 ? (
        <div className="glass rounded-[1.3rem] px-5 py-8 text-center">
          <p className="text-[14px] font-bold text-ink">Kuyu bulunamadı</p>
          <p className="mt-1 text-[12.5px] font-medium text-ink-soft">Farklı bir isim veya ilçe deneyin.</p>
        </div>
      ) : (
        <ul className="flex flex-col gap-3">
          {results.map((w) => (
            <li key={w.id}>
              <WellCard
                well={w}
                onStart={onStart}
                started={startedId === w.id}
                onEdit={onWellEdit ? () => onWellEdit(w) : undefined}
                onNavigate={onNavigate}
              />
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}

function WellCard({ well, onStart, started, onEdit, onNavigate }) {
  return (
    <article className="glass overflow-hidden rounded-[1.2rem]">
      {/* Kart gövdesi */}
      <div className="px-4 pt-3.5 pb-3">

        {/* Üst satır: ikon + bilgi + Başlat/Takip Et butonu */}
        <div className="flex items-start gap-2.5">
          {/* Damla ikonu */}
          <span className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-brand-100/80 text-brand-700">
            <Droplet className="h-4.5 w-4.5" />
          </span>

          {/* İsim + konum — tıklanırsa düzenlemeye gider */}
          <button
            type="button"
            onClick={onEdit}
            disabled={!onEdit}
            className="min-w-0 flex-1 text-left disabled:cursor-default"
          >
            <div className="overflow-hidden">
              <h3
                className={`text-[15px] font-extrabold leading-tight tracking-tight text-ink ${
                  well.ad.length > 18 ? 'marquee-text' : 'truncate'
                }`}
              >
                {well.ad}
              </h3>
            </div>
            <div className="mt-0.5 flex items-center gap-1 text-ink-soft">
              <MapPin className="h-[11px] w-[11px] shrink-0" />
              <span className="text-[11.5px] font-semibold">{well.il} / {well.ilce}</span>
            </div>
          </button>

          {/* Başlat / Takip Et — sağ üst köşe */}
          {onStart && (
            <button
              type="button"
              onClick={() => {
                if (started && onNavigate) {
                  onNavigate('home')
                } else {
                  onStart(well)
                }
              }}
              className={[
                'flex shrink-0 items-center gap-1.5 rounded-xl px-3 py-1.5 text-[12px] font-bold text-white transition-all duration-200 active:scale-[0.96]',
                started
                  ? 'bg-sea-600 shadow-[0_6px_14px_-6px_rgba(33,100,142,0.9)]'
                  : 'bg-brand-600 shadow-[0_6px_14px_-6px_rgba(17,90,75,0.9)]',
              ].join(' ')}
            >
              {started ? (
                <>
                  {/* Eye / radar icon */}
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                    <circle cx="12" cy="12" r="3" />
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8Z" />
                  </svg>
                  Takip Et
                </>
              ) : (
                <>
                  <Play className="h-3 w-3" />
                  Başlat
                </>
              )}
            </button>
          )}

          {/* Düzenleme ikonu (onEdit var ama onStart yok) */}
          {!onStart && onEdit && (
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="shrink-0 text-ink-faint" aria-hidden="true">
              <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
              <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5Z" />
            </svg>
          )}
        </div>

        {/* Badge'ler — yatay kaydırmalı */}
        <ul className="no-scrollbar mt-2.5 flex gap-1 overflow-x-auto">
          {well.badges.map((b) => {
            const Icon = badgeIcon[b.label]
            const tone = b.tone === 'blue' ? 'green' : b.tone
            return (
              <li
                key={b.label}
                className={`flex shrink-0 items-center gap-1 rounded-md border px-1.5 py-0.5 ${toneClass[tone]}`}
              >
                <span className={`h-1 w-1 rounded-full ${toneDot[tone]}`} />
                {Icon && <Icon className="h-[10px] w-[10px]" strokeWidth={2.2} />}
                <span className="text-[9.5px] font-bold uppercase tracking-tight">{b.label}</span>
              </li>
            )
          })}
        </ul>
      </div>
    </article>
  )
}
