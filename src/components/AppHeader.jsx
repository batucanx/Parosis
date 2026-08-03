import { LogoMark, Wallet } from './Icons.jsx'
import { formatTL } from '../data.js'

/**
 * Sade üst çubuk: solda logo, sağda tek bir dokunma hedefi olarak
 * "450 TL · Yükle" — tıklanınca Bakiyem sayfasına gider.
 */
export default function AppHeader({ balance, onBalanceClick }) {
  return (
    <header className="flex items-center justify-between gap-3 px-5 pb-3 pt-1">
      <div
        className="glass-soft grid h-[60px] w-[60px] shrink-0 place-items-center rounded-2xl text-brand-600"
        aria-label="Sulama"
      >
        <LogoMark className="h-8 w-8" />
      </div>

      <button
        type="button"
        onClick={onBalanceClick}
        aria-label={`Bakiyeniz ${formatTL(balance)} lira. Bakiye yüklemek için dokunun.`}
        className="glass flex h-[60px] min-w-0 items-center gap-2.5 whitespace-nowrap rounded-2xl pl-4 pr-3 transition-transform duration-200 active:scale-[0.97]"
      >
        <Wallet className="h-5 w-5 shrink-0 text-brand-600" />
        <span className="text-[16px] font-extrabold tracking-tight text-ink">
          {formatTL(balance)} TL
        </span>
        <span className="rounded-xl bg-brand-600 px-3.5 py-2 text-[14px] font-bold text-white">
          Yükle
        </span>
      </button>
    </header>
  )
}
