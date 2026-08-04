import { useState, useMemo } from 'react'
import { Plus, X, ChevronDown } from '../components/Icons.jsx'
import { statement, formatTL } from '../data.js'

/* Aylar listesi — Türkçe */
const MONTHS = [
  { value: 1,  label: 'Ocak' },
  { value: 2,  label: 'Şubat' },
  { value: 3,  label: 'Mart' },
  { value: 4,  label: 'Nisan' },
  { value: 5,  label: 'Mayıs' },
  { value: 6,  label: 'Haziran' },
  { value: 7,  label: 'Temmuz' },
  { value: 8,  label: 'Ağustos' },
  { value: 9,  label: 'Eylül' },
  { value: 10, label: 'Ekim' },
  { value: 11, label: 'Kasım' },
  { value: 12, label: 'Aralık' },
]

const availableYears = [...new Set(statement.map((r) => r.year))].sort((a, b) => b - a)

export default function BalanceScreen({ balance, onTopUp, lastTopUp }) {
  const [filterYear,    setFilterYear]    = useState('all')
  const [filterMonth,   setFilterMonth]   = useState('all')
  const [noticeDismissed, setNoticeDismissed] = useState(false)

  const filteredStatement = useMemo(() => {
    return statement.filter((row) => {
      const yearOk  = filterYear  === 'all' || row.year  === Number(filterYear)
      const monthOk = filterMonth === 'all' || row.month === Number(filterMonth)
      return yearOk && monthOk
    })
  }, [filterYear, filterMonth])

  const showNotice = lastTopUp && !noticeDismissed

  return (
    <div className="screen-in flex flex-col gap-5 px-5 pb-6 pt-2">
      <h1 className="px-1 text-[21px] font-extrabold tracking-tight text-ink">Bakiyem</h1>

      {/* Kapatılabilir bildirim */}
      {showNotice && (
        <div
          role="status"
          className="flex items-center gap-3 rounded-2xl border border-brand-200 bg-brand-100/85 p-4"
        >
          <span className="grid h-10 w-10 shrink-0 place-items-center rounded-full bg-brand-600 text-white">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5">
              <path d="m5 12.6 4.6 4.6L19 6.8" />
            </svg>
          </span>
          <p className="flex-1 text-[14px] font-bold leading-snug text-brand-700">
            {formatTL(lastTopUp)} TL bakiyenize eklendi.
          </p>
          <button
            type="button"
            onClick={() => setNoticeDismissed(true)}
            className="grid h-7 w-7 shrink-0 place-items-center rounded-full bg-brand-200/60 text-brand-700 transition-colors active:bg-brand-300/60"
            aria-label="Bildirimi kapat"
          >
            <X className="h-3.5 w-3.5" />
          </button>
        </div>
      )}

      {/* --- Kullanılabilir bakiye --- */}
      <section className="glass rounded-[1.75rem] px-6 py-7 text-center">
        <h2 className="text-[15px] font-bold tracking-tight text-ink-soft">Kullanılabilir Bakiye</h2>
        <p className="mt-2.5 text-[42px] font-extrabold leading-none tracking-tight text-ink">
          {formatTL(balance)}
          <span className="ml-2 text-[20px] font-bold text-ink-soft">TL</span>
        </p>
      </section>

      <button
        type="button"
        onClick={onTopUp}
        className="flex h-[52px] w-full items-center justify-center gap-2.5 rounded-[1.1rem] bg-brand-600 text-[15px] font-extrabold tracking-tight text-white shadow-[0_12px_24px_-12px_rgba(17,90,75,0.9),0_1px_0_0_rgba(255,255,255,0.3)_inset] transition-transform duration-200 active:scale-[0.98]"
      >
        <Plus className="h-5 w-5" />
        Bakiye Yükle
      </button>

      {/* --- Hesap ekstresi --- */}
      <section className="mt-2">
        <div className="flex items-center justify-between gap-2 px-1">
          <h2 className="text-[17px] font-extrabold tracking-tight text-ink">Hesap Ekstresi</h2>

          {/* Filtreleme */}
          <div className="flex items-center gap-1.5">
            <div className="relative">
              <select
                value={filterYear}
                onChange={(e) => { setFilterYear(e.target.value); setFilterMonth('all') }}
                className="appearance-none rounded-lg bg-mist-100/50 py-1.5 pl-3 pr-7 text-[12px] font-bold text-ink-soft outline-none focus:ring-2 focus:ring-brand-500"
              >
                <option value="all">Tüm Yıllar</option>
                {availableYears.map((y) => (
                  <option key={y} value={y}>{y}</option>
                ))}
              </select>
              <ChevronDown className="pointer-events-none absolute right-1.5 top-1/2 h-3 w-3 -translate-y-1/2 text-ink-faint" />
            </div>

            <div className="relative">
              <select
                value={filterMonth}
                onChange={(e) => setFilterMonth(e.target.value)}
                className="appearance-none rounded-lg bg-mist-100/50 py-1.5 pl-3 pr-7 text-[12px] font-bold text-ink-soft outline-none focus:ring-2 focus:ring-brand-500"
              >
                <option value="all">Tüm Aylar</option>
                {MONTHS.map((m) => (
                  <option key={m.value} value={m.value}>{m.label}</option>
                ))}
              </select>
              <ChevronDown className="pointer-events-none absolute right-1.5 top-1/2 h-3 w-3 -translate-y-1/2 text-ink-faint" />
            </div>
          </div>
        </div>

        {/* Sütun başlıkları — sayfaya gömülü, kart değil */}
        {filteredStatement.length > 0 && (
          <div
            className="mt-4 grid gap-2 px-2 text-[10.5px] font-bold uppercase tracking-widest text-ink-faint"
            style={{ gridTemplateColumns: '1fr 1.9fr 1fr 1fr' }}
          >
            <span>Tarih</span>
            <span>Açıklama</span>
            <span className="text-right">Yükleme</span>
            <span className="text-right">Harcama</span>
          </div>
        )}

        {/* Kart listesi — her satır ayrı kart */}
        <div className="mt-2.5 flex flex-col gap-2">
          {filteredStatement.length === 0 ? (
            <div className="py-8 text-center text-[13px] font-semibold text-ink-faint">
              Bu döneme ait işlem bulunamadı.
            </div>
          ) : (
            filteredStatement.map((row) => (
              <div
                key={row.id}
                className="grid items-center gap-2 rounded-2xl border border-slate-100 bg-white px-3 py-3.5 shadow-sm"
                style={{ gridTemplateColumns: '1fr 1.9fr 1fr 1fr' }}
              >
                <span className="text-[12px] font-semibold text-ink-faint">{row.tarih}</span>
                <span className="truncate text-[13px] font-bold tracking-tight text-ink">{row.aciklama}</span>
                <span className="text-right text-[12.5px] font-extrabold tracking-tight text-brand-600">
                  {row.yukleme ? `+${formatTL(row.yukleme)}` : '—'}
                </span>
                <span className="text-right text-[12.5px] font-extrabold tracking-tight text-red-500">
                  {row.harcama ? `−${formatTL(row.harcama)}` : '—'}
                </span>
              </div>
            ))
          )}
        </div>

        <p className="mt-3 px-1 text-[12px] font-medium text-ink-faint">Tutarlar TL cinsindendir.</p>
      </section>
    </div>
  )
}
