import { useState } from 'react'
import {
  Globe,
  ChevronRight,
  User,
  Mail,
  Phone,
  IdCard,
  CreditCard,
  Plus,
  X,
} from '../components/Icons.jsx'

/* ---------- veriler ---------- */
const sites = [
  { name: 'Ova Tarım', url: 'ovatarim.com.tr', connected: true },
  { name: 'Sera Kontrol', url: 'panel.seratek.io', connected: true },
  { name: 'Damla Notları', url: 'damlanotlari.com', connected: false },
]

const userInfo = [
  { Icon: User,   label: 'Ad Soyad',     value: 'Batuhan Canaracı' },
  { Icon: Mail,   label: 'E-posta',      value: 'batuhancanaraci85@gmail.com' },
  { Icon: IdCard, label: 'Kullanıcı ID', value: 'SLM-48210' },
]

const contactInfo = [
  { Icon: Phone, label: 'Telefon',  value: '0532 118 04 76' },
  { Icon: Mail,  label: 'E-posta', value: 'batuhancanaraci85@gmail.com' },
]

const initialCards = [
  { id: 'c1', last4: '4242', brand: 'Visa',       expiry: '08/27' },
  { id: 'c2', last4: '5500', brand: 'Mastercard', expiry: '03/26' },
]

/* ---------- Tek bilgi satırı ---------- */
function InfoRow({ Icon, label, value }) {
  return (
    <div className="flex items-center gap-3 py-2.5 border-b border-black/[0.04] last:border-0">
      <span className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-brand-100/80 text-brand-700">
        <Icon className="h-4.5 w-4.5" />
      </span>
      <div className="min-w-0">
        <div className="text-[11.5px] font-semibold text-ink-soft">{label}</div>
        <div className="mt-0.5 truncate text-[14px] font-bold tracking-tight text-ink">{value}</div>
      </div>
    </div>
  )
}

/* ---------- Accordion ---------- */
function AccordionItem({ id, label, open, onToggle, children }) {
  return (
    <div className="overflow-hidden">
      <button
        type="button"
        onClick={() => onToggle(id)}
        className="flex w-full items-center justify-between px-1 py-3 transition-colors active:bg-white/30"
      >
        <span className="text-[14.5px] font-extrabold tracking-tight text-ink">{label}</span>
        <span
          className={`grid h-6 w-6 place-items-center rounded-full bg-brand-100 text-brand-700 transition-transform duration-300 ${
            open ? 'rotate-90' : ''
          }`}
        >
          <ChevronRight className="h-3.5 w-3.5" />
        </span>
      </button>

      <div
        className="overflow-hidden transition-all duration-300 ease-in-out"
        style={{ maxHeight: open ? '600px' : '0px', opacity: open ? 1 : 0 }}
      >
        <div className="pb-3 px-1">{children}</div>
      </div>

      <div className="h-px bg-black/[0.06]" />
    </div>
  )
}

/* ---------- Kayıtlı Kartlar — bottom sheet modal ---------- */
function CardsModal({ onClose }) {
  const [cards, setCards]       = useState(initialCards)
  const [showForm, setShowForm] = useState(false)

  const deleteCard = (id) => setCards((prev) => prev.filter((c) => c.id !== id))

  return (
    <>
      {/* Overlay */}
      <div
        className="absolute inset-0 z-40 bg-black/30 backdrop-blur-[2px]"
        onClick={onClose}
      />

      {/* Sheet */}
      <div
        className="absolute inset-x-0 bottom-0 z-50 flex flex-col rounded-t-[1.8rem] bg-white/90 backdrop-blur-xl"
        style={{ animation: 'slideUp 0.32s cubic-bezier(0.22,1,0.36,1)' }}
      >
        {/* Handle */}
        <div className="mx-auto mt-3 h-1 w-10 rounded-full bg-black/15" />

        {/* Başlık */}
        <div className="flex items-center justify-between px-5 py-4">
          <h2 className="text-[17px] font-extrabold tracking-tight text-ink">Kayıtlı Kartlar</h2>
          <button
            type="button"
            onClick={onClose}
            className="grid h-8 w-8 place-items-center rounded-full bg-black/[0.07] text-ink-soft transition-colors active:bg-black/[0.12]"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* İçerik */}
        <div className="no-scrollbar overflow-y-auto px-5 pb-8">
          {/* Kayıtlı kart listesi */}
          {cards.length === 0 ? (
            <div className="py-6 text-center">
              <CreditCard className="mx-auto h-10 w-10 text-ink-faint" />
              <p className="mt-3 text-[14px] font-semibold text-ink-soft">Henüz kayıtlı kart yok.</p>
            </div>
          ) : (
            <ul className="flex flex-col gap-2.5">
              {cards.map((card) => (
                <li
                  key={card.id}
                  className="flex items-center gap-3 rounded-2xl border border-black/[0.06] bg-white/70 px-4 py-3.5"
                >
                  <span className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-sea-100/80 text-sea-700">
                    <CreditCard className="h-5 w-5" />
                  </span>
                  <div className="flex-1 min-w-0">
                    <div className="text-[14px] font-extrabold tracking-tight text-ink">
                      {card.brand} •••• {card.last4}
                    </div>
                    <div className="text-[12px] font-semibold text-ink-soft">
                      Son kullanma: {card.expiry}
                    </div>
                  </div>
                  <button
                    type="button"
                    onClick={() => deleteCard(card.id)}
                    className="grid h-7 w-7 shrink-0 place-items-center rounded-full bg-mist-100 text-mist-600 transition-colors active:bg-red-100 active:text-red-500"
                    aria-label="Kartı sil"
                  >
                    <X className="h-3.5 w-3.5" />
                  </button>
                </li>
              ))}
            </ul>
          )}

          {/* Ayırıcı */}
          <div className="my-4 h-px bg-black/[0.07]" />

          {/* Kart ekle toggle butonu */}
          <button
            type="button"
            onClick={() => setShowForm((v) => !v)}
            className="flex w-full items-center justify-center gap-2 rounded-2xl border border-dashed border-brand-300 bg-brand-50/50 py-3 text-[13.5px] font-bold text-brand-700 transition-colors active:bg-brand-50"
          >
            <Plus className="h-4 w-4" />
            {showForm ? 'Formu Kapat' : 'Yeni Kart Ekle'}
          </button>

          {/* Kart ekleme formu */}
          <div
            className="overflow-hidden transition-all duration-300 ease-in-out"
            style={{ maxHeight: showForm ? '300px' : '0px', opacity: showForm ? 1 : 0 }}
          >
            <div className="mt-3 flex flex-col gap-2.5 rounded-2xl border border-brand-100 bg-brand-50/60 p-4">
              <div className="text-[11px] font-bold uppercase tracking-widest text-brand-700">
                Kart Bilgileri
              </div>
              <input
                type="text"
                placeholder="Kart Numarası"
                maxLength={19}
                className="w-full rounded-xl border border-black/10 bg-white/80 px-3 py-2.5 text-[13px] font-semibold text-ink placeholder:text-ink-faint focus:outline-none focus:ring-2 focus:ring-brand-400"
              />
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="AA/YY"
                  maxLength={5}
                  className="w-1/2 rounded-xl border border-black/10 bg-white/80 px-3 py-2.5 text-[13px] font-semibold text-ink placeholder:text-ink-faint focus:outline-none focus:ring-2 focus:ring-brand-400"
                />
                <input
                  type="text"
                  placeholder="CVV"
                  maxLength={3}
                  className="w-1/2 rounded-xl border border-black/10 bg-white/80 px-3 py-2.5 text-[13px] font-semibold text-ink placeholder:text-ink-faint focus:outline-none focus:ring-2 focus:ring-brand-400"
                />
              </div>
              <button
                type="button"
                className="flex items-center justify-center gap-1.5 rounded-xl bg-brand-600 py-2.5 text-[13px] font-bold text-white transition-transform active:scale-[0.97]"
              >
                <Plus className="h-4 w-4" />
                Kartı Kaydet
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}

/* ---------- Ana ekran ---------- */
export default function ProfileScreen({ onOpenCards }) {
  const connected = sites.filter((s) => s.connected).length
  const [openSection, setOpenSection] = useState(null)

  const toggle = (id) => setOpenSection((prev) => (prev === id ? null : id))

  return (
    <div className="screen-in relative flex flex-col gap-4 px-5 pb-6 pt-2">
      {/* Profil avatar */}
      <header className="flex items-center justify-end px-1">
        <div className="grid h-12 w-12 shrink-0 place-items-center rounded-full bg-brand-100 text-[14px] font-extrabold tracking-tight text-brand-700">
          BC
        </div>
      </header>

      {/* --- Web siteleri --- */}
      <section>
        <div className="flex items-baseline justify-between gap-3 px-1">
          <h2 className="text-[15px] font-extrabold tracking-tight text-ink">Web Siteleri</h2>
          <span className="text-[12px] font-semibold text-ink-soft">
            {connected}/{sites.length} bağlı
          </span>
        </div>

        <ul className="mt-3 flex flex-col gap-2.5">
          {sites.map((site) => (
            <li key={site.url}>
              <button
                type="button"
                className="glass flex w-full items-center gap-3.5 rounded-[1.2rem] p-3.5 text-left transition-transform duration-200 active:scale-[0.985]"
              >
                <span
                  className={`grid h-10 w-10 shrink-0 place-items-center rounded-xl ${
                    site.connected ? 'bg-sea-100/80 text-sea-700' : 'bg-mist-100/80 text-mist-600'
                  }`}
                >
                  <Globe className="h-5 w-5" />
                </span>
                <span className="min-w-0 flex-1">
                  <span className="block truncate text-[14px] font-extrabold leading-tight tracking-tight text-ink">
                    {site.name}
                  </span>
                  <span className="mt-0.5 block truncate text-[12px] font-medium text-ink-soft">
                    {site.url}
                  </span>
                  <span
                    className={`mt-1 inline-block rounded-lg px-2 py-0.5 text-[10.5px] font-bold ${
                      site.connected ? 'bg-brand-100 text-brand-700' : 'bg-mist-100 text-mist-600'
                    }`}
                  >
                    {site.connected ? 'Bağlı' : 'Bağlı değil'}
                  </span>
                </span>
                <ChevronRight className="h-4.5 w-4.5 shrink-0 text-ink-faint" />
              </button>
            </li>
          ))}
        </ul>
      </section>

      {/* --- Ayırıcı çizgi --- */}
      <div className="mx-1 h-px bg-black/[0.09]" />

      {/* --- Hesap bölümleri --- */}
      <section className="glass rounded-[1.4rem] px-4 py-1">
        {/* Kullanıcı Bilgileri — accordion */}
        <AccordionItem
          id="user"
          label="Kullanıcı Bilgileri"
          open={openSection === 'user'}
          onToggle={toggle}
        >
          {userInfo.map(({ Icon, label, value }) => (
            <InfoRow key={label} Icon={Icon} label={label} value={value} />
          ))}
        </AccordionItem>

        {/* İletişim Bilgileri — accordion */}
        <AccordionItem
          id="contact"
          label="İletişim Bilgileri"
          open={openSection === 'contact'}
          onToggle={toggle}
        >
          {contactInfo.map(({ Icon, label, value }) => (
            <InfoRow key={label} Icon={Icon} label={label} value={value} />
          ))}
        </AccordionItem>

        {/* Kayıtlı Kartlar — modal açar */}
        <div className="overflow-hidden">
          <button
            type="button"
            onClick={() => onOpenCards()}
            className="flex w-full items-center justify-between px-1 py-3 transition-colors active:bg-white/30"
          >
            <span className="text-[14.5px] font-extrabold tracking-tight text-ink">
              Kayıtlı Kartlar
            </span>
            <span className="grid h-6 w-6 place-items-center rounded-full bg-brand-100 text-brand-700">
              <ChevronRight className="h-3.5 w-3.5" />
            </span>
          </button>
        </div>
      </section>
    </div>
  )
}
