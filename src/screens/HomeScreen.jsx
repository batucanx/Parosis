import { useState } from 'react'
import {
  CalendarClock, Droplet, ChevronRight, Clock,
  Gauge, Thermometer, Bolt, Signal, X,
} from '../components/Icons.jsx'
import { pastIrrigations, upcomingIrrigations, wells } from '../data.js'

/* Aktif kuyu mock verisi — Ova Kuyu 1 */
const activeWell = wells[0]

const tabs = [
  { id: 'active',   label: 'Aktif Sulamalar',   count: 1 },
  { id: 'upcoming', label: 'Gelecek Sulamalar',  count: null },
]

/* Badge rengi: green → beyaz zemin yeşil metin, gray → beyaz zemin kırmızı metin */
const badgeClass = {
  green: 'bg-white text-brand-700 border-brand-200/60',
  gray:  'bg-white text-red-600   border-red-200/60',
}
const badgeDot = {
  green: 'bg-brand-500',
  gray:  'bg-red-500',
}
const badgeIcon = { Pompa: Gauge, Termik: Thermometer, Enerji: Bolt, Haberleşme: Signal }

export default function HomeScreen({ onNavigate }) {
  const [activeTab, setActiveTab] = useState('active')

  return (
    <div className="screen-in flex flex-col gap-5 px-5 pb-6 pt-2">

      {/* --- Ana eylem butonları --- */}
      <div className="flex flex-col gap-2.5">
        <BigAction
          tone="gray"
          Icon={CalendarClock}
          title="Program Sulama"
          desc="İleri tarihe sulama planla"
          onClick={() => onNavigate('program')}
        />
        <BigAction
          tone="green"
          Icon={Droplet}
          title="Anlık Sulama"
          desc="Kuyuyu hemen çalıştır"
          onClick={() => onNavigate('instant')}
        />
      </div>

      {/* --- Sekme butonları --- */}
      <section>
        <div className="flex gap-2">
          {tabs.map((t) => {
            const active = t.id === activeTab
            return (
              <button
                key={t.id}
                type="button"
                onClick={() => setActiveTab(t.id)}
                aria-pressed={active}
                className={[
                  'flex h-9 flex-1 items-center justify-center gap-2 rounded-2xl text-[13px] font-bold tracking-tight transition-all duration-200 active:scale-[0.98] whitespace-nowrap',
                  active
                    ? 'bg-sea-600 text-white shadow-[0_10px_22px_-10px_rgba(33,100,142,0.9)]'
                    : 'glass text-ink-soft',
                ].join(' ')}
              >
                {t.count != null && active && (
                  <span className="flex h-4 w-4 items-center justify-center rounded-full bg-white/25 text-[10px] font-extrabold text-white">
                    {t.count}
                  </span>
                )}
                {t.label}
              </button>
            )
          })}
        </div>

        {/* --- İçerik --- */}
        <div className="mt-3">
          {activeTab === 'active' ? (
            <ActiveIrrigationCard />
          ) : (
            <ul className="flex flex-col gap-2.5">
              {upcomingIrrigations.map((item) => (
                <li key={item.id}>
                  <RecordCard
                    item={item}
                    tone="blue"
                    sub={item.ilce}
                    trailing={item.sure}
                    trailingLabel="planlandı"
                  />
                </li>
              ))}
            </ul>
          )}
        </div>
      </section>
    </div>
  )
}

/* ── Aktif sulama kartı ── */
function ActiveIrrigationCard() {
  return (
    <article className="rounded-[1.3rem] bg-gradient-to-br from-brand-600 to-brand-800 p-4 shadow-[0_14px_30px_-12px_rgba(17,90,75,0.8)]">
      {/* Üst satır */}
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-2">
          <span className="grid h-8 w-8 shrink-0 place-items-center rounded-xl bg-white/20">
            <Droplet className="h-4.5 w-4.5 text-white" />
          </span>
          <span className="text-[11px] font-semibold text-white/75">Anlık sulama</span>
        </div>
        <div className="text-right">
          <div className="text-[9px] font-bold uppercase tracking-widest text-white/50">Süre</div>
          <div className="text-[13px] font-extrabold text-white">∞ Sınırsız</div>
        </div>
      </div>

      <div className="mt-3 overflow-hidden">
        <h3
          className={`text-[20px] font-extrabold leading-tight tracking-tight text-white ${
            activeWell.ad.length > 16 ? 'marquee-text' : ''
          }`}
        >
          {activeWell.ad}
        </h3>
      </div>

      {/* Badge'ler */}
      <ul className="no-scrollbar mt-3 flex gap-1.5 overflow-x-auto">
        {activeWell.badges.map((b) => {
          const Icon = badgeIcon[b.label]
          return (
            <li
              key={b.label}
              className={`flex items-center gap-1.5 rounded-lg border px-2 py-1 ${badgeClass[b.tone]}`}
            >
              <span className={`h-1.5 w-1.5 rounded-full ${badgeDot[b.tone]}`} />
              {Icon && <Icon className="h-[11px] w-[11px]" strokeWidth={2.2} />}
              <span className="text-[10.5px] font-bold uppercase tracking-tight">{b.label}</span>
            </li>
          )
        })}
      </ul>

      {/* Durum + kullanım */}
      <div className="mt-3.5 flex items-center justify-between">
        <div className="flex items-center gap-1.5">
          <span className="h-2 w-2 animate-pulse rounded-full bg-white" />
          <span className="text-[12px] font-semibold text-white">Sulama çalışıyor</span>
        </div>
        <span className="text-[11px] font-semibold text-white">Kullanım 02:34:11</span>
      </div>

      {/* Durdur butonu */}
      <button
        type="button"
        className="mt-3 flex h-10 w-full items-center justify-center gap-2 rounded-2xl bg-white text-[13px] font-bold text-brand-700 shadow-sm transition-colors active:bg-red-50 active:text-red-600"
      >
        {/* Pause icon */}
        <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <rect x="5" y="4" width="4" height="16" rx="1.5" />
          <rect x="15" y="4" width="4" height="16" rx="1.5" />
        </svg>
        Durdur
      </button>
    </article>
  )
}

/* ── Ana eylem butonları ── */
const actionTone = {
  green: {
    surface: 'bg-brand-600 shadow-[0_14px_28px_-14px_rgba(17,90,75,0.9),0_1px_0_0_rgba(255,255,255,0.28)_inset]',
    icon: 'bg-white/20',
  },
  gray: {
    surface: 'bg-mist-600 shadow-[0_14px_28px_-14px_rgba(79,103,99,0.85),0_1px_0_0_rgba(255,255,255,0.25)_inset]',
    icon: 'bg-white/20',
  },
}

function BigAction({ tone, Icon, title, desc, onClick }) {
  const t = actionTone[tone]
  return (
    <button
      type="button"
      onClick={onClick}
      className={`flex w-full items-center gap-3.5 rounded-[1.3rem] p-4 text-left transition-transform duration-200 active:scale-[0.98] ${t.surface}`}
    >
      <span className={`grid h-11 w-11 shrink-0 place-items-center rounded-xl ${t.icon}`}>
        <Icon className="h-6 w-6 text-white" />
      </span>
      <span className="min-w-0 flex-1">
        <span className="block text-[15px] font-extrabold leading-tight tracking-tight text-white">
          {title}
        </span>
        <span className="mt-0.5 block text-[12px] font-medium text-white/80">{desc}</span>
      </span>
      <ChevronRight className="h-5 w-5 shrink-0 text-white/70" />
    </button>
  )
}

/* ── Gelecek sulama kartı ── */
const recordTone = { blue: 'bg-sea-100/80 text-sea-700' }

function RecordCard({ item, tone, sub, trailing, trailingLabel }) {
  return (
    <article className="glass flex items-center gap-3.5 rounded-[1.2rem] p-3.5">
      <span className={`grid h-10 w-10 shrink-0 place-items-center rounded-xl ${recordTone[tone] ?? 'bg-mist-100/80 text-mist-600'}`}>
        <Clock className="h-5 w-5" />
      </span>
      <div className="min-w-0 flex-1">
        <h3 className="truncate text-[14px] font-extrabold leading-tight tracking-tight text-ink">
          {item.kuyu}
        </h3>
        <p className="mt-0.5 truncate text-[12px] font-semibold text-ink-soft">
          {item.tarih} · {item.saat}
        </p>
        <p className="mt-0.5 truncate text-[11px] font-medium text-ink-faint">{sub}</p>
      </div>
      <div className="shrink-0 text-right">
        <div className="text-[13px] font-extrabold tracking-tight text-ink">{trailing}</div>
        <div className="mt-0.5 text-[10.5px] font-semibold text-ink-faint">{trailingLabel}</div>
      </div>
    </article>
  )
}
