/**
 * Line-art ikon seti.
 * Hepsi 24x24 viewBox, currentColor stroke — boyut/renk sınıf ile verilir.
 * Erişilebilirlik için varsayılan stroke kalınlığı 1.8 (eskisi 1.6).
 */

const base = {
  viewBox: '0 0 24 24',
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.8,
  strokeLinecap: 'round',
  strokeLinejoin: 'round',
  xmlns: 'http://www.w3.org/2000/svg',
  'aria-hidden': 'true',
}

const Svg = ({ children, className = 'w-6 h-6', strokeWidth, ...rest }) => (
  <svg {...base} strokeWidth={strokeWidth ?? base.strokeWidth} className={className} {...rest}>
    {children}
  </svg>
)

/* Marka: su damlası + yaprak */
export const LogoMark = (p) => (
  <Svg {...p}>
    <path d="M12 3.2s5.8 5.5 5.8 9.5a5.8 5.8 0 1 1-11.6 0C6.2 8.7 12 3.2 12 3.2Z" />
    <path d="M10.1 15.6c0-2.7 1.9-4.6 4.6-4.8.2 2.7-1.8 4.7-4.6 4.8Z" />
    <path d="M14.7 10.8 10.4 15.3" />
  </Svg>
)

export const Droplet = (p) => (
  <Svg {...p}>
    <path d="M12 3.4s5.6 5.4 5.6 9.3a5.6 5.6 0 1 1-11.2 0C6.4 8.8 12 3.4 12 3.4Z" />
  </Svg>
)

export const Home = (p) => (
  <Svg {...p}>
    <path d="M4 10.2 12 4l8 6.2v8.1a1.7 1.7 0 0 1-1.7 1.7H5.7A1.7 1.7 0 0 1 4 18.3v-8.1Z" />
    <path d="M9.6 20v-6.2h4.8V20" />
  </Svg>
)

export const User = (p) => (
  <Svg {...p}>
    <circle cx="12" cy="8.2" r="3.6" />
    <path d="M4.8 19.6a7.2 7.2 0 0 1 14.4 0" />
  </Svg>
)

export const Wallet = (p) => (
  <Svg {...p}>
    <path d="M3.4 8.6A2.6 2.6 0 0 1 6 6h11.4a2.6 2.6 0 0 1 2.6 2.6v7.8a2.6 2.6 0 0 1-2.6 2.6H6a2.6 2.6 0 0 1-2.6-2.6V8.6Z" />
    <path d="M16.4 12.5h3.6" />
  </Svg>
)

export const Plus = (p) => (
  <Svg strokeWidth={2.2} {...p}>
    <path d="M12 5.4v13.2M5.4 12h13.2" />
  </Svg>
)

export const Search = (p) => (
  <Svg {...p}>
    <circle cx="10.8" cy="10.8" r="6.4" />
    <path d="m15.6 15.6 4 4" />
  </Svg>
)

export const Play = (p) => (
  <Svg {...p}>
    <path d="M8.4 5.6 18 12l-9.6 6.4V5.6Z" />
  </Svg>
)

export const ArrowLeft = (p) => (
  <Svg strokeWidth={2.2} {...p}>
    <path d="M19 12H5" />
    <path d="m11 6-6 6 6 6" />
  </Svg>
)

export const ChevronRight = (p) => (
  <Svg strokeWidth={2.2} {...p}>
    <path d="m9.6 5.6 6.4 6.4-6.4 6.4" />
  </Svg>
)

export const CalendarClock = (p) => (
  <Svg {...p}>
    <rect x="3.4" y="5.2" width="17.2" height="15.4" rx="3" />
    <path d="M3.4 9.8h17.2M8.2 3.4v3.6M15.8 3.4v3.6" />
    <path d="M12 12.8v2.8l2 1.2" />
  </Svg>
)

export const History = (p) => (
  <Svg {...p}>
    <path d="M3.6 12a8.4 8.4 0 1 0 2.5-6" />
    <path d="M3.4 3.8v4.6h4.6" />
    <path d="M12 7.6V12l3 1.8" />
  </Svg>
)

export const Clock = (p) => (
  <Svg {...p}>
    <circle cx="12" cy="12" r="8.4" />
    <path d="M12 7.4V12l3 1.8" />
  </Svg>
)

export const MapPin = (p) => (
  <Svg {...p}>
    <path d="M12 21.2s6.6-5.4 6.6-10.4a6.6 6.6 0 0 0-13.2 0c0 5 6.6 10.4 6.6 10.4Z" />
    <circle cx="12" cy="10.6" r="2.6" />
  </Svg>
)

/* Kuyu etiketleri */
export const Gauge = (p) => (
  <Svg {...p}>
    <path d="M4.2 17.4a8.6 8.6 0 1 1 15.6 0" />
    <path d="m14.6 9.8-2.8 4.2" />
    <circle cx="12" cy="17.4" r="1.3" />
  </Svg>
)

export const Thermometer = (p) => (
  <Svg {...p}>
    <path d="M13.8 13.4V5.6a1.8 1.8 0 1 0-3.6 0v7.8a3.6 3.6 0 1 0 3.6 0Z" />
    <path d="M12 15.4v-4" />
  </Svg>
)

export const Bolt = (p) => (
  <Svg {...p}>
    <path d="M13.4 2.8 5.2 13.4h5.6l-1 7.8 8.2-10.6h-5.6l1-7.8Z" />
  </Svg>
)

export const Signal = (p) => (
  <Svg {...p}>
    <path d="M12 19.4h.01" />
    <path d="M8.4 15.9a5.1 5.1 0 0 1 7.2 0" />
    <path d="M5.2 12.6a9.6 9.6 0 0 1 13.6 0" />
    <path d="M2.2 9.4a14 14 0 0 1 19.6 0" />
  </Svg>
)

/* Profil */
export const Globe = (p) => (
  <Svg {...p}>
    <circle cx="12" cy="12" r="8.4" />
    <path d="M3.6 12h16.8" />
    <path d="M12 3.6c2.1 2.3 3.3 5.3 3.3 8.4s-1.2 6.1-3.3 8.4c-2.1-2.3-3.3-5.3-3.3-8.4S9.9 5.9 12 3.6Z" />
  </Svg>
)

export const Mail = (p) => (
  <Svg {...p}>
    <rect x="3.2" y="5.6" width="17.6" height="12.8" rx="2.6" />
    <path d="m4.4 8 6.3 4.4a2.2 2.2 0 0 0 2.6 0L19.6 8" />
  </Svg>
)

export const Phone = (p) => (
  <Svg {...p}>
    <path d="M8.1 4.4h-2A2.1 2.1 0 0 0 4 6.7c.4 6.7 5.6 11.9 12.3 12.3a2.1 2.1 0 0 0 2.3-2.1v-2a1.4 1.4 0 0 0-1.1-1.4l-2.4-.5a1.4 1.4 0 0 0-1.4.6l-.7 1a11 11 0 0 1-4.4-4.4l1-.7a1.4 1.4 0 0 0 .6-1.4l-.5-2.4a1.4 1.4 0 0 0-1.4-1.1Z" />
  </Svg>
)

export const IdCard = (p) => (
  <Svg {...p}>
    <rect x="3" y="5.4" width="18" height="13.2" rx="2.8" />
    <circle cx="8.6" cy="10.8" r="1.9" />
    <path d="M5.6 15.8a3.4 3.4 0 0 1 6 0" />
    <path d="M14.4 10.4h4M14.4 13.8h2.8" />
  </Svg>
)

export const Check = (p) => (
  <Svg strokeWidth={2.4} {...p}>
    <path d="m5 12.6 4.6 4.6L19 6.8" />
  </Svg>
)

export const CreditCard = (p) => (
  <Svg {...p}>
    <rect x="2.6" y="5.4" width="18.8" height="13.2" rx="2.6" />
    <path d="M2.6 9.6h18.8" />
    <path d="M5.6 14.4h4.4" />
  </Svg>
)

export const X = (p) => (
  <Svg strokeWidth={2.2} {...p}>
    <path d="m6 6 12 12M18 6 6 18" />
  </Svg>
)

export const ChevronDown = (p) => (
  <Svg {...p}>
    <path d="m6 9 6 6 6-6" />
  </Svg>
)
