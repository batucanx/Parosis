import { Home, Wallet, User } from './Icons.jsx'

const tabs = [
  { id: 'home', label: 'Ana Sayfa', Icon: Home },
  { id: 'balance', label: 'Bakiyem', Icon: Wallet },
  { id: 'profile', label: 'Profil', Icon: User },
]

/**
 * Geniş, etiketli alt navigasyon.
 * Her buton ~92px yüksekliğinde — yaşlı kullanıcılar için rahat dokunma hedefi.
 */
export default function BottomNav({ activeTab, onChange }) {
  return (
    <nav
      aria-label="Ana gezinme"
      className="glass-nav absolute inset-x-0 bottom-0 z-30 grid grid-cols-3 gap-2 rounded-t-[2rem] px-3 pb-6 pt-3"
    >
      {tabs.map(({ id, label, Icon }) => {
        const selected = activeTab === id
        return (
          <button
            key={id}
            type="button"
            onClick={() => onChange(id)}
            aria-current={selected ? 'page' : undefined}
            className={[
              'flex h-[74px] flex-col items-center justify-center gap-1.5 rounded-[1.4rem] transition-all duration-200',
              selected
                ? 'bg-brand-600 text-white shadow-[0_10px_22px_-10px_rgba(17,90,75,0.9),0_1px_0_0_rgba(255,255,255,0.28)_inset]'
                : 'text-ink-soft active:bg-white/50',
            ].join(' ')}
          >
            <Icon className="h-6 w-6" />
            <span className={`text-[12.5px] tracking-tight ${selected ? 'font-bold' : 'font-semibold'}`}>
              {label}
            </span>
          </button>
        )
      })}
    </nav>
  )
}
