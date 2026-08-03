import { useState } from 'react'
import PageHeading from '../components/PageHeading.jsx'
import { Plus } from '../components/Icons.jsx'
import { quickAmounts, formatTL } from '../data.js'

export default function TopUpScreen({ onBack, onConfirm }) {
  // Hızlı seçim ve manuel giriş aynı state'i paylaşır —
  // bir hızlı seçim butonuna basınca input otomatik dolar.
  const [amount, setAmount] = useState('')

  const numeric = Number(amount)
  const isValid = Number.isFinite(numeric) && numeric > 0

  const handleInput = (e) => {
    // Yalnızca rakam kabul et; başlangıçtaki sıfırları temizle.
    const digits = e.target.value.replace(/\D/g, '').replace(/^0+(?=\d)/, '')
    setAmount(digits)
  }

  return (
    <div className="screen-in flex flex-col gap-6 px-5 pb-6 pt-2">
      <PageHeading title="Bakiye Yükle" subtitle="Tutar seçin veya yazın" onBack={onBack} />

      {/* --- Hızlı seçimler --- */}
      <section>
        <h2 className="px-1 text-[14px] font-extrabold tracking-tight text-ink">Hızlı Seçim</h2>
        <div className="mt-3 grid grid-cols-3 gap-2.5">
          {quickAmounts.map((v) => {
            const selected = numeric === v
            return (
              <button
                key={v}
                type="button"
                onClick={() => setAmount(String(v))}
                aria-pressed={selected}
                className={[
                  'flex h-[48px] items-center justify-center rounded-[1rem] text-[14px] font-extrabold tracking-tight transition-all duration-200 active:scale-[0.97]',
                  selected
                    ? 'bg-brand-600 text-white shadow-[0_10px_20px_-10px_rgba(17,90,75,0.9),0_1px_0_0_rgba(255,255,255,0.3)_inset]'
                    : 'glass text-ink',
                ].join(' ')}
              >
                {v} TL
              </button>
            )
          })}
        </div>
      </section>

      {/* --- Manuel giriş --- */}
      <section>
        <label
          htmlFor="tutar"
          className="block px-1 text-[14px] font-extrabold tracking-tight text-ink"
        >
          Kendi Tutarınız
        </label>
        <div className="glass mt-3 flex h-[52px] items-center gap-3 rounded-[1rem] px-4">
          <input
            id="tutar"
            type="text"
            inputMode="numeric"
            autoComplete="off"
            value={amount}
            onChange={handleInput}
            placeholder="Tutar giriniz"
            className="w-full bg-transparent text-[16px] font-extrabold tracking-tight text-ink outline-none placeholder:text-[14px] placeholder:font-semibold placeholder:text-ink-faint"
          />
          <span className="shrink-0 text-[14px] font-bold text-ink-soft">TL</span>
        </div>
        <div className="mt-3 flex items-start gap-2.5 rounded-xl border border-amber-200/70 bg-amber-50/60 px-3.5 py-2.5">
          <span className="mt-0.5 shrink-0 text-amber-400">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
              <path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z" />
              <line x1="12" y1="9" x2="12" y2="13" />
              <line x1="12" y1="17" x2="12.01" y2="17" />
            </svg>
          </span>
          <p className="text-[12px] font-semibold leading-snug text-amber-800/75">
            Bakiye işlemlerini yukarıdan hızlı seçimden seçerek yapabilirsiniz. Test sürecinde olduğu için bakiyeniz direkt olarak yüklenir.
          </p>
        </div>
      </section>

      {/* --- Onay --- */}
      <button
        type="button"
        disabled={!isValid}
        onClick={() => onConfirm(numeric)}
        className={[
          'mt-1 flex h-[52px] w-full items-center justify-center gap-2.5 rounded-[1.1rem] text-[15px] font-extrabold tracking-tight transition-all duration-200',
          isValid
            ? 'bg-[#111111] text-white shadow-[0_12px_28px_-14px_rgba(0,0,0,0.6)] active:scale-[0.98]'
            : 'cursor-not-allowed bg-mist-200/70 text-mist-600',
        ].join(' ')}
      >
        <Plus className="h-5 w-5" />
        {isValid ? 'Yükle' : 'Tutar Seçin'}
      </button>
    </div>
  )
}
