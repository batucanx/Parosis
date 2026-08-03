import { Home, Wallet, User } from './Icons.jsx'

const tabs = [
  { id: 'home',    label: 'Ana Sayfa', Icon: Home },
  { id: 'balance', label: 'Bakiyem',   Icon: Wallet },
  { id: 'profile', label: 'Profil',    Icon: User },
]

/**
 * Floating damla/pill şeklinde alt navigasyon.
 * Ekranın altına bitişik değil — merkezde yüzer.
 */
export default function BottomNav({ activeTab, onChange }) {
  return (
    <nav
      aria-label="Ana gezinme"
      className="absolute bottom-5 left-1/2 z-30 -translate-x-1/2"
    >
      <div className="glass-nav flex items-center gap-1 rounded-full px-2 py-1.5 shadow-[0_8px_32px_-8px_rgba(8,48,42,0.35),0_2px_8px_-4px_rgba(8,48,42,0.2)]">
        {tabs.map(({ id, label, Icon }) => {
          const selected = activeTab === id
          return (
            <button
              key={id}
              type="button"
              onClick={() => onChange(id)}
              aria-current={selected ? 'page' : undefined}
              className={[
                'flex items-center gap-1.5 rounded-full px-5 py-2 transition-all duration-200 whitespace-nowrap',
                selected
                  ? 'bg-brand-600 text-white shadow-[0_6px_16px_-6px_rgba(17,90,75,0.85),0_1px_0_0_rgba(255,255,255,0.28)_inset]'
                  : 'text-ink-soft active:bg-white/50',
              ].join(' ')}
            >
              <Icon className="h-4.5 w-4.5 shrink-0" />
              <span className={`text-[12px] tracking-tight ${selected ? 'font-bold' : 'font-semibold'}`}>
                {label}
              </span>
            </button>
          )
        })}
      </div>
    </nav>
  )
}
