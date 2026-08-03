/** iPhone benzeri cihaz çerçevesi + iOS durum çubuğu. */

const StatusBar = () => (
  <div className="relative z-30 flex h-[54px] shrink-0 items-center justify-between px-8 pt-2">
    <span className="text-[15px] font-bold tracking-tight text-ink">9:41</span>
    <div className="flex items-center gap-1.5 text-ink">
      {/* Sinyal */}
      <svg width="18" height="12" viewBox="0 0 18 12" fill="currentColor" aria-hidden="true">
        <rect x="0" y="8" width="3" height="4" rx="1" />
        <rect x="5" y="5.5" width="3" height="6.5" rx="1" />
        <rect x="10" y="3" width="3" height="9" rx="1" />
        <rect x="15" y="0" width="3" height="12" rx="1" />
      </svg>
      {/* Wi-Fi */}
      <svg width="16" height="12" viewBox="0 0 16 12" fill="currentColor" aria-hidden="true">
        <path d="M8 11.2 5.9 8.8a3.2 3.2 0 0 1 4.2 0L8 11.2Z" />
        <path
          d="M3.5 6.4a6.4 6.4 0 0 1 9 0"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.7"
          strokeLinecap="round"
        />
        <path
          d="M1 3.6a10 10 0 0 1 14 0"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.7"
          strokeLinecap="round"
        />
      </svg>
      {/* Pil */}
      <svg width="25" height="12" viewBox="0 0 25 12" fill="none" aria-hidden="true">
        <rect
          x="0.6"
          y="0.6"
          width="21"
          height="10.8"
          rx="3"
          stroke="currentColor"
          strokeOpacity="0.4"
          strokeWidth="1.1"
        />
        <rect x="2.2" y="2.2" width="17.8" height="7.6" rx="1.9" fill="currentColor" />
        <path
          d="M23.4 4.2v3.6a2 2 0 0 0 0-3.6Z"
          fill="currentColor"
          fillOpacity="0.4"
        />
      </svg>
    </div>
  </div>
)

export default function PhoneFrame({ children }) {
  return (
    <div className="relative w-full max-w-[402px] sm:rounded-[3.4rem] sm:bg-[#0c1a18] sm:p-[11px] sm:shadow-[0_50px_90px_-30px_rgba(11,76,70,0.55),0_0_0_1px_rgba(255,255,255,0.12)_inset]">
      <div className="app-bg relative flex h-dvh w-full flex-col overflow-hidden sm:h-[860px] sm:rounded-[2.85rem]">
        {/* Dynamic Island */}
        <div className="pointer-events-none absolute left-1/2 top-2.5 z-40 h-[30px] w-[104px] -translate-x-1/2 rounded-full bg-[#0c1a18]" />
        <StatusBar />
        {children}
      </div>
    </div>
  )
}
