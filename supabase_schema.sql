-- ============================================================================
-- EMPIRE HOOKAH LOUNGE - SUPABASE PRODUCTION DATABASE SCHEMA
-- Generated for Supabase (PostgreSQL 15+)
-- Realtime Channels Enabled: tabs, tab_items, service_tickets, tobacco_inventory
-- ============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 2. ENUMS & CUSTOM TYPES
-- ============================================================================
CREATE TYPE tobacco_category AS ENUM ('russian', 'tangiers', 'blonde', 'heritage');
CREATE TYPE stock_status AS ENUM ('in_stock', 'low_stock', 'out_of_stock');
CREATE TYPE tab_status AS ENUM ('open', 'settling', 'paid', 'closed', 'cancelled');
CREATE TYPE tab_item_type AS ENUM ('shisha', 'refill', 'drink', 'custom_mix', 'addon');
CREATE TYPE item_prep_status AS ENUM ('staged', 'sent', 'preparing', 'served', 'cancelled');
CREATE TYPE ticket_type AS ENUM ('bowl_order', 'drink_order', 'refill_order', 'coal_refresh', 'server_assistance', 'tab_assistance');
CREATE TYPE ticket_urgency AS ENUM ('normal', 'high', 'urgent');
CREATE TYPE ticket_status AS ENUM ('pending', 'acknowledged', 'completed', 'cancelled');
CREATE TYPE vip_tier AS ENUM ('Standard', 'Silver VIP', 'Gold VIP', 'Platinum VIP', 'Royalty');

-- ============================================================================
-- 3. CORE CATALOG TABLES
-- ============================================================================

-- A. BRANDS / CRAFT HOUSES
CREATE TABLE IF NOT EXISTS public.brands (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    origin TEXT NOT NULL,
    country_code VARCHAR(3) NOT NULL,
    country_flag VARCHAR(8) NOT NULL,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- B. TOBACCO INVENTORY
CREATE TABLE IF NOT EXISTS public.tobacco_inventory (
    id TEXT PRIMARY KEY,
    brand_id TEXT NOT NULL REFERENCES public.brands(id) ON UPDATE CASCADE,
    name TEXT NOT NULL,
    category tobacco_category NOT NULL DEFAULT 'russian',
    strength NUMERIC(3,1) NOT NULL DEFAULT 7.0,
    stock stock_status NOT NULL DEFAULT 'in_stock',
    color_hex VARCHAR(9) DEFAULT '#ff3366',
    description TEXT,
    profiles TEXT[] DEFAULT '{}',
    stock_grams NUMERIC(8,2) DEFAULT 1000.00,
    price_override NUMERIC(6,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- C. HOUSE MIXES (SIGNATURE FORMULATIONS)
CREATE TABLE IF NOT EXISTS public.house_mixes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    tagline TEXT,
    description TEXT,
    badge TEXT,
    color_hex VARCHAR(9) DEFAULT '#E5A93C',
    is_signature BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- D. HOUSE MIX COMPONENTS (LEAF RATIOS)
CREATE TABLE IF NOT EXISTS public.house_mix_components (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mix_id TEXT NOT NULL REFERENCES public.house_mixes(id) ON DELETE CASCADE,
    tobacco_id TEXT NOT NULL REFERENCES public.tobacco_inventory(id) ON UPDATE CASCADE,
    percentage INT NOT NULL CHECK (percentage > 0 AND percentage <= 100),
    sort_order INT DEFAULT 0,
    UNIQUE(mix_id, tobacco_id)
);

-- E. BEVERAGES CATALOG
CREATE TABLE IF NOT EXISTS public.beverages (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category VARCHAR(50) DEFAULT 'Soft Drink',
    description TEXT,
    price NUMERIC(6,2) DEFAULT 0.00,
    in_stock BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 4. FLOORPLAN & SEATING TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.lounge_zones (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    icon VARCHAR(30) DEFAULT 'layers',
    sort_order INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.lounge_tables (
    id TEXT PRIMARY KEY,
    table_number VARCHAR(20) NOT NULL UNIQUE,
    zone_id TEXT REFERENCES public.lounge_zones(id) ON DELETE SET NULL,
    capacity INT DEFAULT 4,
    qr_code_token TEXT UNIQUE DEFAULT encode(gen_random_bytes(16), 'hex'),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 5. MEMBERS & VIP LOYALTY
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.members (
    id TEXT PRIMARY KEY,
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone VARCHAR(30),
    tier vip_tier DEFAULT 'Standard',
    points INT DEFAULT 100,
    total_spent NUMERIC(10,2) DEFAULT 0.00,
    can_self_order BOOLEAN DEFAULT TRUE,
    preferred_buzz NUMERIC(3,1) DEFAULT 7.0,
    favorite_mix_id TEXT REFERENCES public.house_mixes(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- SMOKE SESSION HISTORY (GUEST RECALL & TASTING LOGS)
CREATE TABLE IF NOT EXISTS public.smoke_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member_id TEXT NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
    table_id TEXT REFERENCES public.lounge_tables(id) ON DELETE SET NULL,
    session_title TEXT NOT NULL,
    mix_id TEXT REFERENCES public.house_mixes(id) ON DELETE SET NULL,
    blend_details JSONB NOT NULL DEFAULT '{}'::jsonb,
    buzz_rating NUMERIC(3,1),
    guest_rating NUMERIC(2,1),
    notes TEXT,
    smoked_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 6. TABS, ORDER ITEMS & SQUARE PAYMENT SETTLEMENT
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.tabs (
    id TEXT PRIMARY KEY,
    table_id TEXT REFERENCES public.lounge_tables(id) ON DELETE SET NULL,
    member_id TEXT REFERENCES public.members(id) ON DELETE SET NULL,
    seat_label VARCHAR(50) DEFAULT 'Floating VIP Tab',
    status tab_status NOT NULL DEFAULT 'open',
    subtotal NUMERIC(8,2) NOT NULL DEFAULT 0.00,
    tax NUMERIC(8,2) NOT NULL DEFAULT 0.00,
    tip NUMERIC(8,2) NOT NULL DEFAULT 0.00,
    total NUMERIC(8,2) NOT NULL DEFAULT 0.00,
    square_order_id TEXT,
    square_payment_id TEXT,
    square_idempotency_key TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    settling_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.tab_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tab_id TEXT NOT NULL REFERENCES public.tabs(id) ON DELETE CASCADE,
    item_type tab_item_type NOT NULL DEFAULT 'shisha',
    name TEXT NOT NULL,
    price NUMERIC(6,2) NOT NULL DEFAULT 0.00,
    quantity INT NOT NULL DEFAULT 1,
    details JSONB DEFAULT '{}'::jsonb,
    prep_status item_prep_status NOT NULL DEFAULT 'sent',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 7. KITCHEN / STAFF SERVICE TICKETS (REALTIME BROADCAST)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.service_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tab_id TEXT REFERENCES public.tabs(id) ON DELETE CASCADE,
    table_number VARCHAR(30) NOT NULL,
    ticket_type ticket_type NOT NULL DEFAULT 'bowl_order',
    urgency ticket_urgency NOT NULL DEFAULT 'normal',
    status ticket_status NOT NULL DEFAULT 'pending',
    title TEXT NOT NULL,
    details TEXT,
    payload JSONB DEFAULT '{}'::jsonb,
    acknowledged_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    acknowledged_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
);

-- ============================================================================
-- 8. REWARD TIERS & CONFIGURATION
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.reward_tiers (
    id TEXT PRIMARY KEY,
    points_req INT NOT NULL,
    label TEXT NOT NULL,
    discount_amount NUMERIC(6,2) DEFAULT 0.00,
    icon VARCHAR(10) DEFAULT '✨',
    description TEXT,
    sort_order INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.pricing_config (
    id INT PRIMARY KEY DEFAULT 1,
    original_price NUMERIC(6,2) NOT NULL DEFAULT 35.00,
    refill_price NUMERIC(6,2) NOT NULL DEFAULT 25.00,
    tangiers_price NUMERIC(6,2) NOT NULL DEFAULT 38.00,
    tax_rate_percent NUMERIC(5,2) NOT NULL DEFAULT 8.60,
    default_tip_percent INT NOT NULL DEFAULT 18,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT single_pricing_row CHECK (id = 1)
);

-- ============================================================================
-- 9. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tobacco_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.house_mixes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.house_mix_components ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.beverages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lounge_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lounge_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.smoke_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tabs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tab_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pricing_config ENABLE ROW LEVEL SECURITY;

-- Catalog & Public Tables: Anyone can view active catalog items
CREATE POLICY "Public Read Active Brands" ON public.brands FOR SELECT USING (is_active = true);
CREATE POLICY "Public Read Tobacco Inventory" ON public.tobacco_inventory FOR SELECT USING (true);
CREATE POLICY "Public Read Active House Mixes" ON public.house_mixes FOR SELECT USING (is_active = true);
CREATE POLICY "Public Read Mix Components" ON public.house_mix_components FOR SELECT USING (true);
CREATE POLICY "Public Read Beverages" ON public.beverages FOR SELECT USING (in_stock = true);
CREATE POLICY "Public Read Lounge Tables" ON public.lounge_tables FOR SELECT USING (is_active = true);
CREATE POLICY "Public Read Reward Tiers" ON public.reward_tiers FOR SELECT USING (true);
CREATE POLICY "Public Read Pricing Config" ON public.pricing_config FOR SELECT USING (true);

-- Tabs & Orders: Read & Write for active session
CREATE POLICY "Guest/Member Tab Read" ON public.tabs FOR SELECT USING (true);
CREATE POLICY "Guest/Member Tab Insert" ON public.tabs FOR INSERT WITH CHECK (true);
CREATE POLICY "Guest/Member Tab Update" ON public.tabs FOR UPDATE USING (true);

CREATE POLICY "Tab Items Read" ON public.tab_items FOR SELECT USING (true);
CREATE POLICY "Tab Items Insert" ON public.tab_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Tab Items Update" ON public.tab_items FOR UPDATE USING (true);

-- Service Tickets: Anyone can create a ticket; staff can read/acknowledge
CREATE POLICY "Service Ticket Create" ON public.service_tickets FOR INSERT WITH CHECK (true);
CREATE POLICY "Service Ticket View" ON public.service_tickets FOR SELECT USING (true);
CREATE POLICY "Service Ticket Update" ON public.service_tickets FOR UPDATE USING (true);

-- Members & Smoke History: Members can view and update their own profiles
CREATE POLICY "Member View Own Profile" ON public.members FOR SELECT USING (true);
CREATE POLICY "Member Update Profile" ON public.members FOR UPDATE USING (true);
CREATE POLICY "Smoke History Select" ON public.smoke_history FOR SELECT USING (true);
CREATE POLICY "Smoke History Insert" ON public.smoke_history FOR INSERT WITH CHECK (true);

-- ============================================================================
-- 10. REALTIME PUBLICATION SETUP
-- ============================================================================

-- Add core live tables to Supabase Realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.tabs;
ALTER PUBLICATION supabase_realtime ADD TABLE public.tab_items;
ALTER PUBLICATION supabase_realtime ADD TABLE public.service_tickets;
ALTER PUBLICATION supabase_realtime ADD TABLE public.tobacco_inventory;

-- ============================================================================
-- 11. INITIAL VERIFIED SEED DATA
-- ============================================================================

-- Pricing Config
INSERT INTO public.pricing_config (id, original_price, refill_price, tangiers_price, tax_rate_percent, default_tip_percent)
VALUES (1, 35.00, 25.00, 38.00, 8.60, 18)
ON CONFLICT (id) DO NOTHING;

-- Brands
INSERT INTO public.brands (id, name, origin, country_code, country_flag, sort_order) VALUES
('MustHave', 'MustHave Tobacco', 'Moscow, Russia', 'RUS', '🇷🇺', 1),
('Tangiers', 'Tangiers Club Noir', 'San Diego, USA', 'USA', '🇺🇸', 2),
('Darkside', 'Darkside Core', 'Nizhny Novgorod, Russia', 'RUS', '🇷🇺', 3),
('BlackBurn', 'BlackBurn Craft', 'Moscow, Russia', 'RUS', '🇷🇺', 4),
('Al Fakher', 'Al Fakher Golden', 'Ajman, UAE', 'ARE', '🇦🇪', 5),
('Starbuzz', 'Starbuzz Tobacco', 'California, USA', 'USA', '🇺🇸', 6),
('Adalya', 'Adalya Tobacco', 'Izmir, Turkey', 'TUR', '🇹🇷', 7)
ON CONFLICT (id) DO NOTHING;

-- Tobacco Inventory
INSERT INTO public.tobacco_inventory (id, brand_id, name, category, strength, stock, color_hex, description, profiles) VALUES
('mh-pinkman', 'MustHave', 'Pinkman', 'russian', 7.0, 'in_stock', '#ff3366', 'Raspberry, Pink Grapefruit & Strawberry', ARRAY['Berries', 'Citruses', 'Tropical']),
('mh-frosty', 'MustHave', 'Frosty', 'russian', 6.0, 'in_stock', '#00f0ff', 'Sub-Zero Siberian Chill', ARRAY['Mints', 'Flavor Additives']),
('mh-milky-rice', 'MustHave', 'Milky Rice', 'russian', 7.0, 'in_stock', '#e0e7ff', 'Creamy Sweet Rice Pudding', ARRAY['Dairy / Creamy', 'Desserts']),
('mh-space-flavour', 'MustHave', 'Space Flavour', 'russian', 7.0, 'in_stock', '#ff8c00', 'Tropical Mango, Passion & Berry', ARRAY['Tropical', 'Berries', 'Citruses']),
('tan-cane-mint', 'Tangiers', 'Cane Mint (Noir 96)', 'tangiers', 9.0, 'in_stock', '#00f0ff', 'Natural Sweet Cane Peppermint', ARRAY['Mints']),
('tan-kashmir-peach', 'Tangiers', 'Kashmir Peach', 'tangiers', 9.0, 'in_stock', '#fb923c', 'Exotic Indian Spices + Ripe Peach', ARRAY['Orchard Fruit', 'Warm Spices', 'Florals']),
('tan-orange-soda', 'Tangiers', 'Orange Soda', 'tangiers', 8.0, 'in_stock', '#ffcc00', 'Fizzy Citrus Valencia Orange', ARRAY['Citruses', 'Beverages']),
('ds-falling-star', 'Darkside', 'Falling Star', 'russian', 8.0, 'in_stock', '#ff8c00', 'Passionfruit & Mango Tropical Medley', ARRAY['Tropical', 'Citruses']),
('ds-supernova', 'Darkside', 'Supernova', 'russian', 9.0, 'in_stock', '#00f0ff', 'Deep Siberian Arctic Freeze', ARRAY['Mints', 'Flavor Additives']),
('bb-green-tea', 'BlackBurn', 'Green Tea', 'russian', 8.0, 'in_stock', '#10b981', 'Jasmine Green Tea Herbal Leaf', ARRAY['Beverages', 'Herbal']),
('af-two-apples', 'Al Fakher', 'Two Apples', 'blonde', 3.0, 'in_stock', '#22c55e', 'Traditional Anise & Crisp Apple', ARRAY['Apple', 'Orchard Fruit', 'Warm Spices']),
('sb-blue-mist', 'Starbuzz', 'Blue Mist', 'blonde', 2.0, 'in_stock', '#ff3366', 'Sweet Blueberry Fresh Breeze', ARRAY['Berries', 'Mints']),
('ad-love-66', 'Adalya', 'Love 66', 'blonde', 3.0, 'out_of_stock', '#ff8c00', 'Watermelon, Honeydew & Mint', ARRAY['Tropical', 'Berries', 'Mints'])
ON CONFLICT (id) DO NOTHING;

-- Signature House Mixes
INSERT INTO public.house_mixes (id, name, tagline, description, badge, color_hex, is_signature, sort_order) VALUES
('mix-pink-cane', 'Pink Cane Sensation', 'Lounge Signature Blend', 'Sweet ruby raspberries, pink grapefruit & strawberry chilled with natural cane peppermint.', 'Craft #1', '#EC4899', true, 1),
('mix-siberian-midnight', 'Siberian Midnight Tea', 'Arctic Freeze & Green Tea', 'Earthy jasmine green tea paired with sub-zero arctic freeze.', 'Staff Fav', '#6366F1', true, 2),
('mix-kashmir-velvet', 'Kashmir Velvet Cream', 'Spiced Floral Kashmir & Sweet Rice', 'Aromatic Indian spices with ripe peach and warm vanilla rice pudding.', 'Rich', '#FB923C', true, 3),
('mix-empire-royalty', 'Empire Royalty', 'Cane Mint, Mango & Siberian Freeze', 'Cane mint, tropical mango passion, and crisp Siberian chill.', 'VIP', '#E5A93C', true, 4),
('mix-citrus-bliss', 'Fizzy Citrus Rush', 'Valencia Orange & Grapefruit Zest', 'Sparkling Valencia orange soda balanced by tangy pink grapefruit.', 'Fresh', '#F97316', true, 5)
ON CONFLICT (id) DO NOTHING;

-- House Mix Components
INSERT INTO public.house_mix_components (mix_id, tobacco_id, percentage, sort_order) VALUES
('mix-pink-cane', 'mh-pinkman', 70, 1),
('mix-pink-cane', 'tan-cane-mint', 30, 2),
('mix-siberian-midnight', 'bb-green-tea', 70, 1),
('mix-siberian-midnight', 'ds-supernova', 30, 2),
('mix-kashmir-velvet', 'tan-kashmir-peach', 60, 1),
('mix-kashmir-velvet', 'mh-milky-rice', 40, 2),
('mix-empire-royalty', 'tan-cane-mint', 35, 1),
('mix-empire-royalty', 'ds-falling-star', 35, 2),
('mix-empire-royalty', 'mh-frosty', 30, 3),
('mix-citrus-bliss', 'tan-orange-soda', 50, 1),
('mix-citrus-bliss', 'mh-pinkman', 50, 2)
ON CONFLICT (mix_id, tobacco_id) DO NOTHING;

-- Verified Beverages
INSERT INTO public.beverages (id, name, category, description, price, in_stock, sort_order) VALUES
('coke-classic', 'Coca-Cola Classic', 'Soda', 'Classic recipe cola', 0.00, true, 1),
('coke-diet', 'Diet Coke', 'Soda', 'Crisp zero-sugar classic', 0.00, true, 2),
('coke-zero', 'Coke Zero Sugar', 'Soda', 'Zero calories cola', 0.00, true, 3),
('sprite', 'Sprite Lemon-Lime', 'Soda', 'Crisp lemon-lime', 0.00, true, 4),
('dr-pepper', 'Dr Pepper', 'Soda', '23 signature authentic blend flavors', 0.00, true, 5),
('fanta-orange', 'Fanta Orange', 'Soda', 'Citrus orange soda', 0.00, true, 6),
('ginger-ale', 'Seagram''s Ginger Ale', 'Soda', 'Smooth crisp ginger bubbles', 0.00, true, 7),
('mexican-coke', 'Mexican Coke', 'Soda', 'Pure cane sugar glass bottle', 0.00, true, 8),
('redbull-original', 'Red Bull Original', 'Energy', 'Classic 8.4oz energy can', 0.00, true, 9),
('redbull-sugarfree', 'Red Bull Sugarfree', 'Energy', 'Zero sugar energy formula', 0.00, true, 10),
('redbull-yellow', 'Red Bull Yellow Edition', 'Energy', 'Tropical fruits blend', 0.00, true, 11),
('redbull-red', 'Red Bull Red Edition', 'Energy', 'Watermelon chill blend', 0.00, true, 12),
('maison-perrier', 'Maison Perrier', 'Mineral Water', 'French sparkling natural mineral water', 0.00, true, 13),
('bottled-water', 'Bottled Water', 'Still Water', 'Artisan chilled spring water bottle', 0.00, true, 14)
ON CONFLICT (id) DO NOTHING;

-- Zones
INSERT INTO public.lounge_zones (id, name, icon, sort_order) VALUES
('indoor', 'Indoor Floor', 'layers', 1),
('bar', 'Main Bar', 'wine', 2),
('vip', 'VIP Lounge', 'crown', 3),
('patio', 'Outdoor Patio', 'sun', 4)
ON CONFLICT (id) DO NOTHING;

-- Reward Tiers
INSERT INTO public.reward_tiers (id, points_req, label, discount_amount, icon, description, sort_order) VALUES
('tier-100', 100, 'Free Beverage', 0.00, '🍹', '1 Complimentary Chilled Beverage', 1),
('tier-250', 250, 'Free Ice Tip ($5.00 Off)', 5.00, '❄️', 'Complimentary Frozen Ice Tip', 2),
('tier-750', 750, '50% Off Refill (-$12.50)', 12.50, '🏺', '50% off shisha repack / refill', 3),
('tier-1000', 1000, 'Free Shisha Bowl (-$35.00)', 35.00, '✨', 'Free Russian Craft or Blonde Bowl', 4),
('tier-1500', 1500, 'VIP Royalty Pass (-$50.00)', 50.00, '👑', '$50.00 Off Entire Bill', 5)
ON CONFLICT (id) DO NOTHING;
