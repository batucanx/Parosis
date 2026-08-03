import { useState } from 'react'
import PhoneFrame from './components/PhoneFrame.jsx'
import AppHeader from './components/AppHeader.jsx'
import BottomNav from './components/BottomNav.jsx'
import HomeScreen from './screens/HomeScreen.jsx'
import ProgramScreen from './screens/ProgramScreen.jsx'
import InstantScreen from './screens/InstantScreen.jsx'
import BalanceScreen from './screens/BalanceScreen.jsx'
import TopUpScreen from './screens/TopUpScreen.jsx'
import ProfileScreen from './screens/ProfileScreen.jsx'

/** Alt sayfalar hangi navigasyon sekmesini aktif gösterecek. */
const tabOfScreen = {
  home: 'home',
  program: 'home',
  instant: 'home',
  balance: 'balance',
  topup: 'balance',
  profile: 'profile',
}

export default function App() {
  const [screen, setScreen] = useState('home')
  const [balance, setBalance] = useState(450)
  const [lastTopUp, setLastTopUp] = useState(null)

  const go = (next) => {
    setLastTopUp(null)
    setScreen(next)
  }

  const confirmTopUp = (amount) => {
    setBalance((b) => b + amount)
    setLastTopUp(amount)
    setScreen('balance')
  }

  const screens = {
    home: <HomeScreen onNavigate={go} />,
    program: <ProgramScreen onBack={() => go('home')} />,
    instant: <InstantScreen onBack={() => go('home')} />,
    balance: (
      <BalanceScreen balance={balance} lastTopUp={lastTopUp} onTopUp={() => go('topup')} />
    ),
    topup: <TopUpScreen onBack={() => go('balance')} onConfirm={confirmTopUp} />,
    profile: <ProfileScreen />,
  }

  return (
    <div className="app-bg flex min-h-dvh items-center justify-center sm:p-8">
      <PhoneFrame>
        <AppHeader balance={balance} onBalanceClick={() => go('balance')} />

        {/* key={screen}: ekran değişince scroll başa döner */}
        <main key={screen} className="no-scrollbar flex-1 overflow-y-auto pb-28">
          {screens[screen]}
        </main>

        <BottomNav activeTab={tabOfScreen[screen]} onChange={go} />
      </PhoneFrame>
    </div>
  )
}
