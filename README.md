# Empire Hookah Lounge — Dynamic Lounge Menu & Mix Lab 👑
> **EST. 2010 • Modern PWA for Social Lounge Ordering, Russian Shisha Mixology, Table Tabs & Stash Inventory**

[![Netlify Status](https://api.netlify.com/api/v1/badges/deploy-status)](https://app.netlify.com)

Official Repository: [https://github.com/Stoked-Spyre/Empire-Dynamic-Lounge-Menu.git](https://github.com/Stoked-Spyre/Empire-Dynamic-Lounge-Menu.git)

---

## 🌟 Key Features

### 1. 📱 Installable PWA & Responsive Mobile Experience
- **Progressive Web App (PWA)**: Installable directly to home screen on iOS and Android with `manifest.json` and service worker caching (`sw.js`).
- Fast offline resilience and instantaneous tap response.

### 2. 📍 Dynamic QR Table Routing & Multi-Person Party Sync
- **URL Parameter Table Detection**: Tables can be assigned via QR codes (e.g. `?table=6&section=VIP&pin=6010`).
- **Shared Party Sessions**:
  - The party host creates the table session.
  - Friends join via 4-digit Table PIN or direct link.
  - Supports unified table tabs or individual Square sub-tabs.
  - **Shared "Call Coals" button** synced with lounge staff.

### 3. 🧪 Russian & Tangiers Shisha Mix Lab (Inspired by Stoked)
- **Multi-stop Spectrum Gradient Ribbon**: Visual feedback representing exact blend color & ratio.
- **Pro Flavor Rows with Vertical Brand Rails**: Direct `[-] / [+]` percentage steppers and live gram counters (e.g., `15.4g Pinkman + 6.6g Cane Mint`).
- **Live Composite Flavor Profile Tags & Strength Meter**: Real-time buzz rating (1–10) calculated based on Russian Dark Leaf (MustHave, Darkside, BlackBurn, Element) and Tangiers Noir blends.
- **1-Tap Bowl Portions**: Russian Phunnel (22g), Tangiers Clay (24g), Fruit Head (35g), plus Ice Hose Tip add-on.

### 4. 📦 Backend Stash & Inventory Management Portal
- **Local-First Database**: Runs seamlessly on local storage with instant reactivity and persistent state.
- **Gram-Level Deduction Engine**: When bowls are dispatched, exact portion grams are automatically deducted from the tobacco inventory.
- **Stash Manager**:
  - Add new tobacco tins/flavors with brand, cut, initial grams, and flavor notes.
  - Restock shortcuts (+200g tins) and low-stock warning badges (< 50g remaining).
  - Live Consumption Audit Log tracking table deductions in real-time.
- **Supabase Cloud Sync Ready**: Built to plug straight into Supabase PostgreSQL when your cloud project is ready.

### 5. 🔥 Staff & Coal Master KDS (Kitchen Display System)
- Real-time alert board showing active table requests, coal rotation timers, and exact gram recipes for coal masters and baristas.

### 6. 🎨 Configurable Brand Theme Engine
- Live theme customizer with customizable CSS variables (`Moscow Neon & Gold`, `Royal Empire Amber`, `Siberian Mint Emerald`).

---

## 🚀 Local Development

To run the local development server:

```bash
# Start Node.js static server on port 3000
node server.js
```

Then open **[http://localhost:3000](http://localhost:3000)** in your browser.

---

## 🌐 Free Deployment on Netlify

1. Push this repository to GitHub:
   ```bash
   git add .
   git commit -m "feat: initial release of Empire Dynamic Lounge Menu PWA"
   git push -u origin main
   ```
2. Link your GitHub repository in the **Netlify Dashboard**.
3. The included `netlify.toml` will handle publishing the project with HTTPS and security headers with zero configuration!

---

## 🗄️ Supabase Migration Schema (When Cloud Ready)

```sql
-- Tobacco Stash Table
create table lounge_stash (
  id text primary key,
  brand text not null,
  name text not null,
  line text,
  grams numeric default 200,
  strength integer default 7,
  color text default '#A855F7',
  profile text[],
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Table Sessions Table
create table table_sessions (
  id uuid default gen_random_uuid() primary key,
  table_number integer not null,
  table_name text not null,
  party_pin text not null,
  host_name text not null,
  active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Consumption Audit Log
create table consumption_logs (
  id uuid default gen_random_uuid() primary key,
  table_number integer not null,
  flavor_name text not null,
  brand text not null,
  grams numeric not null,
  timestamp timestamp with time zone default timezone('utc'::text, now())
);
```

---

*© 2010–Present Empire Hookah Lounge. All rights reserved.*
