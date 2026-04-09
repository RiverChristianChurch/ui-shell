# RCC Website Rebuild — UI Shell Options

Five UI shell concepts for riverchristian.church, informed by research of top large-church websites (Elevation, Life.Church, VOUS, Hillsong, Church of the Highlands, Passion City, Bethel, Transformation Church).

Open each HTML file in a browser to preview.

---

## The Five Options

### Option 1: Clean & Welcoming
**File:** `options/option-1-clean-welcoming.html`
**Inspiration:** Life.Church / Elevation Church
**Vibe:** Bright, warm, visitor-first, approachable

- Light backgrounds with warm cream accents
- Rounded pill buttons, friendly typography (DM Sans + Inter)
- Split hero with image + text side-by-side
- Service times strip in brand teal
- Card-based ministries and events
- Floating badge element for service times

**Best for:** Maximum approachability. Feels like a warm handshake. Great for visitor conversion.

---

### Option 2: Bold & Cinematic
**File:** `options/option-2-bold-cinematic.html`
**Inspiration:** VOUS Church / Passion City Church
**Vibe:** Dark hero, bold display type, video-forward, high contrast

- Full-screen dark hero with `Bebas Neue` display font
- Dramatic dark-to-light transition mid-page
- Numbered step cards for the discipleship pathway
- Image-overlay ministry grid with hover reveals
- Minimal event rows with hover slide animation
- Gold accent color for energy

**Best for:** High-energy worship culture. Feels cinematic and confident. Appeals to younger demographics.

---

### Option 3: Super Modern / Edgy ⚡
**File:** `options/option-3-edgy-modern.html`
**Inspiration:** VOUS meets editorial/brutalist design
**Vibe:** Asymmetric, oversized type, bento grid, dark mode, grain texture

- Full-bleed hero with outlined + filled type contrast (Syne font)
- Scrolling marquee ticker for service info
- **Bento grid layout** — mixed-size cards in a magazine-style grid
- Lime green (`#c4f751`) accent for edge and energy
- Horizontal-scroll event cards
- Film grain texture overlay
- `mix-blend-mode: difference` header that adapts to content

**Best for:** Standing out from every other church website. Feels like a creative agency site. Youngest-skewing option by far.

---

### Option 4: Warm & Organic
**File:** `options/option-4-warm-organic.html`
**Inspiration:** Church of the Highlands / North Point
**Vibe:** Earthy tones, serif headlines, rounded shapes, community-first

- Forest green (`#2c5f4a`) + warm terra cotta (`#d4956b`) palette
- `Lora` serif for headlines — feels classic yet modern
- Staggered hero photo row (different aspect ratios)
- Testimonial section with full-color background
- Rounded everything — cards, buttons, images
- Portal in a soft cream card container

**Best for:** Emphasizing warmth and roots. Feels established, trustworthy, and family-oriented. Great for a church with deep community ties.

---

### Option 5: Minimal & Editorial
**File:** `options/option-5-minimal-editorial.html`
**Inspiration:** Hillsong / Bethel / high-end editorial
**Vibe:** Magazine-quality whitespace, elegant serif headlines, refined grid

- `Instrument Serif` for headlines — sophisticated and intentional
- Two-column hero with meta data strip (service times, location)
- Full-width cinematic image below hero
- Grid-line aesthetic — bordered cells, dividers, structure
- Ministry list as clean rows (not cards)
- Portal as a bordered card grid — feels like a product dashboard
- Minimal color — relies on typography and spacing

**Best for:** Sophistication and intentionality. Feels like a well-designed magazine. Appeals to design-conscious audiences.

---

## Shared Design Decisions

All five options share these patterns based on research:

| Decision | Rationale |
|----------|-----------|
| **6-7 nav items max** | Top churches (Elevation has 4) keep nav ruthlessly simple |
| **"I'm New" / "Plan a Visit" as primary CTA** | Visitor-first design — homepage exists for first-timers |
| **"Give" always visible** | Every major church keeps it in primary nav |
| **Sign In button in header** | Portal access without cluttering nav |
| **Latest message prominent** | 87% of churches still stream; sermon is the primary draw |
| **Event cards from PCO** | Planning Center Calendar integration auto-populates |
| **Growth pathway (4 steps)** | Visit → Connect → Grow → Serve is the universal pattern |
| **Mobile-first responsive** | 60%+ of church traffic is mobile, spikes on Sunday |

---

## Planning Center Integration — Member Portal Ideas

### Auth Flow
- **OAuth 2.0 via Planning Center** — members sign in with their existing PCO credentials
- No separate account creation needed — if they're in PCO People, they can sign in
- PCO provides OAuth tokens scoped to the specific app permissions you configure

### Core Portal Features (PCO APIs)

| Feature | PCO Product | What It Does |
|---------|-------------|--------------|
| **Giving Dashboard** | PCO Giving | View donation history, manage recurring gifts, download year-end tax statements |
| **Serve Schedule** | PCO Services | See upcoming volunteer schedule, confirm/decline, request swaps, block out dates |
| **My Groups** | PCO Groups | View enrolled LifeGroups, see group members, access group chat/messaging |
| **Event Registration** | PCO Registrations | Browse and sign up for events, manage family registrations, see confirmation status |
| **Profile Management** | PCO People | Update contact info, address, phone, email — syncs back to PCO |
| **Check-In** | PCO Check-Ins | Pre-check-in for kids ministry before arriving Sunday |
| **Prayer Requests** | Custom + PCO | Submit prayer needs that route to prayer team; optional community prayer wall |
| **Growth Track Progress** | PCO People (custom fields) | Track completion of each Growth Track session via custom person fields |

### Enhanced Experience Ideas

| Feature | Description |
|---------|-------------|
| **Personalized Homepage** | Detect signed-in vs. visitor — show "Welcome back, Jason" with dashboard shortcuts vs. "Plan a Visit" hero |
| **Sunday Smart Mode** | On Sunday mornings, swap the hero to "We're Live" with embedded stream + live chat + prayer request button |
| **Digital Connect Card** | Replace paper cards — visitors fill out info that goes straight into PCO People as a new person with a "First-Time Visitor" tag |
| **Sermon Notes** | Members can take notes during the message, saved to their profile, searchable later |
| **Family Dashboard** | Parents see kids' check-in history, upcoming family events, kids ministry updates |
| **Volunteer Onboarding** | Self-service application flow → background check → team assignment → schedule, all tracked in PCO |
| **Giving Challenges** | Opt-in giving goals (e.g., "Give consistently for 3 months") with progress tracking |
| **Anniversary/Birthday Notices** | Auto-generated messages from PCO data — pastoral care automation |
| **Member Directory** | Opt-in directory where members choose what to share (photo, phone, email, neighborhood) |
| **Push Notifications** | Serve reminders, event updates, new sermon alerts via PWA or app |

### Tech Architecture (Recommendation)
- **Frontend:** Vue 3 (consistent with your existing modern blocks POC) or Nuxt 3 for SSR
- **Auth:** Planning Center OAuth 2.0 → JWT session
- **API Layer:** Lightweight Node/Express or Nuxt server routes proxying PCO API calls
- **Data:** PCO is the system of record — no separate database needed for most features
- **Hosting:** Vercel/Netlify (static + serverless) or your existing WordPress with a `/portal` route

---

## Current Site Analysis

Your existing site (Divi + WordPress) has:
- 55 pages across About, Watch, Next Steps, Ministries, Events, Give
- Brand color shifting from Divi default blue to deeper teal `#095879`
- Modern blocks POC already in progress (ACF + Vue 3)
- Strong ministry structure (Kids, Students, Men, Women, Care, Outreach)
- Mission: "Win People · Train Believers · Unleash Disciples"

## Next Steps

1. **Pick a direction** — or mix elements (e.g., Option 3's bento grid + Option 5's typography)
2. **Photography** — every top church site uses authentic, professional photography of real people. This is the #1 differentiator.
3. **Decide on WordPress vs. custom** — continue with WP + custom theme, or go headless/Nuxt
4. **PCO OAuth app setup** — register an app in Planning Center Developer portal
5. **Build out the chosen shell** into a real project with routing, components, and PCO integration
