import { User, Mail, Phone, IdCard } from '../components/Icons.jsx'

/* ---------- Veri ---------- */
const userInfo = [
  { Icon: User,   label: 'Ad Soyad',     value: 'Batuhan Canaracı' },
  { Icon: Mail,   label: 'E-posta',      value: 'batuhancanaraci85@gmail.com' },
  { Icon: IdCard, label: 'Kullanıcı ID', value: 'SLM-48210' },
]

const contactInfo = [
  { Icon: Phone, label: 'Telefon',  value: '0532 118 04 76' },
  { Icon: Mail,  label: 'E-posta', value: 'batuhancanaraci85@gmail.com' },
]

function InfoRow({ Icon, label, value, last }) {
  return (
    <div className={`flex items-center gap-4 py-4 ${!last ? 'border-b border-black/[0.06]' : ''}`}>
      <span className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-brand-100/80 text-brand-700">
        <Icon className="h-5 w-5" />
      </span>
      <div className="min-w-0 flex-1">
        <div className="text-[11.5px] font-semibold text-ink-soft">{label}</div>
        <div className="mt-0.5 truncate text-[14px] font-bold tracking-tight text-ink">{value}</div>
      </div>
    </div>
  )
}

/**
 * PhoneFrame seviyesinde render edilen bottom sheet —
 * navbardan (bottom-0) tüm ekrana kayar, CardsModal gibi.
 */
export default function ProfileSheet({ type, onClose }) {
  const title = type === 'user' ? 'Kullanıcı Bilgileri' : 'İletişim Bilgileri'
  const rows  = type === 'user' ? userInfo : contactInfo

  return (
    <>
      {/* Overlay */}
      <div
        className="absolute inset-0 z-40 bg-black/40 backdrop-blur-[3px]"
        onClick={onClose}
      />

      {/* Sheet — navbardan tüm ekrana kayar */}
      <div
        className="absolute inset-x-0 bottom-0 z-50 flex flex-col rounded-t-[1.8rem] bg-[#f8faf9] shadow-2xl"
        style={{
          height: 'calc(100% - 54px)',
          animation: 'sheetUp 0.35s cubic-bezier(0.22,1,0.36,1)',
        }}
      >
        {/* Handle */}
        <div className="mx-auto mt-3 h-1 w-10 shrink-0 rounded-full bg-black/15" />

        {/* Başlık + kırmızı X */}
        <div className="flex shrink-0 items-center justify-between px-5 py-4">
          <h2 className="text-[17px] font-extrabold tracking-tight text-ink">{title}</h2>
          <button
            type="button"
            onClick={onClose}
            className="grid h-8 w-8 place-items-center rounded-full border border-red-200 bg-white text-red-500 transition-colors active:bg-red-50"
            aria-label="Kapat"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" className="h-4 w-4">
              <path d="M18 6 6 18M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* İçerik */}
        <div className="no-scrollbar flex-1 overflow-y-auto px-5 pb-10">
          {rows.map(({ Icon, label, value }, i) => (
            <InfoRow
              key={label}
              Icon={Icon}
              label={label}
              value={value}
              last={i === rows.length - 1}
            />
          ))}
        </div>
      </div>
    </>
  )
}
