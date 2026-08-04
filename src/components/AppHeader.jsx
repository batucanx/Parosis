import { useState } from 'react'
import { Wallet, Menu, X, ListChecks, History, Droplets, ChevronRight } from './Icons.jsx'
import { formatTL } from '../data.js'

/* ---------- Menü öğeleri ---------- */
const menuItems = [
  {
    id: 'well-requests',
    Icon: Droplets,
    label: 'Kuyu Taleplerim',
    desc: 'Açık ve bekleyen talepleriniz',
    color: 'text-brand-700',
    bg: 'bg-brand-100',
  },
  {
    id: 'requests',
    Icon: ListChecks,
    label: 'Talepler',
    desc: 'Tüm sulama talepleri',
    color: 'text-sea-700',
    bg: 'bg-sea-100',
  },
  {
    id: 'past-irrigations',
    Icon: History,
    label: 'Geçmiş Sulamalar',
    desc: 'Tamamlanan sulama kayıtları',
    color: 'text-mist-600',
    bg: 'bg-mist-100',
  },
]

/**
 * Üst çubuk: solda hamburger, ortada logo, sağda bakiye — hepsi sayfaya gömülü, kart yok.
 * Hamburger tıklanınca tam ekran hızlı erişim menüsü açılır.
 */
export default function AppHeader({ balance, onBalanceClick }) {
  const [menuOpen, setMenuOpen] = useState(false)

  return (
    <>
      <header className="relative flex items-center justify-between px-4 pb-3 pt-2">

        {/* Hamburger — sol, gömülü */}
        <button
          type="button"
          id="app-menu-toggle"
          onClick={() => setMenuOpen(true)}
          aria-label="Menü"
          className="grid h-10 w-10 shrink-0 place-items-center text-brand-700 transition-transform duration-200 active:scale-90"
        >
          <Menu className="h-6 w-6" />
        </button>

        {/* Logo — tam ortada, gömülü */}
        <div className="pointer-events-none absolute inset-x-0 flex justify-center">
          <img src="/logo.svg" alt="Parosis" className="h-7 w-auto" />
        </div>

        {/* Bakiye — sağ, gömülü, tıklanınca Bakiyem'e gider */}
        <button
          type="button"
          onClick={onBalanceClick}
          aria-label={`Bakiyeniz ${formatTL(balance)} lira. Bakiyem sayfasına git.`}
          className="flex shrink-0 items-center gap-1.5 text-ink transition-transform duration-200 active:scale-95"
        >
          <Wallet className="h-4.5 w-4.5 shrink-0 text-brand-600" />
          <span className="text-[14px] font-extrabold tracking-tight">
            {formatTL(balance)} ₺
          </span>
        </button>
      </header>

      {/* ════════════════════════════════════════════════
          TAM EKRAN HIZLI ERİŞİM MENÜSÜ
      ════════════════════════════════════════════════ */}
      {menuOpen && (
        <div
          className="absolute inset-0 z-50 flex flex-col bg-[#f8faf9]"
          style={{ animation: 'drawerLeft 0.32s cubic-bezier(0.22,1,0.36,1)' }}
        >
          {/* Üst alan — sayfaya gömülü, ayrı bir kart yüzeyi yok */}
          <div className="shrink-0 px-5 pb-6 pt-9">
            <div className="flex items-center justify-between gap-3">
              <div>
                <img src="/logo.svg" alt="Parosis" className="h-11 w-auto" />
              </div>
              <button
                type="button"
                onClick={() => setMenuOpen(false)}
                className="grid h-9 w-9 shrink-0 place-items-center rounded-full bg-black/[0.06] text-ink-soft transition-colors active:bg-black/[0.12]"
                aria-label="Kapat"
              >
                <X className="h-4.5 w-4.5" />
              </button>
            </div>
          </div>

          {/* Menü öğeleri */}
          <div className="no-scrollbar flex flex-1 flex-col overflow-y-auto px-5 py-3">
            {menuItems.map((item, i) => (
              <button
                key={item.id}
                id={`menu-item-${item.id}`}
                type="button"
                onClick={() => setMenuOpen(false)}
                className={`flex items-center gap-4 py-4 text-left transition-colors active:bg-black/[0.03] ${
                  i < menuItems.length - 1 ? 'border-b border-black/[0.07]' : ''
                }`}
              >
                <span className={`grid h-11 w-11 shrink-0 place-items-center rounded-xl ${item.bg} ${item.color}`}>
                  <item.Icon className="h-5 w-5" />
                </span>
                <div className="min-w-0 flex-1">
                  <div className="text-[15px] font-bold tracking-tight text-ink">{item.label}</div>
                  <div className="mt-0.5 text-[12px] font-medium text-ink-soft">{item.desc}</div>
                </div>
                <ChevronRight className="h-4 w-4 shrink-0 text-ink-faint" />
              </button>
            ))}
          </div>

          {/* Alt alan */}
          <div className="shrink-0 border-t border-black/[0.06] px-5 py-4 text-center">
            <div className="text-[11.5px] font-medium text-ink-faint">Sulama Yönetim Sistemi v1.0</div>
          </div>

          <style>{`
            @keyframes drawerLeft {
              from { transform: translateX(-100%); }
              to   { transform: translateX(0); }
            }
          `}</style>
        </div>
      )}
    </>
  )
}
