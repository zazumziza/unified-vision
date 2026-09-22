import { useMemo, useState } from 'react'
import type { ReactNode } from 'react'
import { Compass, Flame, Inbox, Music2, Play, Plus, UserRound } from 'lucide-react'
import type { BtInteraction } from '../domain/canon'
import type { EventCard, TrackCard } from '../types/domain'

const tracks: TrackCard[] = [
  { id: 't1', title: 'Verified Heat', artist: 'Toxic Lyrikali', scene: 'Nairobi · Gengetone', cover: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=900&q=80', duration: '2:48', verified: true },
  { id: 't2', title: 'Umoja Nights', artist: 'Mbogi Genje', scene: 'Nairobi · Ghetto Sound', cover: 'https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?auto=format&fit=crop&w=900&q=80', duration: '3:12' },
]

const events: EventCard[] = [
  { id: 'e1', title: 'Nairobi Night Shift', venue: 'Nairobi CBD', date: 'SAT · 7 PM', city: 'Nairobi', image: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=900&q=80' },
]

type Nav = 'Discover' | 'Feed' | 'Inbox' | 'Profile'

function App() {
  const [nav, setNav] = useState<Nav>('Discover')
  const [selectedTrack, setSelectedTrack] = useState(tracks[0])
  const [repeat, setRepeat] = useState(false)
  const [bigUps, setBigUps] = useState<Record<string, number>>({})
  const [showActions, setShowActions] = useState(false)

  const selectedBigUps = bigUps[selectedTrack.id] ?? 0
  const navTitle = useMemo(() => ({
    Discover: 'What’s moving.',
    Feed: 'Your people.',
    Inbox: 'Stay in the loop.',
    Profile: 'Your BT.',
  }[nav]), [nav])

  function interact(action: BtInteraction) {
    if (action === 'BIG UP') setBigUps((current) => ({ ...current, [selectedTrack.id]: (current[selectedTrack.id] ?? 0) + 1 }))
    if (action === 'ON REPEAT') setRepeat((value) => !value)
  }

  return (
    <div className="app-shell">
      <header className="topbar">
        <div className="wordmark"><span>BT</span><strong>BIGTUNE254</strong></div>
        <button className="join-button">JOIN BT</button>
      </header>

      <main className="content">
        <section className="hero">
          <div>
            <div className="eyebrow">KENYA MUSIC INTELLIGENCE</div>
            <h1>{navTitle}</h1>
            <p>Discover the people, sounds, scenes and moments moving Kenyan music.</p>
          </div>
          <button className="icon-button" aria-label="Create" onClick={() => setShowActions((v) => !v)}><Plus size={20}/></button>
        </section>

        {showActions && <div className="action-strip"><button>POST</button><button>SHARE TRACK</button><button>ADD EVENT</button></div>}

        {nav === 'Discover' && (
          <>
            <section className="section">
              <div className="section-heading"><span>PLAY THIS</span><small>LIVE DISCOVERY</small></div>
              <article className="feature-card" onClick={() => setSelectedTrack(tracks[0])}>
                <img src={tracks[0].cover} alt="" />
                <div className="feature-overlay">
                  <div className="badge">BAD TUNE 🔥</div>
                  <h2>{tracks[0].title}</h2>
                  <p>{tracks[0].artist} · {tracks[0].scene}</p>
                  <button className="play-button"><Play fill="currentColor" size={18}/> PLAY</button>
                </div>
              </article>
            </section>

            <section className="section">
              <div className="section-heading"><span>EMERGING NOW</span><small>OBSERVED MOMENTUM</small></div>
              <div className="track-stack">
                {tracks.map((track) => (
                  <button key={track.id} className={selectedTrack.id === track.id ? 'track-row active' : 'track-row'} onClick={() => setSelectedTrack(track)}>
                    <img src={track.cover} alt="" />
                    <span className="track-meta"><strong>{track.title}</strong><small>{track.artist} · {track.scene}</small></span>
                    <span className="track-time">{track.duration}</span>
                  </button>
                ))}
              </div>
            </section>

            <section className="section">
              <div className="section-heading"><span>WHAT’S HAPPENING</span><small>EVENTS</small></div>
              {events.map((event) => <article className="event-card" key={event.id}>
                <img src={event.image} alt="" />
                <div><div className="event-date">{event.date}</div><h3>{event.title}</h3><p>{event.venue} · {event.city}</p></div>
              </article>)}
            </section>
          </>
        )}

        {nav === 'Feed' && <section className="feed-list">
          <article className="activity"><div className="avatar">Z</div><div><strong>Zawadi</strong> put you on to <b>Umoja Nights</b><span>12 min ago</span></div></article>
          <article className="activity"><div className="avatar gold">91</div><div><strong>BIGTUNE254</strong> dropped a new scene pulse<span>1 hr ago</span></div></article>
        </section>}

        {nav === 'Inbox' && <section className="inbox">
          <div className="inbox-item"><div><strong>R3CS Records</strong><small>Release update available</small></div><span>NEW</span></div>
          <div className="inbox-item"><div><strong>Event reminder</strong><small>Nairobi Night Shift starts Saturday</small></div><span>2h</span></div>
        </section>}

        {nav === 'Profile' && <section className="profile-card">
          <div className="profile-top"><div className="profile-avatar">R</div><div><h2>Ramogi</h2><p>Fan · Creator · Community</p></div></div>
          <div className="profile-grid"><div><strong>14</strong><span>BIG UPS</span></div><div><strong>8</strong><span>FOLLOWING</span></div><div><strong>3</strong><span>ON REPEAT</span></div></div>
          <button className="secondary-button">CLAIM / CREATE ARTIST IDENTITY</button>
        </section>}
      </main>

      <aside className="player-bar">
        <div className="player-track"><div className="mini-art"><Music2 size={18}/></div><div><strong>{selectedTrack.title}</strong><span>{selectedTrack.artist}</span></div></div>
        <div className="player-actions">
          <button onClick={() => interact('PULL UP')}>PULL UP</button>
          <button className={repeat ? 'selected' : ''} onClick={() => interact('ON REPEAT')}>ON REPEAT</button>
          <button onClick={() => interact('BIG UP')}><Flame size={16}/> {selectedBigUps}</button>
        </div>
      </aside>

      <nav className="bottom-nav">
        <NavButton label="Discover" active={nav === 'Discover'} onClick={() => setNav('Discover')} icon={<Compass size={19}/>} />
        <NavButton label="Feed" active={nav === 'Feed'} onClick={() => setNav('Feed')} icon={<Music2 size={19}/>} />
        <NavButton label="Inbox" active={nav === 'Inbox'} onClick={() => setNav('Inbox')} icon={<Inbox size={19}/>} />
        <NavButton label="Profile" active={nav === 'Profile'} onClick={() => setNav('Profile')} icon={<UserRound size={19}/>} />
      </nav>
    </div>
  )
}

function NavButton({ label, active, onClick, icon }: { label: Nav; active: boolean; onClick: () => void; icon: ReactNode }) {
  return <button className={active ? 'nav-item active' : 'nav-item'} onClick={onClick}>{icon}<span>{label}</span></button>
}

export default App
