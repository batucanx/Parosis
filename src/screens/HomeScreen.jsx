import { useState } from 'react'
import { CalendarClock, Droplet, ChevronRight, History, Clock } from '../components/Icons.jsx'
import { pastIrrigations, upcomingIrrigations } from '../data.js'

const tabs = [
  { id: 'past', label: 'Geçmiş Sulamalar', Icon: History, data: pastIrrigations },
  { id: 'upcoming', label: 'Gelecek Sulamalar', Icon: CalendarClock, data: upcomingIrrigations },
]

export default function HomeScreen({ onNavigate }) {
  const [activeTab, setActiveTab] = useState('past')
  const current = tabs.find((t) => t.id === activeTab)

  return (
    <div className="screen-in flex flex-col gap-6 px-5 pb-6 pt-2">
      {/* --- İki ana eylem --- */}
      <div className="flex flex-col gap-3.5">
        <BigAction
          tone="green"
          Icon={CalendarClock}
          title="Program Sulama"
          desc="İleri tarihe sulama planla"
          onClick={() => onNavigate('program')}
        />
        <BigAction
          tone="gray"
          Icon={Droplet}
          title="Anlık Sulama"
          desc="Kuyuyu hemen çalıştır"
          onClick={() => onNavigate('instant')}
        />
      </div>

      {/* --- Geçmiş / Gelecek sulamalar --- */}
      <section>
        <div className="grid grid-cols-2 gap-3">
          {tabs.map((t) => {
            const active = t.id === activeTab
            return (
              <button
                key={t.id}
                type="button"
                onClick={() => setActiveTab(t.id)}
                aria-pressed={active}
                className={[
                  'flex items-center gap-2.5 rounded-2xl px-3.5 py-3.5 text-left transition-all duration-200 active:scale-[0.98]',
                  active
                    ? 'bg-sea-600 shadow-[0_14px_28px_-14px_rgba(33,100,142,0.9),0_1px_0_0_rgba(255,255,255,0.3)_inset]'
                    : 'glass',
                ].join(' ')}
              >
                <t.Icon className={`h-5 w-5 shrink-0 ${active ? 'text-white' : 'text-ink-faint'}`} />
                <span
                  className={`text-[13.5px] font-bold leading-tight tracking-tight ${
                    active ? 'text-white' : 'text-ink-soft'
                  }`}
                >
                  {t.label}
                </span>
              </button>
            )
          })}
        </div>

        <ul className="mt-3.5 flex flex-col gap-3">
          {current.data.map((item) => (
            <li key={item.id}>
              <RecordCard item={item} {...recordProps(activeTab, item)} />
            </li>
          ))}
        </ul>
      </section>
    </div>
  )
}

function recordProps(tabId, item) {
  if (tabId === 'past') {
    return {
      tone: 'gray',
      sub: `${item.ilce} · ${item.sure} sürdü`,
      trailing: item.su,
      trailingLabel: 'kullanıldı',
    }
  }
  return {
    tone: 'blue',
    sub: item.ilce,
    trailing: item.sure,
    trailingLabel: 'planlandı',
  }
}

/* ------------------------------------------------------------- Ana butonlar */

const actionTone = {
  green: {
    surface:
      'bg-brand-600 shadow-[0_18px_34px_-16px_rgba(17,90,75,0.95),0_1px_0_0_rgba(255,255,255,0.3)_inset]',
    icon: 'bg-white/20',
  },
  gray: {
    surface:
      'bg-mist-600 shadow-[0_18px_34px_-16px_rgba(79,103,99,0.9),0_1px_0_0_rgba(255,255,255,0.3)_inset]',
    icon: 'bg-white/20',
  },
}

function BigAction({ tone, Icon, title, desc, onClick }) {
  const t = actionTone[tone]
  return (
    <button
      type="button"
      onClick={onClick}
      className={`flex w-full items-center gap-4 rounded-[1.6rem] p-5 text-left transition-transform duration-200 active:scale-[0.98] ${t.surface}`}
    >
      <span className={`grid h-14 w-14 shrink-0 place-items-center rounded-2xl ${t.icon}`}>
        <Icon className="h-7 w-7 text-white" />
      </span>
      <span className="min-w-0 flex-1">
        <span className="block text-[18px] font-extrabold leading-tight tracking-tight text-white">
          {title}
        </span>
        <span className="mt-1 block text-[13.5px] font-medium text-white/85">{desc}</span>
      </span>
      <ChevronRight className="h-6 w-6 shrink-0 text-white/80" />
    </button>
  )
}

/* --------------------------------------------------------------- Listeler */

const recordTone = {
  gray: 'bg-mist-100/80 text-mist-600',
  blue: 'bg-sea-100/80 text-sea-700',
}

function RecordCard({ item, tone, sub, trailing, trailingLabel }) {
  return (
    <article className="glass flex items-center gap-3.5 rounded-[1.4rem] p-4">
      <span className={`grid h-12 w-12 shrink-0 place-items-center rounded-2xl ${recordTone[tone]}`}>
        <Clock className="h-6 w-6" />
      </span>

      <div className="min-w-0 flex-1">
        <h3 className="truncate text-[15.5px] font-extrabold leading-tight tracking-tight text-ink">
          {item.kuyu}
        </h3>
        <p className="mt-1 truncate text-[13px] font-semibold text-ink-soft">
          {item.tarih} · {item.saat}
        </p>
        <p className="mt-0.5 truncate text-[12px] font-medium text-ink-faint">{sub}</p>
      </div>

      <div className="shrink-0 text-right">
        <div className="text-[14px] font-extrabold tracking-tight text-ink">{trailing}</div>
        <div className="mt-0.5 text-[11px] font-semibold text-ink-faint">{trailingLabel}</div>
      </div>
    </article>
  )
}
