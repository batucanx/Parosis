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
        <h2 className="px-1 text-[16px] font-extrabold tracking-tight text-ink">Hızlı Seçim</h2>
        <div className="mt-3.5 grid grid-cols-2 gap-3">
          {quickAmounts.map((v) => {
            const selected = numeric === v
            return (
              <button
                key={v}
                type="button"
                onClick={() => setAmount(String(v))}
                aria-pressed={selected}
                className={[
                  'flex h-[76px] items-center justify-center rounded-[1.4rem] text-[19px] font-extrabold tracking-tight transition-all duration-200 active:scale-[0.97]',
                  selected
                    ? 'bg-brand-600 text-white shadow-[0_14px_28px_-14px_rgba(17,90,75,0.95),0_1px_0_0_rgba(255,255,255,0.3)_inset]'
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
          className="block px-1 text-[16px] font-extrabold tracking-tight text-ink"
        >
          Kendi Tutarınız
        </label>
        <div className="glass mt-3.5 flex h-[76px] items-center gap-3 rounded-[1.4rem] px-5">
          <input
            id="tutar"
            type="text"
            inputMode="numeric"
            autoComplete="off"
            value={amount}
            onChange={handleInput}
            placeholder="Tutar giriniz"
            className="w-full bg-transparent text-[19px] font-extrabold tracking-tight text-ink outline-none placeholder:text-[16px] placeholder:font-semibold placeholder:text-ink-faint"
          />
          <span className="shrink-0 text-[18px] font-bold text-ink-soft">TL</span>
        </div>
        <p className="mt-2.5 px-1 text-[13px] font-medium text-ink-faint">
          Yukarıdan seçim yaptığınızda bu alan otomatik dolar.
        </p>
      </section>

      {/* --- Onay --- */}
      <button
        type="button"
        disabled={!isValid}
        onClick={() => onConfirm(numeric)}
        className={[
          'mt-1 flex h-[76px] w-full items-center justify-center gap-3 rounded-[1.5rem] text-[18px] font-extrabold tracking-tight transition-all duration-200',
          isValid
            ? 'bg-brand-600 text-white shadow-[0_18px_34px_-16px_rgba(17,90,75,0.95),0_1px_0_0_rgba(255,255,255,0.3)_inset] active:scale-[0.98]'
            : 'cursor-not-allowed bg-mist-200/70 text-mist-600',
        ].join(' ')}
      >
        <Plus className="h-6 w-6" />
        {isValid ? `${formatTL(numeric)} TL Yükle` : 'Tutar Seçin'}
      </button>
    </div>
  )
}
