Minimal, script-friendly coding scheme for beverages & food in Pena ERP stack.

The goal:
- Human readable, machine parsable
- Stable over time (child can read this years later and reconstruct the logic)
- Zen / minimal: only meaningful dimensions, no noise

---

## 1. Profiles

We deliberately use **two different profiles**:

### 1.1 Espresso-based & other standard drinks

**Grammar (6 segments):**

    DEPT_GROUP_BASE_SHOT_SYRUP_MILK

- All espresso-based drinks, filter coffee, hot chocolate, sahlep, tea, soft drinks, etc.
- No sweetness code here. Sugar is not managed in the codec for these items.

Examples:

- Espresso (no milk, no syrup):

      BV_HC_ESP_1X_PLN_NM

- Hot Latte, pasteurized milk, no syrup:

      BV_HC_LAT_1X_PLN_PA

- Iced Caramel Latte, double shot, oat milk:

      BV_CC_LAT_2X_CAR_OA

- Filter coffee (drip), no milk:

      BV_HC_FLT_1X_PLN_NM

- Hot Chocolate, pasteurized milk:

      BV_HC_HCH_1X_PLN_PA

- Turkish Tea, no milk:

      BV_HC_CAY_1X_PLN_NM

### 1.2 Turkish Coffee profile

Turkish Coffee has its own, simpler grammar.  
Sugar level is explicit here; this is the **only** drink with sweetness in the codec.

**Grammar (4 segments):**

    DEPT_GROUP_TRK_SHOT_SWEET

- `BASE` is always `TRK`
- `SWEET` encodes the sugar level

Examples:

- Sade:

      BV_HC_TRK_1X_S0

- Az şekerli:

      BV_HC_TRK_1X_S1

- Orta:

      BV_HC_TRK_1X_S2

- Şekerli:

      BV_HC_TRK_1X_S3

---

## 2. Dictionaries

### 2.1 Department (DEPT)

- `BV` — Beverage
- `FD` — Food

### 2.2 Groups (GROUP)

- `HC` — Hot Coffee / Hot Beverages
- `CC` — Cold Coffee
- `SD` — Soft Drinks
- `BKY` — Bakery / Food (pastries, cakes, etc.)

(These map to ERPNext Item Groups.)

### 2.3 Base codes (BASE)

Hot coffee (HC):

- `ESP` — Espresso
- `RIS` — Ristretto
- `LNG` — Lungo
- `AMR` — Americano
- `MAC` — Macchiato
- `COR` — Cortado
- `CAP` — Cappuccino
- `LAT` — Latte
- `FLW` — Flat White
- `MOC` — Mocha
- `FLT` — Filter coffee (drip)
- `HCH` — Hot Chocolate
- `SLP` — Sahlep
- `TRK` — Turkish Coffee (special profile, see section 1.2)
- `CAY` — Turkish Tea

Cold coffee (CC):

- `AMR` — Iced Americano
- `LAT` — Iced Latte
- `MOC` — Iced Mocha

Soft drinks (SD): (v0 — simple mapping, can be normalized later)

- `CHR`   — Churchill
- `CHMSK` — Chocolate milkshake
- `STMSK` — Strawberry milkshake
- `MHMSK` — Marshmallow milkshake
- `MLMD`  — Mint Lime Lemonade
- `STLMD` — Strawberry Lemonade
- `HBICT` — Hibiscus Peach Iced Tea
- `LMICT` — Lemon Iced Tea
- `SPW`   — San Pellegrino Sparkling Water
- `SPL`   — San Pellegrino Limonata
- `SPA`   — San Pellegrino Aranciata
- `SPAR`  — San Pellegrino Aranciata Rossa
- `WTR`   — Bottle of Water


(These codes are v0 suggestions and can evolve; decoder logic should be table-based, not hardcoded.)

### 2.4 Shot codes (SHOT)

- `1X` — One espresso shot (default)
- `2X` — Double shot
- `3X` — Triple shot

(Decaf or other variations can be added later, e.g. `1D`, `2D`.)

### 2.5 Syrup codes (SYRUP)

- `PLN` — Plain, no syrup
- `CAR` — Caramel
- `VNL` — Vanilla
- `HZL` — Hazelnut
- `CHC` — Chocolate
- `STR` — Strawberry
- `MNT` — Mint
- `PMK` — Pumpkin Spice
- `WCH` — White Chocolate
- (extend as needed; keep codes short and obvious)


### 2.6 Milk codes (MILK)

Only the milks actually used in Pena:

- `PA` — Pasteurized milk (default house milk)
- `LF` — Lactose-free milk
- `OA` — Oat milk
- `AL` — Almond milk
- `NM` — No Milk (used for espresso, Americano, tea, etc.)

### 2.7 Sweetness codes (SWEET) — Turkish Coffee ONLY

Used only in the Turkish Coffee profile (section 1.2):

- `S0` — Sade (no sugar)
- `S1` — Az şekerli (light sweet)
- `S2` — Orta (medium)
- `S3` — Şekerli (extra sweet)

---


## 3. Design rules

1. **Espresso-based drinks** and other standard drinks:
   - Always use the 6-segment grammar:

         DEPT_GROUP_BASE_SHOT_SYRUP_MILK

2. **Turkish Coffee**:
   - Always use the 4-segment grammar:

         DEPT_GROUP_TRK_SHOT_SWEET

3. Syrup:
   - `PLN` explicitly means “no syrup”.

4. Milk:
   - Always encode the actual milk type:
     - `PA`, `LF`, `OA`, `AL`, or `NM`.
   - There is no abstract “DFLT” milk; the recipe defines which milk is default.

5. Sugar / sweetness:
   - Only modeled explicitly for Turkish Coffee (TRK).
   - For other drinks, sugar is handled operationally (sugar on the bar, customer choice) and not encoded in the codec.

6. Future evolution:
   - New bases, syrups, milks or groups must be added to this README first.
   - Scripts that generate Items / Item Prices should read from tables (CSV/JSON) that align with these codes.
   - If grammar changes, bump the version at the top (v0.2.1 -> v0.3, etc.) and commit with a clear message.

