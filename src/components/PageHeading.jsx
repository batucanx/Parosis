import { ArrowLeft } from './Icons.jsx'

/** Alt sayfalarda büyük "Geri" hedefi + sayfa başlığı. */
export default function PageHeading({ title, subtitle, onBack }) {
  return (
    <div className="flex items-center gap-3.5 pb-1">
      <button
        type="button"
        onClick={onBack}
        aria-label="Geri dön"
        className="glass-soft grid h-14 w-14 shrink-0 place-items-center rounded-2xl text-ink transition-transform duration-200 active:scale-95"
      >
        <ArrowLeft className="h-7 w-7" />
      </button>
      <div className="min-w-0">
        <h1 className="text-[21px] font-extrabold leading-tight tracking-tight text-ink">{title}</h1>
        {subtitle && (
          <p className="mt-0.5 text-[13px] font-medium text-ink-soft">{subtitle}</p>
        )}
      </div>
    </div>
  )
}
