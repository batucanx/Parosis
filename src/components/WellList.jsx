import { useMemo, useState } from 'react'
import { Search, MapPin, Play, Gauge, Thermometer, Bolt, Signal } from './Icons.jsx'
import { wells } from '../data.js'

/* Tailwind sınıfları statik olmalı — ton eşlemesi tam sınıf adlarıyla tutuluyor. */
const toneClass = {
  green: 'bg-brand-100/80 text-brand-700 border-brand-200',
  blue: 'bg-sea-100/80 text-sea-700 border-sea-200',
  gray: 'bg-mist-100/80 text-mist-600 border-mist-200',
}

const badgeIcon = {
  Pompa: Gauge,
  Termik: Thermometer,
  Enerji: Bolt,
  Haberleşme: Signal,
}

/**
 * "Program Sulama" ve "Anlık Sulama" ekranlarının ortak gövdesi.
 * Tek fark: onStart verildiğinde her kartta büyük bir "Başlat" butonu çıkar.
 */
export default function WellList({ onStart, startedId }) {
  const [query, setQuery] = useState('')

  const results = useMemo(() => {
    const q = query.trim().toLocaleLowerCase('tr-TR')
    if (!q) return wells
    return wells.filter((w) =>
      [w.ad, w.il, w.ilce].some((f) => f.toLocaleLowerCase('tr-TR').includes(q)),
    )
  }, [query])

  return (
    <div className="flex flex-col gap-4">
      {/* Arama kutusu */}
      <div className="glass flex h-16 items-center gap-3 rounded-2xl px-4">
        <Search className="h-5 w-5 shrink-0 text-ink-faint" />
        <input
          type="search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Kuyu Ara"
          aria-label="Kuyu ara"
          className="w-full bg-transparent text-[16px] font-semibold tracking-tight text-ink outline-none placeholder:font-medium placeholder:text-ink-faint"
        />
      </div>

      <p className="px-1 text-[13px] font-semibold text-ink-soft" aria-live="polite">
        {results.length} kuyu listeleniyor
      </p>

      {results.length === 0 ? (
        <div className="glass rounded-[1.5rem] px-5 py-10 text-center">
          <p className="text-[15.5px] font-bold text-ink">Kuyu bulunamadı</p>
          <p className="mt-1.5 text-[13.5px] font-medium text-ink-soft">
            Farklı bir isim veya ilçe deneyin.
          </p>
        </div>
      ) : (
        <ul className="flex flex-col gap-4">
          {results.map((w) => (
            <li key={w.id}>
              <WellCard well={w} onStart={onStart} started={startedId === w.id} />
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}

function WellCard({ well, onStart, started }) {
  return (
    <article className="glass rounded-[1.5rem] p-5">
      <h3 className="text-[17.5px] font-extrabold leading-tight tracking-tight text-ink">
        {well.ad}
      </h3>

      <div className="mt-1.5 flex items-center gap-2 text-ink-soft">
        <MapPin className="h-[17px] w-[17px] shrink-0" />
        <span className="text-[14.5px] font-semibold">
          {well.il} / {well.ilce}
        </span>
      </div>

      <ul className="mt-4 grid grid-cols-2 justify-items-start gap-2">
        {well.badges.map((b) => {
          const Icon = badgeIcon[b.label]
          return (
            <li
              key={b.label}
              className={`flex items-center gap-1.5 rounded-xl border px-2.5 py-1.5 ${toneClass[b.tone]}`}
            >
              {Icon && <Icon className="h-[15px] w-[15px]" strokeWidth={2} />}
              <span className="text-[12px] font-bold tracking-tight">{b.label}</span>
            </li>
          )
        })}
      </ul>

      {onStart && (
        <button
          type="button"
          onClick={() => onStart(well)}
          className={[
            'mt-5 flex h-16 w-full items-center justify-center gap-2.5 rounded-2xl text-[17px] font-extrabold tracking-tight text-white transition-all duration-200 active:scale-[0.98]',
            started
              ? 'bg-sea-600 shadow-[0_12px_26px_-12px_rgba(33,100,142,0.95)]'
              : 'bg-brand-600 shadow-[0_12px_26px_-12px_rgba(17,90,75,0.95)]',
          ].join(' ')}
        >
          <Play className="h-6 w-6" />
          {started ? 'Sulama Başladı' : 'Başlat'}
        </button>
      )}
    </article>
  )
}
