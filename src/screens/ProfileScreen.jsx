import {
  User,
  Phone,
  CreditCard,
  ChevronRight,
} from '../components/Icons.jsx'

/* ---------- Menü satır butonu ---------- */
function MenuRow({ Icon, label, subtitle, onClick, last }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`flex w-full items-center gap-4 py-4 text-left transition-colors active:bg-brand-50/40 ${
        !last ? 'border-b border-black/[0.06]' : ''
      }`}
    >
      <span className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-brand-100/80 text-brand-700">
        <Icon className="h-5 w-5" />
      </span>
      <div className="flex-1 min-w-0">
        <div className="text-[14.5px] font-bold tracking-tight text-ink">{label}</div>
        {subtitle && (
          <div className="mt-0.5 text-[12px] font-medium text-ink-soft">{subtitle}</div>
        )}
      </div>
      {/* > simgesi — düzenlenebilirlik göstergesi */}
      <ChevronRight className="h-4 w-4 shrink-0 text-ink-faint" />
    </button>
  )
}

/* ---------- Ana ekran ---------- */
export default function ProfileScreen({ onOpenCards, onScrollTop, onOpenSheet }) {
  const open = (type) => {
    onScrollTop?.()
    onOpenSheet?.(type)
  }

  return (
    <div className="screen-in flex flex-col gap-5 px-5 pb-6 pt-2">

      {/* Profil avatar + isim */}
      <div className="flex items-center gap-4 px-1 pt-1">
        <div className="grid h-14 w-14 shrink-0 place-items-center rounded-full bg-gradient-to-br from-brand-400 to-brand-600 text-[16px] font-extrabold text-white shadow-lg">
          BC
        </div>
        <div>
          <div className="text-[17px] font-extrabold tracking-tight text-ink">Batuhan Canaracı</div>
          <div className="text-[12.5px] font-semibold text-ink-soft">SLM-48210 · Aktif Üye</div>
        </div>
      </div>

      {/* --- Hesap bölümleri (flat liste) --- */}
      <section className="rounded-[1.4rem] border border-black/[0.06] bg-white/80 px-5 shadow-sm">
        <MenuRow
          Icon={User}
          label="Kullanıcı Bilgileri"
          subtitle="Ad, e-posta, ID"
          onClick={() => open('user')}
        />
        <MenuRow
          Icon={Phone}
          label="İletişim Bilgileri"
          subtitle="Telefon, e-posta"
          onClick={() => open('contact')}
        />
        <MenuRow
          Icon={CreditCard}
          label="Kayıtlı Kartlar"
          subtitle="Ödeme yöntemleriniz"
          onClick={() => { onScrollTop?.(); onOpenCards?.() }}
          last
        />
      </section>
    </div>
  )
}
