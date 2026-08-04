import { useState, useRef } from 'react'
import { X, Plus, Check, ChevronRight } from '../components/Icons.jsx'

/* ─── Banka logoları ─────────────────────────────────────── */
const BankLogos = {
  ziraat:    () => (<svg viewBox="0 0 40 40" className="h-full w-full"><rect width="40" height="40" rx="8" fill="#E30613"/><text x="20" y="27" textAnchor="middle" fill="white" fontSize="11" fontWeight="bold" fontFamily="Arial">ZİRAAT</text></svg>),
  garanti:   () => (<svg viewBox="0 0 40 40" className="h-full w-full"><rect width="40" height="40" rx="8" fill="#009530"/><text x="20" y="24" textAnchor="middle" fill="white" fontSize="8" fontWeight="bold" fontFamily="Arial">GARANTİ</text><text x="20" y="34" textAnchor="middle" fill="white" fontSize="7" fontWeight="bold" fontFamily="Arial">BBVA</text></svg>),
  akbank:    () => (<svg viewBox="0 0 40 40" className="h-full w-full"><rect width="40" height="40" rx="8" fill="#D0021B"/><text x="20" y="26" textAnchor="middle" fill="white" fontSize="10" fontWeight="bold" fontFamily="Arial">AKBANK</text></svg>),
  isbank:    () => (<svg viewBox="0 0 40 40" className="h-full w-full"><rect width="40" height="40" rx="8" fill="#0058A0"/><text x="20" y="22" textAnchor="middle" fill="white" fontSize="10" fontWeight="bold" fontFamily="Arial">İŞ</text><text x="20" y="33" textAnchor="middle" fill="white" fontSize="8" fontWeight="bold" fontFamily="Arial">BANKASI</text></svg>),
  yapi:      () => (<svg viewBox="0 0 40 40" className="h-full w-full"><rect width="40" height="40" rx="8" fill="#003087"/><text x="20" y="22" textAnchor="middle" fill="white" fontSize="8.5" fontWeight="bold" fontFamily="Arial">YAPI</text><text x="20" y="33" textAnchor="middle" fill="white" fontSize="7.5" fontWeight="bold" fontFamily="Arial">KREDİ</text></svg>),
  halkbank:  () => (<svg viewBox="0 0 40 40" className="h-full w-full"><rect width="40" height="40" rx="8" fill="#003082"/><text x="20" y="26" textAnchor="middle" fill="white" fontSize="8" fontWeight="bold" fontFamily="Arial">HALKBANK</text></svg>),
  vakifbank: () => (<svg viewBox="0 0 40 40" className="h-full w-full"><rect width="40" height="40" rx="8" fill="#F5A800"/><text x="20" y="26" textAnchor="middle" fill="#003082" fontSize="7" fontWeight="bold" fontFamily="Arial">VAKIFBANK</text></svg>),
  denizbank: () => (<svg viewBox="0 0 40 40" className="h-full w-full"><rect width="40" height="40" rx="8" fill="#004B87"/><text x="20" y="26" textAnchor="middle" fill="white" fontSize="7.5" fontWeight="bold" fontFamily="Arial">DENİZBANK</text></svg>),
  kuveyt:    () => (<svg viewBox="0 0 40 40" className="h-full w-full"><rect width="40" height="40" rx="8" fill="#006837"/><text x="20" y="22" textAnchor="middle" fill="white" fontSize="8" fontWeight="bold" fontFamily="Arial">KUVEYT</text><text x="20" y="33" textAnchor="middle" fill="white" fontSize="8" fontWeight="bold" fontFamily="Arial">TÜRK</text></svg>),
  ing:       () => (<svg viewBox="0 0 40 40" className="h-full w-full"><rect width="40" height="40" rx="8" fill="#FF6200"/><text x="20" y="26" textAnchor="middle" fill="white" fontSize="13" fontWeight="bold" fontFamily="Arial">ING</text></svg>),
  unknown:   () => (<svg viewBox="0 0 40 40" className="h-full w-full"><rect width="40" height="40" rx="8" fill="#E6EDEC"/><text x="20" y="26" textAnchor="middle" fill="#35605A" fontSize="8" fontWeight="bold" fontFamily="Arial">KART</text></svg>),
}

const BANKS = [
  { key: 'ziraat',    label: 'Ziraat' },
  { key: 'garanti',   label: 'Garanti' },
  { key: 'akbank',    label: 'Akbank' },
  { key: 'isbank',    label: 'İş Bankası' },
  { key: 'yapi',      label: 'Yapı Kredi' },
  { key: 'halkbank',  label: 'Halkbank' },
  { key: 'vakifbank', label: 'VakıfBank' },
  { key: 'denizbank', label: 'DenizBank' },
  { key: 'kuveyt',    label: 'Kuveyt Türk' },
  { key: 'ing',       label: 'ING' },
]

/* ─── Yardımcı fonksiyonlar ──────────────────────────────── */
function detectBank(bin) {
  const n = bin.replace(/\s/g, '')
  if (n.startsWith('9792') || n.startsWith('6530')) return 'ziraat'
  if (n.startsWith('4043') || n.startsWith('4044') || n.startsWith('5257')) return 'garanti'
  if (n.startsWith('4046') || n.startsWith('5402') || n.startsWith('5406')) return 'akbank'
  if (n.startsWith('4024') || n.startsWith('4025') || n.startsWith('5218')) return 'isbank'
  if (n.startsWith('4011') || n.startsWith('5130') || n.startsWith('5131')) return 'yapi'
  if (n.startsWith('6501') || n.startsWith('6504')) return 'halkbank'
  if (n.startsWith('4058') || n.startsWith('5359')) return 'vakifbank'
  if (n.startsWith('4030') || n.startsWith('5173')) return 'denizbank'
  if (n.startsWith('6791') || n.startsWith('4059')) return 'kuveyt'
  if (n.startsWith('4013') || n.startsWith('5231')) return 'ing'
  if (n.length >= 1) return 'unknown'
  return null
}

function detectScheme(num) {
  const n = num.replace(/\s/g, '')
  if (n.startsWith('4')) return 'visa'
  if (/^5[1-5]/.test(n) || /^2[2-7]/.test(n)) return 'mastercard'
  if (n.startsWith('9792')) return 'troy'
  if (/^3[47]/.test(n)) return 'amex'
  return null
}

function formatCardNumber(raw) {
  const digits = raw.replace(/\D/g, '').slice(0, 16)
  return digits.replace(/(.{4})/g, '$1 ').trim()
}

function formatExpiry(raw) {
  const digits = raw.replace(/\D/g, '').slice(0, 4)
  if (digits.length >= 3) return digits.slice(0, 2) + '/' + digits.slice(2)
  return digits
}

function SchemeIcon({ scheme }) {
  if (scheme === 'visa') return (
    <svg viewBox="0 0 50 16" className="h-5 w-auto drop-shadow" aria-label="Visa">
      <text x="0" y="13" fontFamily="Arial" fontWeight="bold" fontSize="14" fill="white">VISA</text>
    </svg>
  )
  if (scheme === 'mastercard') return (
    <svg viewBox="0 0 36 22" className="h-5 w-auto" aria-label="Mastercard">
      <circle cx="11" cy="11" r="11" fill="#EB001B" fillOpacity="0.9"/>
      <circle cx="25" cy="11" r="11" fill="#F79E1B" fillOpacity="0.9"/>
      <path d="M18 4.2a11 11 0 0 1 0 13.6A11 11 0 0 1 18 4.2Z" fill="#FF5F00"/>
    </svg>
  )
  if (scheme === 'troy') return (
    <svg viewBox="0 0 50 16" className="h-5 w-auto" aria-label="Troy">
      <text x="0" y="13" fontFamily="Arial" fontWeight="bold" fontSize="13" fill="white">TROY</text>
    </svg>
  )
  if (scheme === 'amex') return (
    <svg viewBox="0 0 50 16" className="h-5 w-auto" aria-label="Amex">
      <text x="0" y="13" fontFamily="Arial" fontWeight="bold" fontSize="11" fill="white">AMEX</text>
    </svg>
  )
  return null
}

/* ─── Başlangıç kartları ─────────────────────────────────── */
const initialCards = [
  { id: 'c1', last4: '4242', scheme: 'visa',       bank: 'garanti', expiry: '08/27', holderName: 'BATUHAN CANARACI', cardLabel: 'Garanti Banka Kartım' },
  { id: 'c2', last4: '5500', scheme: 'mastercard', bank: 'akbank',  expiry: '03/26', holderName: 'BATUHAN CANARACI', cardLabel: 'Akbank Kredi Kartım' },
]

/* ═══════════════════════════════════════════════════════════
   ANA MODAL
   • Tam navbardan (bottom-0) üst köşeye kadar kayar
   • ÜST: Yeni Kart Ekle butonu + açılır form
   • ALT: Kayıtlı kartlar listesi (scroll)
═══════════════════════════════════════════════════════════ */
export default function CardsModal({ onClose }) {
  const [cards, setCards]         = useState(initialCards)
  const [showForm, setShowForm]   = useState(false)
  const [saved, setSaved]         = useState(false)
  const [editingId, setEditingId] = useState(null)   // düzenlenecek kart id'si
  const [editLabel, setEditLabel] = useState('')
  const [editCvv, setEditCvv]     = useState('')

  /* form state */
  const [cardNumber,  setCardNumber]  = useState('')
  const [expiry,      setExpiry]      = useState('')
  const [cvv,         setCvv]         = useState('')
  const [holderName,  setHolderName]  = useState('')
  const [cardLabel,   setCardLabel]   = useState('')   // kart adı / etiketi

  const expiryRef = useRef(null)
  const cvvRef    = useRef(null)
  const nameRef   = useRef(null)

  const rawNum       = cardNumber.replace(/\s/g, '')
  const scheme       = detectScheme(rawNum)
  const detectedBank = rawNum.length >= 4 ? detectBank(rawNum) : null
  const bankKey      = detectedBank || null
  const BankLogo     = bankKey && BankLogos[bankKey] ? BankLogos[bankKey] : null

  const isFormValid =
    rawNum.length >= 13 &&
    expiry.length === 5 &&
    cvv.length >= 3 &&
    holderName.trim().length >= 2

  const handleCardNumChange = (e) => {
    const formatted = formatCardNumber(e.target.value)
    setCardNumber(formatted)
    if (formatted.replace(/\s/g, '').length === 16) expiryRef.current?.focus()
  }
  const handleExpiryChange = (e) => {
    const formatted = formatExpiry(e.target.value)
    setExpiry(formatted)
    if (formatted.length === 5) cvvRef.current?.focus()
  }
  const handleCvvChange = (e) => {
    const digits = e.target.value.replace(/\D/g, '').slice(0, 4)
    setCvv(digits)
    if (digits.length >= 3) nameRef.current?.focus()
  }

  const saveCard = () => {
    if (!isFormValid) return
    setCards((prev) => [...prev, {
      id: `c${Date.now()}`,
      last4: rawNum.slice(-4),
      scheme: scheme ?? 'unknown',
      bank: bankKey ?? 'unknown',
      expiry,
      holderName: holderName.toUpperCase(),
      cardLabel: cardLabel.trim() || null,
    }])
    setCardNumber(''); setExpiry(''); setCvv(''); setHolderName(''); setCardLabel('')
    setShowForm(false)
    setSaved(true)
    setTimeout(() => setSaved(false), 3000)
  }

  const deleteCard = (id) => setCards((prev) => prev.filter((c) => c.id !== id))

  const startEdit = (card) => {
    setEditingId(card.id)
    setEditLabel(card.cardLabel || '')
    setEditCvv('')
  }
  const saveEdit = (id) => {
    setCards((prev) => prev.map((c) =>
      c.id === id
        ? { ...c, cardLabel: editLabel.trim() || null, ...(editCvv.length >= 3 ? { cvv: editCvv } : {}) }
        : c
    ))
    setEditingId(null)
  }

  return (
    <>
      {/* ── Arka plan overlay ── */}
      <div
        className="absolute inset-0 z-40 bg-black/40 backdrop-blur-[3px]"
        onClick={onClose}
      />

      {/* ── Sheet: bottom-0'dan tüm ekrana kayar ── */}
      <div
        className="absolute inset-x-0 bottom-0 z-50 flex flex-col rounded-t-[1.8rem] bg-[#f8faf9]"
        style={{
          height: 'calc(100% - 54px)',          /* status bar yüksekliğini geç */
          animation: 'slideUp 0.38s cubic-bezier(0.22,1,0.36,1)',
        }}
      >
        {/* ── Handle + başlık ── */}
        <div className="shrink-0">
          <div className="mx-auto mt-3 h-1 w-10 rounded-full bg-black/15" />
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
        </div>

        {/* ════════════════════════════════════════════════════
            ÜST BÖLÜM — Yeni Kart Ekle (sabit, scroll etkilemez)
        ════════════════════════════════════════════════════ */}
        <div className="shrink-0 px-5 pb-4">

          {/* Başarı bildirimi */}
          {saved && (
            <div className="mb-3 flex items-center gap-2.5 rounded-2xl bg-brand-100 px-4 py-3">
              <span className="grid h-6 w-6 shrink-0 place-items-center rounded-full bg-brand-600 text-white">
                <Check className="h-3.5 w-3.5" />
              </span>
              <span className="text-[13px] font-bold text-brand-700">Kart başarıyla kaydedildi.</span>
            </div>
          )}

          {/* Form açık: beyaz zemin kırmızı X   |   Form kapalı: yeşil Yeni Kart Ekle */}
          {showForm ? (
            <button
              type="button"
              onClick={() => {
                setShowForm(false)
                setCardNumber(''); setExpiry(''); setCvv(''); setHolderName(''); setCardLabel('')
              }}
              className="flex w-full items-center justify-center rounded-2xl border border-red-200 bg-white py-3.5 text-red-500 transition-all active:scale-[0.98] active:bg-red-50"
              aria-label="Formu kapat"
            >
              <X className="h-6 w-6" />
            </button>
          ) : (
            <button
              type="button"
              onClick={() => setShowForm(true)}
              className="flex w-full items-center justify-center gap-2 rounded-2xl bg-brand-600 py-3.5 text-[14px] font-bold text-white shadow-[0_10px_24px_-10px_rgba(17,90,75,0.8)] transition-all active:scale-[0.98]"
            >
              <Plus className="h-4.5 w-4.5" />
              Yeni Kart Ekle
            </button>
          )}

          {/* ── Kart ekleme formu (expand) ── */}
          <div
            className="overflow-hidden transition-all duration-400 ease-in-out"
            style={{ maxHeight: showForm ? '700px' : '0px', opacity: showForm ? 1 : 0 }}
          >
            <div className="mt-3 rounded-2xl border border-slate-200/80 bg-white p-4 shadow-sm">

              {/* Canlı kart önizlemesi */}
              <div className="mb-4 relative h-36 rounded-2xl bg-gradient-to-br from-brand-600 via-brand-700 to-brand-800 p-4 shadow-xl overflow-hidden">
                <div className="absolute -right-8 -top-8 h-32 w-32 rounded-full bg-white/10" />
                <div className="absolute right-4 bottom-4 h-24 w-24 rounded-full bg-white/[0.06]" />
                <div className="relative flex items-start justify-between">
                  {BankLogo
                    ? <div className="h-9 w-9 overflow-hidden rounded-xl shadow-sm"><BankLogo /></div>
                    : <div className="h-9 w-20 rounded-xl bg-white/20" />
                  }
                  <SchemeIcon scheme={scheme} />
                </div>
                <div className="relative mt-2 font-mono text-[14px] font-bold tracking-[0.18em] text-white/90">
                  {cardNumber || '•••• •••• •••• ••••'}
                </div>
                <div className="relative mt-2 flex items-end justify-between">
                  <div>
                    <div className="text-[9px] font-semibold uppercase tracking-widest text-white/50">Kart Sahibi</div>
                    <div className="text-[11px] font-bold uppercase tracking-wider text-white/90">
                      {holderName || 'AD SOYAD'}
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-[9px] font-semibold uppercase tracking-widest text-white/50">Son Kul.</div>
                    <div className="text-[11px] font-bold tracking-wider text-white/90">{expiry || 'AA/YY'}</div>
                  </div>
                </div>
              </div>

              {/* Kart numarası */}
              <div className="mb-2.5">
                <label className="mb-1 block text-[10.5px] font-bold uppercase tracking-widest text-ink-soft">Kart Numarası</label>
                <input
                  type="text" inputMode="numeric"
                  placeholder="0000 0000 0000 0000"
                  value={cardNumber} onChange={handleCardNumChange}
                  className="w-full rounded-xl border border-slate-200 bg-white px-3.5 py-3 font-mono text-[14px] font-semibold text-ink placeholder:text-ink-faint focus:outline-none focus:ring-2 focus:ring-brand-400"
                />
              </div>

              {/* Son kullanma + CVV */}
              <div className="mb-2.5 flex gap-2.5">
                <div className="flex-1">
                  <label className="mb-1 block text-[10.5px] font-bold uppercase tracking-widest text-ink-soft">Son Kullanma</label>
                  <input
                    ref={expiryRef} type="text" inputMode="numeric"
                    placeholder="AA/YY" value={expiry} onChange={handleExpiryChange} maxLength={5}
                    className="w-full rounded-xl border border-slate-200 bg-white px-3.5 py-3 text-[13px] font-semibold text-ink placeholder:text-ink-faint focus:outline-none focus:ring-2 focus:ring-brand-400"
                  />
                </div>
                <div className="flex-1">
                  <label className="mb-1 block text-[10.5px] font-bold uppercase tracking-widest text-ink-soft">CVV / CVC</label>
                  <input
                    ref={cvvRef} type="password" inputMode="numeric"
                    placeholder="•••" value={cvv} onChange={handleCvvChange} maxLength={4}
                    className="w-full rounded-xl border border-slate-200 bg-white px-3.5 py-3 text-[13px] font-semibold text-ink placeholder:text-ink-faint focus:outline-none focus:ring-2 focus:ring-brand-400"
                  />
                </div>
              </div>

              {/* Kart sahibi */}
              <div className="mb-2.5">
                <label className="mb-1 block text-[10.5px] font-bold uppercase tracking-widest text-ink-soft">Kart Sahibi Adı</label>
                <input
                  ref={nameRef} type="text"
                  placeholder="AD SOYAD"
                  value={holderName} onChange={(e) => setHolderName(e.target.value.toUpperCase())}
                  className="w-full rounded-xl border border-slate-200 bg-white px-3.5 py-3 text-[13px] font-semibold uppercase tracking-wider text-ink placeholder:text-ink-faint focus:outline-none focus:ring-2 focus:ring-brand-400"
                />
              </div>

              {/* Kart adı / etiketi — EN ALTTA */}
              <div className="mb-4">
                <label className="mb-1 block text-[10.5px] font-bold uppercase tracking-widest text-ink-soft">Kart Adı <span className="normal-case tracking-normal font-medium text-ink-faint">(isteğe bağlı)</span></label>
                <input
                  type="text"
                  placeholder="ör. Yapı Kredi Banka Kartım"
                  value={cardLabel} onChange={(e) => setCardLabel(e.target.value)}
                  className="w-full rounded-xl border border-slate-200 bg-white px-3.5 py-3 text-[13px] font-semibold text-ink placeholder:text-ink-faint focus:outline-none focus:ring-2 focus:ring-brand-400"
                />
              </div>

              {/* Kaydet */}
              <button
                type="button" onClick={saveCard} disabled={!isFormValid}
                className="flex w-full items-center justify-center gap-2 rounded-xl bg-brand-600 py-3 text-[14px] font-bold text-white shadow-[0_8px_20px_-8px_rgba(17,90,75,0.7)] transition-all active:scale-[0.98] disabled:opacity-40 disabled:shadow-none disabled:cursor-not-allowed"
              >
                <Plus className="h-4 w-4" /> Kartı Kaydet
              </button>
              <p className="mt-2.5 text-center text-[11px] text-ink-faint">🔒 256-bit SSL ile şifrelenmiş</p>
            </div>
          </div>
        </div>

        {/* ── Ayırıcı çizgi ── */}
        <div className="mx-5 shrink-0 border-t border-black/[0.08]" />

        {/* ════════════════════════════════════════════════════
            ALT BÖLÜM — Kayıtlı kartlar (kaydırılabilir)
        ════════════════════════════════════════════════════ */}
        <div className="no-scrollbar min-h-0 flex-1 overflow-y-auto px-5 pb-6 pt-4">
          {cards.length === 0 ? (
            <div className="py-10 text-center">
              <div className="mx-auto mb-3 grid h-14 w-14 place-items-center rounded-2xl bg-slate-100 text-ink-faint">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" className="h-7 w-7">
                  <rect x="2" y="5" width="20" height="14" rx="3"/>
                  <path d="M2 10h20M6 15h4"/>
                </svg>
              </div>
              <p className="text-[14px] font-semibold text-ink-soft">Henüz kayıtlı kart yok.</p>
              <p className="mt-1 text-[12px] text-ink-faint">Yukarıdan yeni kart ekleyebilirsiniz.</p>
            </div>
          ) : (
            <ul className="flex flex-col gap-3">
              {cards.map((card) => {
                const isEditing = editingId === card.id
                return (
                  <li
                    key={card.id}
                    className="overflow-hidden rounded-2xl border border-slate-200/80 bg-white shadow-sm"
                  >
                    {/* Normal görünüm */}
                    {!isEditing ? (
                      <div className="flex items-center gap-3 px-4 py-4">
                        {/* Sol — Visa/MC logo */}
                        <div className="shrink-0 w-10 flex items-center justify-center">
                          {card.scheme === 'visa' && (
                            <span className="rounded-md bg-[#1A1F71] px-2 py-1 text-[9px] font-extrabold text-white">VISA</span>
                          )}
                          {card.scheme === 'mastercard' && (
                            <span className="flex items-center">
                              <span className="h-5 w-5 rounded-full bg-[#EB001B] opacity-90" />
                              <span className="-ml-2.5 h-5 w-5 rounded-full bg-[#F79E1B] opacity-90" />
                            </span>
                          )}
                          {card.scheme === 'troy' && (
                            <span className="rounded-md bg-[#003082] px-2 py-1 text-[9px] font-extrabold text-white">TROY</span>
                          )}
                          {!['visa','mastercard','troy'].includes(card.scheme) && (
                            <span className="rounded-md bg-slate-200 px-2 py-1 text-[9px] font-bold text-ink-soft">KART</span>
                          )}
                        </div>

                        {/* Orta — kart adı + sahibi */}
                        <div className="min-w-0 flex-1">
                          {card.cardLabel && (
                            <div className="text-[13px] font-extrabold tracking-tight text-ink">{card.cardLabel}</div>
                          )}
                          <div className="mt-0.5 text-[11.5px] font-semibold text-ink-soft">{card.holderName}</div>
                        </div>

                        {/* Sağ — numara + tarih */}
                        <div className="shrink-0 text-right">
                          <div className="text-[13px] font-extrabold tracking-tight text-ink">•••• {card.last4}</div>
                          <div className="mt-0.5 text-[11px] font-semibold text-ink-faint">{card.expiry}</div>
                        </div>

                        {/* Düzenle butonu */}
                        <button
                          type="button"
                          onClick={() => startEdit(card)}
                          className="ml-1 grid h-8 w-8 shrink-0 place-items-center rounded-full bg-slate-100 text-ink-soft transition-colors active:bg-brand-100 active:text-brand-700"
                          aria-label="Kartı güncelle"
                        >
                          <ChevronRight className="h-4 w-4" strokeWidth={2.4} />
                        </button>
                      </div>
                    ) : (
                      /* Düzenleme modu */
                      <div className="px-4 py-4">
                        <div className="mb-2 text-[10.5px] font-bold uppercase tracking-widest text-brand-700">Düzenle</div>
                        <div className="mb-2">
                          <label className="mb-1 block text-[10.5px] font-semibold text-ink-soft">Kart Adı</label>
                          <input
                            type="text"
                            value={editLabel}
                            onChange={(e) => setEditLabel(e.target.value)}
                            placeholder="ör. Garanti Banka Kartım"
                            className="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-[13px] font-semibold text-ink focus:outline-none focus:ring-2 focus:ring-brand-400"
                          />
                        </div>
                        <div className="mb-3">
                          <label className="mb-1 block text-[10.5px] font-semibold text-ink-soft">CVV / CVC</label>
                          <input
                            type="password"
                            inputMode="numeric"
                            placeholder="•••"
                            value={editCvv}
                            onChange={(e) => setEditCvv(e.target.value.replace(/\D/g, '').slice(0, 4))}
                            maxLength={4}
                            className="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-[13px] font-semibold text-ink placeholder:text-ink-faint focus:outline-none focus:ring-2 focus:ring-brand-400"
                          />
                        </div>
                        <div className="flex gap-2">
                          <button
                            type="button"
                            onClick={() => saveEdit(card.id)}
                            className="flex flex-1 items-center justify-center gap-1.5 rounded-xl bg-brand-600 py-2.5 text-[13px] font-bold text-white active:bg-brand-700"
                          >
                            Kaydet
                          </button>
                          <button
                            type="button"
                            onClick={() => { deleteCard(card.id); setEditingId(null) }}
                            className="flex items-center justify-center gap-1.5 rounded-xl bg-red-50 px-4 py-2.5 text-[13px] font-bold text-red-500 active:bg-red-100"
                          >
                            <X className="h-3.5 w-3.5" /> Sil
                          </button>
                          <button
                            type="button"
                            onClick={() => setEditingId(null)}
                            className="rounded-xl bg-slate-100 px-4 py-2.5 text-[13px] font-bold text-ink-soft active:bg-slate-200"
                          >
                            İptal
                          </button>
                        </div>
                      </div>
                    )}
                  </li>
                )
              })}
            </ul>
          )}
        </div>
      </div>
    </>
  )
}
