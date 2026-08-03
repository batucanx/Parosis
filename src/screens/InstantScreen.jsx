import { useState } from 'react'
import PageHeading from '../components/PageHeading.jsx'
import WellList from '../components/WellList.jsx'

export default function InstantScreen({ onBack }) {
  // Prototip: hangi kuyunun sulaması başlatıldı
  const [startedId, setStartedId] = useState(null)

  return (
    <div className="screen-in flex flex-col gap-5 px-5 pb-6 pt-2">
      <PageHeading
        title="Anlık Sulama"
        subtitle="Hemen başlatmak için kuyu seçin"
        onBack={onBack}
      />
      <WellList startedId={startedId} onStart={(well) => setStartedId(well.id)} />
    </div>
  )
}
