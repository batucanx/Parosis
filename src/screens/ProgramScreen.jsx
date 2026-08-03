import PageHeading from '../components/PageHeading.jsx'
import WellList from '../components/WellList.jsx'

export default function ProgramScreen({ onBack }) {
  return (
    <div className="screen-in flex flex-col gap-5 px-5 pb-6 pt-2">
      <PageHeading
        title="Program Sulama"
        subtitle="Sulama planlamak için kuyu seçin"
        onBack={onBack}
      />
      <WellList />
    </div>
  )
}
