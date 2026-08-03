import { Globe, ChevronRight, User, Mail, Phone, IdCard } from '../components/Icons.jsx'

const sites = [
  { name: 'Ova Tarım', url: 'ovatarim.com.tr', connected: true },
  { name: 'Sera Kontrol', url: 'panel.seratek.io', connected: true },
  { name: 'Damla Notları', url: 'damlanotlari.com', connected: false },
]

const info = [
  { Icon: User, label: 'Ad Soyad', value: 'Batuhan Canaracı' },
  { Icon: Phone, label: 'Telefon', value: '0532 118 04 76' },
  { Icon: Mail, label: 'E-posta', value: 'batuhancanaraci85@gmail.com' },
  { Icon: IdCard, label: 'Kullanıcı ID', value: 'SLM-48210' },
]

export default function ProfileScreen() {
  const connected = sites.filter((s) => s.connected).length

  return (
    <div className="screen-in flex flex-col gap-5 px-5 pb-6 pt-2">
      <header className="flex items-center justify-between gap-4 px-1">
        <h1 className="text-[21px] font-extrabold tracking-tight text-ink">Profil</h1>
        <div className="grid h-14 w-14 shrink-0 place-items-center rounded-full bg-brand-100 text-[16px] font-extrabold tracking-tight text-brand-700">
          BC
        </div>
      </header>

      {/* --- Web siteleri --- */}
      <section>
        <div className="flex items-baseline justify-between gap-3 px-1">
          <h2 className="text-[17px] font-extrabold tracking-tight text-ink">Web Siteleri</h2>
          <span className="text-[13px] font-semibold text-ink-soft">
            {connected}/{sites.length} bağlı
          </span>
        </div>

        <ul className="mt-3.5 flex flex-col gap-3">
          {sites.map((site) => (
            <li key={site.url}>
              <button
                type="button"
                className="glass flex w-full items-center gap-4 rounded-[1.4rem] p-4 text-left transition-transform duration-200 active:scale-[0.985]"
              >
                <span
                  className={`grid h-12 w-12 shrink-0 place-items-center rounded-2xl ${
                    site.connected ? 'bg-sea-100/80 text-sea-700' : 'bg-mist-100/80 text-mist-600'
                  }`}
                >
                  <Globe className="h-6 w-6" />
                </span>

                <span className="min-w-0 flex-1">
                  <span className="block truncate text-[16px] font-extrabold leading-tight tracking-tight text-ink">
                    {site.name}
                  </span>
                  <span className="mt-1 block truncate text-[13.5px] font-medium text-ink-soft">
                    {site.url}
                  </span>
                  <span
                    className={`mt-1.5 inline-block rounded-lg px-2 py-0.5 text-[11px] font-bold ${
                      site.connected
                        ? 'bg-brand-100 text-brand-700'
                        : 'bg-mist-100 text-mist-600'
                    }`}
                  >
                    {site.connected ? 'Bağlı' : 'Bağlı değil'}
                  </span>
                </span>

                <ChevronRight className="h-5 w-5 shrink-0 text-ink-faint" />
              </button>
            </li>
          ))}
        </ul>
      </section>

      {/* --- Hesap bilgileri --- */}
      <section className="mt-1">
        <h2 className="px-1 text-[17px] font-extrabold tracking-tight text-ink">Hesap Bilgileri</h2>

        <ul className="mt-3.5 flex flex-col gap-3">
          {info.map(({ Icon, label, value }) => (
            <li key={label} className="glass flex items-center gap-4 rounded-[1.4rem] p-4">
              <span className="grid h-12 w-12 shrink-0 place-items-center rounded-2xl bg-brand-100/80 text-brand-700">
                <Icon className="h-6 w-6" />
              </span>
              <div className="min-w-0">
                <div className="text-[13px] font-semibold text-ink-soft">{label}</div>
                <div className="mt-0.5 truncate text-[16px] font-extrabold tracking-tight text-ink">
                  {value}
                </div>
              </div>
            </li>
          ))}
        </ul>
      </section>
    </div>
  )
}
