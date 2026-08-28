# Empire Hookah Lounge & Stoked POS — Complete Application Specification

**Version**: 2.4.0 (Production Pilot)  
**Repository**: [https://github.com/Stoked-Spyre/Empire-Dynamic-Lounge-Menu](https://github.com/Stoked-Spyre/Empire-Dynamic-Lounge-Menu)  
**Ecosystem**: Powered by [Stoked Hookah Network](https://stokedhookah.netlify.app)  

---

## 1. System Overview

The **Empire Hookah Lounge Suite** is a high-performance, dual-application hospitality and point-of-sale platform specifically engineered for craft hookah lounges. It bridges customer-facing digital sommelier menus with live staff floor management, coal cycle tracking, and payment settlement.

The suite consists of two synchronized, zero-build Progressive Web Applications:
1. **Staff Operations Deck (`staff.html`)**: The server and floor manager dashboard for seating management, 25-minute coal cycle monitoring, 3-column sommelier blend formulation, and tab settlement.
2. **Customer QR Menu & Mix Lab (`index.html`)**: The guest-facing editorial cocktail-style menu, VIP tasting passport, and interactive bowl customizer.

---

## 2. Technical Stack & Architecture

* **Frontend Engine**: Pure HTML5, CSS3, Tailwind CSS (via CDN), and Vanilla JavaScript (ES6+). Zero build-step or compilation required.
* **Database & Catalog**: Direct client-side SDK connection to **Supabase PostgreSQL** (`https://zwrryhzynpbyqyecyomz.supabase.co`) containing 6,037 master tobacco flavors and botanical category mappings.
* **Shift Resilience & Offline Caching**: Complete offline fallback via `localStorage` (`empire_cached_flavors`) ensuring uninterrupted table service if lounge Wi-Fi disconnects.
* **Audio Synthesis**: Native Web Audio API oscillator synthesizing custom alert chimes for new kitchen orders, coal cycles, and service checks.
* **Case Ergonomics & Touch Design**: 18px–24px perimeter bezel safe-zones and 48px+ touch targets optimized for rugged commercial tablet enclosures and center hand-straps.

---

## 3. Staff Operations POS Deck (`staff.html`)

### 3.1. Top Luxury App Bar
* **Station Brand**: Empire Crest with live operational status indicator (`● LIVE`).
* **Co-Branding**: Quiet, unobtrusive link to `https://stokedhookah.netlify.app`.
* **Operational Counters**: Real-time counter of **Active Seated Tables** and **Total Pending Action Items** (Coals overdue + Service checks due + Kitchen orders pending).
* **Audio Synthesizer Toggle**: 1-tap `AUDIO: ON / MUTED` toggle for shift volume control.
* **Simulation Trigger**: `+ TEST` button to simulate random real-world incoming orders, 25m coal alerts, or 5m service checks during staff training.

### 3.2. Live Action Dock (Left Column)
A dedicated, real-time prioritization queue that alerts staff to 4 distinct operational events:
1. **Incoming Kitchen / Bar Orders**: Displays bowl recipes, pipe choices, or beverage orders placed from guest QR menus with a 1-tap `DISPATCH` / `RUN DRINK` button.
2. **25-Minute Coal Cycle Alerts**: Automatically turns high-contrast red when a seated table reaches 25 minutes without coal maintenance, calculating exact overdue minutes.
3. **5-Minute Service Quality Checks**: Alerts servers when a new party has been seated for 5 minutes without a quality check.
4. **Table Service Requests**: Displays guest requests for bill splitting, refills, or server assistance.

### 3.3. Seating Controller & Floorplan (Center/Right Column)
* **View Switcher**: Toggle between **OpenTable Floor Map** and **Pods Grid**.
* **Zone Filters**: Instant filtering by `ALL ZONES`, `VIP BOOTHS`, `INDOOR FLOOR`, `MAIN BAR`, and `PATIO`.
* **OpenTable Interactive 2D Canvas**:
  - Architectural landmarks: Main Bar Counter, DJ Stage, Host Entrance, Patio Deck.
  - Interactive Table Nodes: Tactile seating pods displaying live seated duration (`48m`), live guest names, and pulsating color states (`Green: Active`, `Amber: Service Due`, `Red: Coals Due`).
  - 1-tap click on any table opens the **Table Full-Screen Modal Deck**.

### 3.4. Table Full-Screen Modal Deck
A comprehensive, two-tab management canvas:

#### Tab 1: Tab & POS Settlement
* **Itemized Active Tab**: Live listing of hookahs, refills, and drinks with individual delete/remove triggers.
* **Automatic Tax Calculation**: Standard 8.6% state and local sales tax calculation.
* **Gratuity Presets**: 1-tap tip calculators (`18%`, `20%`, `25%`, `None`).
* **Tender Settlement**:
  - `Cash`: Records cash transactions and calculates change.
  - `Card`: Tenders via standard credit/debit card.
  - `Square`: Triggers Square POS settlement.
  - `Settle & Close Table`: Closes tab, frees table node on the floor map, and clears timers.

#### Tab 2: Sommelier Mix Lab (3-Column Layout)
* **Column 1 (Left): Tobacco Houses & Flavor Profiles**:
  - **Signature House Mixes (Default)**: Pre-loaded craft recipes.
  - **Brand Houses**: MustHave, Tangiers, Darkside, BlackBurn, Al Fakher, Starbuzz, Adalya.
  - **11 Stoked Flavor Profiles**: Berries, Citruses, Mints, Desserts, Dairy, Warm Spices, Tropical, Orchard, Herbal, Candy, Sour.
  - **Beverages Button**: Quick-access to chilled soft drinks, Red Bull editions, and Russian Samovar Teapots.
* **Column 2 (Center): Active Pack Formulation Bench**:
  - **Stoked Continuous Flavor Spectrum**: Multi-stop dynamic CSS gradient visualizing the exact flavor ratio boundaries.
  - **Physical / Draggable Divider Pins**: Visual divider lines with numerical badges (e.g. `70%`) marking flavor transitions.
  - **Flavor Steppers**: +/- percentage ratio adjusters that automatically balance formulations to 100%.
  - **Buzz Rating Gauge**: Dynamic nicotine intensity rating (0.0 to 10.0) with category classifications (`MILD BLONDE`, `MEDIUM`, `BOLD DARK`, `NOIR RESERVE`).
  - **1-Tap Hardware Touch Chips (Zero Dropdowns)**:
    - *Pipe*: Steamulation Pro X III, Regal King Wood, Alpha Model X, MIG Armour.
    - *Clay Bowl*: Russian Phunnel, Alpaca Mini Rook, Oblako Mono, Solaris Classic.
    - *Heat Regulation (HMD)*: Kaloud Lotus III, Provost HMD, Direct Foil.
  - **Member Hospitality Notes**: Displays guest biography, past smoking history, and 1-tap re-order button.
* **Column 3 (Right): Dynamic Catalog**:
  - Displays filtered flavor cards or house mix recipes with botanical gradient swatches and 1-tap `+ ADD` / `1-Tap Load` buttons.
* **Floating Bottom Order Tray**:
  - Staged order chips with botanical dots, live calculated total, and large `Submit Order` button.

---

## 4. Customer QR Menu & Mix Lab (`index.html`)

### 4.1. Cinematic Noir Entry Stage
* **Hand-Drawn Etching Artwork**: High-contrast architectural skyline background.
* **60FPS Floating Crest**: Glowing Empire brand emblem.
* **Lounge Policies**: 21+ Federal Tobacco law link, 2-person-per-pipe policy, outside beverage rules.
* **Powered by Stoked**: Minimalist link to `https://stokedhookah.netlify.app`.

### 4.2. Editorial Cocktail-Style Menu Spread
* **Atmospheric Typography**: Serif display headings with wide letter-spacing (`Cinzel` / `Playfair`) paired with crisp monospace annotations.
* **Dotted Leader Lines**: Clean `Item ............ $Price` classic menu layout with zero cluttered boxes or heavy borders.
* **Tasting Descriptions & Leaf Origins**: Monospace leaf lineage (`MustHave · Moscow, Russia`, `Tangiers · San Diego, USA`) with italic botanical notes.

### 4.3. Customer Mixology Bench
* Interactive customer-facing mix builder allowing guests at tables to build custom blends, preview buzz scores, and dispatch orders to the staff deck.

### 4.4. VIP Member Portal & Stoked Tasting Passport
* **Unified Account Registration**: Name, Email, Phone, Password, and Date of Birth (21+ compliance).
* **Supabase Integration**: Asynchronously syncs guest profiles to the Stoked `user_profiles` table with `home_lounge: "empire-hookah-lounge"`.
* **Welcome Bonus**: 100 reward points credited upon registration.
* **Smoke History**: Logs past blends, nicotine ratings, and favorite hardware setups.

### 4.5. Table Tab & Settle View
* Itemized live receipt with subtotal, tax, gratuity selector, and custom tip drawer.
* Server bill split request button and checkout triggers.

---

## 5. Stoked Botanical Flavor Engine & Mathematics

The core flavor science engine is shared directly with the Stoked web application:

### 21 Canonical Category Color System
```javascript
const defaultFlavorCategories = [
  { id: "mints", label: "Mints", color: "#00f0ff" },
  { id: "berries", label: "Berries", color: "#ff3366" },
  { id: "citruses", label: "Citruses", color: "#ffcc00" },
  { id: "tropical", label: "Tropical", color: "#ff8c00" },
  { id: "apple", label: "Apple", color: "#22c55e" },
  { id: "orchard", label: "Orchard Fruit", color: "#fb923c" },
  { id: "desserts", label: "Desserts", color: "#c084fc" },
  { id: "dairy", label: "Dairy / Creamy", color: "#e0e7ff" },
  { id: "warm-spices", label: "Warm Spices", color: "#d97706" },
  { id: "florals", label: "Florals", color: "#ff66b2" },
  { id: "herbal", label: "Herbal", color: "#10b981" },
  { id: "beverages", label: "Beverages", color: "#3b82f6" },
  { id: "candy", label: "Candy", color: "#ec4899" },
  { id: "sour", label: "Sour", color: "#ccff00" }
];
```

### Dynamic Multi-Stop Gradient Algorithm (`getMixCategoryGradient`)
Calculates cumulative percentage ranges across N flavors in a bowl pack, producing a continuous multi-stop CSS gradient that accurately blends each flavor's botanical notes.

---

## 6. Data Siloing & Privacy Safeguards

| Data Type | Privacy Scope | Storage Location |
| :--- | :--- | :--- |
| **Sales Totals & Itemized Tabs** | **Strictly Private to Empire** | Local Lounge Database / Siloed RLS |
| **Staff Hospitality Notes** | **Strictly Private to Empire** | Local Staff Database |
| **User Flavor Palate & Buzz Tolerance** | **Portable with Customer** | Stoked Supabase `user_profiles` |
| **Personal Saved Recipes** | **Portable with Customer** | Stoked Supabase `mixes` |

---

## 7. Operational Deployment Links

* **Live Staff POS**: [http://192.168.1.235:8080/staff.html](http://192.168.1.235:8080/staff.html)
* **Live Customer Menu**: [http://192.168.1.235:8080/index.html](http://192.168.1.235:8080/index.html)
* **GitHub Repository**: [https://github.com/Stoked-Spyre/Empire-Dynamic-Lounge-Menu](https://github.com/Stoked-Spyre/Empire-Dynamic-Lounge-Menu)
* **Architecture Master Plan**: [https://github.com/Stoked-Spyre/Empire-Dynamic-Lounge-Menu/blob/main/LOUNGE_ECOSYSTEM_ARCHITECTURE.md](https://github.com/Stoked-Spyre/Empire-Dynamic-Lounge-Menu/blob/main/LOUNGE_ECOSYSTEM_ARCHITECTURE.md)
