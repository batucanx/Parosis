import { Wallet } from './Icons.jsx'
import { formatTL } from '../data.js'

/**
 * Sade üst çubuk: solda logo, sağda tek bir dokunma hedefi olarak
 * "450 TL · Yükle" — tıklanınca Bakiyem sayfasına gider.
 */
export default function AppHeader({ balance, onBalanceClick }) {
  return (
    <header className="flex items-center justify-between gap-3 px-5 pb-3 pt-1">
      <div
        className="glass-soft flex h-[50px] w-[130px] shrink-0 items-center gap-2 rounded-xl px-3"
        aria-label="Sulama"
      >
        {/* Damla ikonu */}
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="shrink-0 text-brand-600" aria-hidden="true">
          <path d="M12 3.2s5.8 5.5 5.8 9.5a5.8 5.8 0 1 1-11.6 0C6.2 8.7 12 3.2 12 3.2Z" />
          <path d="M10.1 15.6c0-2.7 1.9-4.6 4.6-4.8.2 2.7-1.8 4.7-4.6 4.8Z" />
        </svg>
        {/* Şirket adı — gerçek logo gelince buraya img konur */}
        <span className="text-[15px] font-extrabold tracking-tight text-brand-700">
          Sulama
        </span>
      </div>

      <button
        type="button"
        onClick={onBalanceClick}
        aria-label={`Bakiyeniz ${formatTL(balance)} lira. Bakiye yüklemek için dokunun.`}
        className="glass flex h-[50px] min-w-0 items-center gap-2 whitespace-nowrap rounded-xl pl-3.5 pr-2.5 transition-transform duration-200 active:scale-[0.97]"
      >
        <Wallet className="h-4.5 w-4.5 shrink-0 text-brand-600" />
        <span className="text-[14px] font-extrabold tracking-tight text-ink">
          {formatTL(balance)} TL
        </span>
        <span className="rounded-lg bg-brand-600 px-3 py-1.5 text-[12.5px] font-bold text-white">
          Yükle
        </span>
      </button>
    </header>
  )
}
