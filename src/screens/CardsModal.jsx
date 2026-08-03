import { useState } from 'react'
import { CreditCard, Plus, X } from '../components/Icons.jsx'

const initialCards = [
  { id: 'c1', last4: '4242', brand: 'Visa',       expiry: '08/27' },
  { id: 'c2', last4: '5500', brand: 'Mastercard', expiry: '03/26' },
]

export default function CardsModal({ onClose }) {
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

      {/* Bottom sheet — tam altta, navbar ile birleşik */}
      <div
        className="absolute inset-x-0 bottom-0 z-50 flex flex-col rounded-t-[1.8rem] bg-white/92 backdrop-blur-2xl"
        style={{ animation: 'slideUp 0.32s cubic-bezier(0.22,1,0.36,1)' }}
      >
        {/* Handle çubuğu */}
        <div className="mx-auto mt-3 h-1 w-10 rounded-full bg-black/15" />

        {/* Başlık */}
        <div className="flex items-center justify-between px-5 py-4">
          <h2 className="text-[17px] font-extrabold tracking-tight text-ink">Kayıtlı Kartlar</h2>
          <button
            type="button"
            onClick={onClose}
            className="grid h-8 w-8 place-items-center rounded-full bg-black/[0.07] text-ink-soft transition-colors active:bg-black/[0.12]"
            aria-label="Kapat"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* İçerik */}
        <div className="no-scrollbar overflow-y-auto px-5 pb-10">
          {/* Kart listesi */}
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

          {/* Kart ekle toggle */}
          <button
            type="button"
            onClick={() => setShowForm((v) => !v)}
            className="flex w-full items-center justify-center gap-2 rounded-2xl border border-dashed border-brand-300 bg-brand-50/50 py-3 text-[13.5px] font-bold text-brand-700 transition-colors active:bg-brand-50"
          >
            <Plus className="h-4 w-4" />
            {showForm ? 'Formu Kapat' : 'Yeni Kart Ekle'}
          </button>

          {/* Form */}
          <div
            className="overflow-hidden transition-all duration-300 ease-in-out"
            style={{ maxHeight: showForm ? '280px' : '0px', opacity: showForm ? 1 : 0 }}
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

      <style>{`
        @keyframes slideUp {
          from { transform: translateY(100%); }
          to   { transform: translateY(0); }
        }
      `}</style>
    </>
  )
}
