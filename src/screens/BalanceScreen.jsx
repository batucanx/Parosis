import { useState, useMemo } from 'react'
import { Plus, Check, ChevronDown } from '../components/Icons.jsx'
import { statement, formatTL } from '../data.js'

export default function BalanceScreen({ balance, onTopUp, lastTopUp }) {
  const [filterMonth, setFilterMonth] = useState('all')

  const filteredStatement = useMemo(() => {
    if (filterMonth === 'all') return statement
    return statement.filter((row) => row.tarih.includes(filterMonth))
  }, [filterMonth])
  return (
    <div className="screen-in flex flex-col gap-5 px-5 pb-6 pt-2">
      <h1 className="px-1 text-[21px] font-extrabold tracking-tight text-ink">Bakiyem</h1>

      {lastTopUp && (
        <div
          role="status"
          className="flex items-center gap-3 rounded-2xl border border-brand-200 bg-brand-100/85 p-4"
        >
          <span className="grid h-10 w-10 shrink-0 place-items-center rounded-full bg-brand-600 text-white">
            <Check className="h-5 w-5" />
          </span>
          <p className="text-[14px] font-bold leading-snug text-brand-700">
            {formatTL(lastTopUp)} TL bakiyenize eklendi.
          </p>
        </div>
      )}

      {/* --- Kullanılabilir bakiye --- */}
      <section className="glass rounded-[1.75rem] px-6 py-7 text-center">
        <h2 className="text-[15px] font-bold tracking-tight text-ink-soft">Kullanılabilir Bakiye</h2>
        <p className="mt-2.5 text-[42px] font-extrabold leading-none tracking-tight text-ink">
          {formatTL(balance)}
          <span className="ml-2 text-[20px] font-bold text-ink-soft">TL</span>
        </p>
      </section>

      <button
        type="button"
        onClick={onTopUp}
        className="flex h-[52px] w-full items-center justify-center gap-2.5 rounded-[1.1rem] bg-brand-600 text-[15px] font-extrabold tracking-tight text-white shadow-[0_12px_24px_-12px_rgba(17,90,75,0.9),0_1px_0_0_rgba(255,255,255,0.3)_inset] transition-transform duration-200 active:scale-[0.98]"
      >
        <Plus className="h-5 w-5" />
        Bakiye Yükle
      </button>

      {/* --- Hesap ekstresi --- */}
      <section className="mt-2">
        <div className="flex items-center justify-between px-1">
          <h2 className="text-[17px] font-extrabold tracking-tight text-ink">Hesap Ekstresi</h2>
          
          {/* Filtreleme */}
          <div className="relative">
            <select
              value={filterMonth}
              onChange={(e) => setFilterMonth(e.target.value)}
              className="appearance-none rounded-lg bg-mist-100/50 py-1.5 pl-3 pr-8 text-[12px] font-bold text-ink-soft outline-none focus:ring-2 focus:ring-brand-500"
            >
              <option value="all">Tüm Zamanlar</option>
              <option value="Eki">Ekim 2023</option>
              <option value="Kas">Kasım 2023</option>
              <option value="Ara">Aralık 2023</option>
            </select>
            <ChevronDown className="pointer-events-none absolute right-2 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-ink-faint" />
          </div>
        </div>

        <div className="mt-3.5">
          {/* Başlık satırı */}
          <div className="grid grid-cols-[2.9rem_1fr_3.9rem_3.9rem] gap-x-1.5 border-b-2 border-mist-200/60 px-1 pb-2">
            <span className="text-[10.5px] font-extrabold uppercase text-ink-faint">Tarih</span>
            <span className="text-[10.5px] font-extrabold uppercase text-ink-faint">Açıklama</span>
            <span className="text-right text-[10.5px] font-extrabold uppercase text-brand-600">
              Yükleme
            </span>
            <span className="text-right text-[10.5px] font-extrabold uppercase text-mist-600">
              Harcama
            </span>
          </div>

          {/* Satırlar */}
          {filteredStatement.length === 0 ? (
            <div className="py-8 text-center text-[13px] font-semibold text-ink-faint">
              Bu döneme ait işlem bulunamadı.
            </div>
          ) : (
            <ul>
              {filteredStatement.map((row, i) => (
                <li
                  key={row.id}
                  className={`grid grid-cols-[2.9rem_1fr_3.9rem_3.9rem] items-center gap-x-1.5 px-1 py-4 ${
                    i > 0 ? 'border-t border-mist-200/50' : ''
                  }`}
                >
                  <span className="text-[12.5px] font-bold tracking-tight text-ink-soft">
                    {row.tarih}
                  </span>
                  <span className="truncate text-[13px] font-semibold tracking-tight text-ink">
                    {row.aciklama}
                  </span>
                  <span className="text-right text-[13.5px] font-extrabold tracking-tight text-brand-600">
                    {row.yukleme ? formatTL(row.yukleme) : <span className="text-ink-faint">—</span>}
                  </span>
                  <span className="text-right text-[13.5px] font-extrabold tracking-tight text-mist-600">
                    {row.harcama ? formatTL(row.harcama) : <span className="text-ink-faint">—</span>}
                  </span>
                </li>
              ))}
            </ul>
          )}
        </div>

        <p className="mt-3 px-1 text-[12px] font-medium text-ink-faint">Tutarlar TL cinsindendir.</p>
      </section>
    </div>
  )
}
