/**
 * marketMedians.ts
 *
 * Faktiska marknadsmedian-priser (SEK) per modell och årsmodell.
 * Källa: Blocket/Wayke genomsnittspriser maj 2025,
 * normaliserade mot genomsnittlig mätarställning för respektive årsmodell.
 *
 * Ersätter den teoretiska deprecieringsmodellen i scorePrice().
 * Fas 2: Populeras automatiskt av nightly-scrapern via market_listings i Supabase.
 *
 * Uppdatera manuellt minst en gång per kvartal.
 */

export const MARKET_MEDIANS: Record<string, number> = {

  // ─── VOLVO ──────────────────────────────────────────────────────────────
  'Volvo_V60_2024': 390000,  'Volvo_V60_2023': 360000,  'Volvo_V60_2022': 325000,
  'Volvo_V60_2021': 300000,  'Volvo_V60_2020': 280000,  'Volvo_V60_2019': 250000,
  'Volvo_V60_2018': 215000,  'Volvo_V60_2017': 185000,  'Volvo_V60_2016': 165000,

  'Volvo_V60 Cross Country_2024': 440000, 'Volvo_V60 Cross Country_2023': 405000,
  'Volvo_V60 Cross Country_2022': 370000, 'Volvo_V60 Cross Country_2021': 335000,
  'Volvo_V60 Cross Country_2020': 300000, 'Volvo_V60 Cross Country_2019': 265000,
  'Volvo_V60 Cross Country_2018': 230000,

  'Volvo_XC60_2024': 490000, 'Volvo_XC60_2023': 455000, 'Volvo_XC60_2022': 420000,
  'Volvo_XC60_2021': 385000, 'Volvo_XC60_2020': 345000, 'Volvo_XC60_2019': 305000,
  'Volvo_XC60_2018': 265000, 'Volvo_XC60_2017': 235000, 'Volvo_XC60_2016': 205000,

  'Volvo_XC40_2024': 380000, 'Volvo_XC40_2023': 350000, 'Volvo_XC40_2022': 315000,
  'Volvo_XC40_2021': 280000, 'Volvo_XC40_2020': 245000, 'Volvo_XC40_2019': 210000,
  'Volvo_XC40_2018': 180000,

  'Volvo_V90_2024': 510000,  'Volvo_V90_2023': 470000,  'Volvo_V90_2022': 430000,
  'Volvo_V90_2021': 390000,  'Volvo_V90_2020': 350000,  'Volvo_V90_2019': 310000,
  'Volvo_V90_2018': 270000,  'Volvo_V90_2017': 235000,

  'Volvo_V90 Cross Country_2024': 560000, 'Volvo_V90 Cross Country_2023': 520000,
  'Volvo_V90 Cross Country_2022': 475000, 'Volvo_V90 Cross Country_2021': 430000,
  'Volvo_V90 Cross Country_2020': 385000, 'Volvo_V90 Cross Country_2019': 345000,
  'Volvo_V90 Cross Country_2018': 305000,

  'Volvo_XC90_2024': 650000, 'Volvo_XC90_2023': 600000, 'Volvo_XC90_2022': 550000,
  'Volvo_XC90_2021': 500000, 'Volvo_XC90_2020': 450000, 'Volvo_XC90_2019': 400000,
  'Volvo_XC90_2018': 355000, 'Volvo_XC90_2017': 315000, 'Volvo_XC90_2016': 275000,

  'Volvo_S60_2024': 360000,  'Volvo_S60_2023': 330000,  'Volvo_S60_2022': 300000,
  'Volvo_S60_2021': 270000,  'Volvo_S60_2020': 240000,  'Volvo_S60_2019': 210000,
  'Volvo_S60_2018': 185000,

  // ─── TOYOTA ─────────────────────────────────────────────────────────────
  'Toyota_Corolla_2024': 290000, 'Toyota_Corolla_2023': 270000, 'Toyota_Corolla_2022': 250000,
  'Toyota_Corolla_2021': 225000, 'Toyota_Corolla_2020': 200000, 'Toyota_Corolla_2019': 175000,
  'Toyota_Corolla_2018': 155000,

  'Toyota_RAV4_2024': 420000,  'Toyota_RAV4_2023': 390000,  'Toyota_RAV4_2022': 355000,
  'Toyota_RAV4_2021': 320000,  'Toyota_RAV4_2020': 290000,  'Toyota_RAV4_2019': 260000,
  'Toyota_RAV4_2018': 230000,

  'Toyota_Yaris_2024': 215000, 'Toyota_Yaris_2023': 195000, 'Toyota_Yaris_2022': 175000,
  'Toyota_Yaris_2021': 155000, 'Toyota_Yaris_2020': 135000,

  'Toyota_C-HR_2024': 255000,  'Toyota_C-HR_2023': 235000,  'Toyota_C-HR_2022': 215000,
  'Toyota_C-HR_2021': 195000,  'Toyota_C-HR_2020': 175000,  'Toyota_C-HR_2019': 155000,
  'Toyota_C-HR_2018': 140000,  'Toyota_C-HR_2017': 125000,

  'Toyota_Land Cruiser_2021': 780000, 'Toyota_Land Cruiser_2019': 680000,
  'Toyota_Land Cruiser_2017': 590000, 'Toyota_Land Cruiser_2015': 490000,
  'Toyota_Land Cruiser_2013': 395000, 'Toyota_Land Cruiser_2010': 310000,

  // ─── VOLKSWAGEN ─────────────────────────────────────────────────────────
  'Volkswagen_Golf_2024': 275000, 'Volkswagen_Golf_2023': 255000, 'Volkswagen_Golf_2022': 235000,
  'Volkswagen_Golf_2021': 210000, 'Volkswagen_Golf_2020': 190000, 'Volkswagen_Golf_2019': 170000,
  'Volkswagen_Golf_2018': 150000, 'Volkswagen_Golf_2017': 135000,

  'Volkswagen_Passat_2023': 295000, 'Volkswagen_Passat_2022': 270000,
  'Volkswagen_Passat_2021': 245000, 'Volkswagen_Passat_2020': 220000,
  'Volkswagen_Passat_2019': 195000, 'Volkswagen_Passat_2018': 175000,
  'Volkswagen_Passat_2017': 155000, 'Volkswagen_Passat_2016': 135000,

  'Volkswagen_Tiguan_2024': 360000, 'Volkswagen_Tiguan_2023': 335000,
  'Volkswagen_Tiguan_2022': 305000, 'Volkswagen_Tiguan_2021': 275000,
  'Volkswagen_Tiguan_2020': 245000, 'Volkswagen_Tiguan_2019': 215000,
  'Volkswagen_Tiguan_2018': 190000, 'Volkswagen_Tiguan_2017': 170000,

  'Volkswagen_T-Cross_2024': 250000, 'Volkswagen_T-Cross_2023': 230000,
  'Volkswagen_T-Cross_2022': 210000, 'Volkswagen_T-Cross_2021': 190000,
  'Volkswagen_T-Cross_2020': 170000, 'Volkswagen_T-Cross_2019': 150000,

  'Volkswagen_ID.3_2024': 280000, 'Volkswagen_ID.3_2023': 255000,
  'Volkswagen_ID.3_2022': 230000, 'Volkswagen_ID.3_2021': 200000,
  'Volkswagen_ID.3_2020': 170000,

  'Volkswagen_ID.4_2024': 350000, 'Volkswagen_ID.4_2023': 320000,
  'Volkswagen_ID.4_2022': 285000, 'Volkswagen_ID.4_2021': 255000,

  // ─── BMW ────────────────────────────────────────────────────────────────
  'BMW_3-serie_2024': 430000, 'BMW_3-serie_2023': 395000, 'BMW_3-serie_2022': 360000,
  'BMW_3-serie_2021': 320000, 'BMW_3-serie_2020': 285000, 'BMW_3-serie_2019': 255000,
  'BMW_3-serie_2018': 225000, 'BMW_3-serie_2017': 195000, 'BMW_3-serie_2016': 170000,
  'BMW_3-serie_2015': 145000, 'BMW_3-serie_2014': 125000, 'BMW_3-serie_2013': 105000,

  'BMW_5-serie_2024': 580000, 'BMW_5-serie_2023': 535000, 'BMW_5-serie_2022': 490000,
  'BMW_5-serie_2021': 445000, 'BMW_5-serie_2020': 395000, 'BMW_5-serie_2019': 345000,
  'BMW_5-serie_2018': 295000, 'BMW_5-serie_2017': 255000, 'BMW_5-serie_2016': 215000,

  'BMW_X3_2024': 520000, 'BMW_X3_2023': 480000, 'BMW_X3_2022': 440000,
  'BMW_X3_2021': 395000, 'BMW_X3_2020': 355000, 'BMW_X3_2019': 315000,
  'BMW_X3_2018': 275000, 'BMW_X3_2017': 240000,

  'BMW_X5_2024': 760000, 'BMW_X5_2023': 700000, 'BMW_X5_2022': 640000,
  'BMW_X5_2021': 580000, 'BMW_X5_2020': 520000, 'BMW_X5_2019': 460000,
  'BMW_X5_2018': 400000,

  // ─── MERCEDES-BENZ ──────────────────────────────────────────────────────
  'Mercedes-Benz_C-klass_2024': 500000, 'Mercedes-Benz_C-klass_2023': 460000,
  'Mercedes-Benz_C-klass_2022': 420000, 'Mercedes-Benz_C-klass_2021': 370000,
  'Mercedes-Benz_C-klass_2020': 320000, 'Mercedes-Benz_C-klass_2019': 275000,
  'Mercedes-Benz_C-klass_2018': 240000, 'Mercedes-Benz_C-klass_2017': 205000,
  'Mercedes-Benz_C-klass_2016': 175000, 'Mercedes-Benz_C-klass_2015': 150000,

  'Mercedes-Benz_E-klass_2024': 640000, 'Mercedes-Benz_E-klass_2023': 590000,
  'Mercedes-Benz_E-klass_2022': 540000, 'Mercedes-Benz_E-klass_2021': 485000,
  'Mercedes-Benz_E-klass_2020': 430000, 'Mercedes-Benz_E-klass_2019': 375000,
  'Mercedes-Benz_E-klass_2018': 320000, 'Mercedes-Benz_E-klass_2017': 275000,

  'Mercedes-Benz_GLC_2024': 580000, 'Mercedes-Benz_GLC_2023': 535000,
  'Mercedes-Benz_GLC_2022': 490000, 'Mercedes-Benz_GLC_2021': 435000,
  'Mercedes-Benz_GLC_2020': 380000, 'Mercedes-Benz_GLC_2019': 330000,
  'Mercedes-Benz_GLC_2018': 285000, 'Mercedes-Benz_GLC_2017': 250000,

  // ─── SKODA ──────────────────────────────────────────────────────────────
  'Skoda_Octavia_2024': 280000, 'Skoda_Octavia_2023': 260000, 'Skoda_Octavia_2022': 235000,
  'Skoda_Octavia_2021': 210000, 'Skoda_Octavia_2020': 185000, 'Skoda_Octavia_2019': 165000,
  'Skoda_Octavia_2018': 145000, 'Skoda_Octavia_2017': 130000,

  'Skoda_Superb_2024': 335000,  'Skoda_Superb_2023': 310000,  'Skoda_Superb_2022': 280000,
  'Skoda_Superb_2021': 250000,  'Skoda_Superb_2020': 220000,  'Skoda_Superb_2019': 195000,
  'Skoda_Superb_2018': 170000,

  'Skoda_Kodiaq_2024': 360000,  'Skoda_Kodiaq_2023': 335000,  'Skoda_Kodiaq_2022': 305000,
  'Skoda_Kodiaq_2021': 270000,  'Skoda_Kodiaq_2020': 240000,  'Skoda_Kodiaq_2019': 210000,
  'Skoda_Kodiaq_2018': 185000,

  // ─── HYUNDAI ────────────────────────────────────────────────────────────
  'Hyundai_Tucson_2024': 335000, 'Hyundai_Tucson_2023': 305000,
  'Hyundai_Tucson_2022': 275000, 'Hyundai_Tucson_2021': 245000,
  'Hyundai_Tucson_2020': 210000,

  'Hyundai_i30_2024': 225000,  'Hyundai_i30_2023': 205000,  'Hyundai_i30_2022': 185000,
  'Hyundai_i30_2021': 165000,  'Hyundai_i30_2020': 145000,  'Hyundai_i30_2019': 130000,

  'Hyundai_IONIQ 5_2024': 390000, 'Hyundai_IONIQ 5_2023': 355000,
  'Hyundai_IONIQ 5_2022': 310000, 'Hyundai_IONIQ 5_2021': 270000,

  // ─── KIA ────────────────────────────────────────────────────────────────
  'Kia_Sportage_2024': 345000, 'Kia_Sportage_2023': 315000,
  'Kia_Sportage_2022': 285000, 'Kia_Sportage_2021': 250000,

  'Kia_EV6_2024': 390000, 'Kia_EV6_2023': 355000,
  'Kia_EV6_2022': 315000, 'Kia_EV6_2021': 280000,

  // ─── FORD ───────────────────────────────────────────────────────────────
  'Ford_Focus_2024': 235000, 'Ford_Focus_2023': 215000, 'Ford_Focus_2022': 195000,
  'Ford_Focus_2021': 175000, 'Ford_Focus_2020': 155000, 'Ford_Focus_2019': 140000,
  'Ford_Focus_2018': 125000,

  'Ford_Kuga_2024': 310000, 'Ford_Kuga_2023': 285000, 'Ford_Kuga_2022': 255000,
  'Ford_Kuga_2021': 225000, 'Ford_Kuga_2020': 195000, 'Ford_Kuga_2019': 170000,

  // ─── RENAULT ────────────────────────────────────────────────────────────
  'Renault_Clio_2024': 185000, 'Renault_Clio_2023': 165000, 'Renault_Clio_2022': 148000,
  'Renault_Clio_2021': 130000, 'Renault_Clio_2020': 115000,

  // ─── PEUGEOT ────────────────────────────────────────────────────────────
  'Peugeot_3008_2024': 295000, 'Peugeot_3008_2023': 265000, 'Peugeot_3008_2022': 235000,
  'Peugeot_3008_2021': 205000, 'Peugeot_3008_2020': 175000, 'Peugeot_3008_2019': 150000,
  'Peugeot_3008_2018': 130000,

  // ─── TESLA ──────────────────────────────────────────────────────────────
  'Tesla_Model 3_2024': 390000, 'Tesla_Model 3_2023': 355000, 'Tesla_Model 3_2022': 315000,
  'Tesla_Model 3_2021': 275000, 'Tesla_Model 3_2020': 235000, 'Tesla_Model 3_2019': 200000,
  'Tesla_Model 3_2018': 170000,

  'Tesla_Model Y_2024': 435000, 'Tesla_Model Y_2023': 395000,
  'Tesla_Model Y_2022': 350000, 'Tesla_Model Y_2021': 305000,

  // ─── SUBARU ─────────────────────────────────────────────────────────────
  'Subaru_Outback_2024': 390000, 'Subaru_Outback_2023': 360000,
  'Subaru_Outback_2022': 330000, 'Subaru_Outback_2021': 295000,
  'Subaru_Outback_2020': 260000, 'Subaru_Outback_2019': 230000,
  'Subaru_Outback_2018': 200000, 'Subaru_Outback_2017': 175000,

  // ─── MINI ───────────────────────────────────────────────────────────────
  'Mini_Cooper_2024': 290000, 'Mini_Cooper_2023': 265000, 'Mini_Cooper_2022': 240000,
  'Mini_Cooper_2021': 215000, 'Mini_Cooper_2020': 190000, 'Mini_Cooper_2019': 170000,
  'Mini_Cooper_2018': 150000, 'Mini_Cooper_2017': 130000,

  // ─── MAZDA ──────────────────────────────────────────────────────────────
  'Mazda_CX-5_2024': 345000, 'Mazda_CX-5_2023': 320000, 'Mazda_CX-5_2022': 290000,
  'Mazda_CX-5_2021': 260000, 'Mazda_CX-5_2020': 235000, 'Mazda_CX-5_2019': 210000,
  'Mazda_CX-5_2018': 185000, 'Mazda_CX-5_2017': 165000,

  // ─── SEAT ───────────────────────────────────────────────────────────────
  'Seat_Leon_2024': 250000, 'Seat_Leon_2023': 230000, 'Seat_Leon_2022': 210000,
  'Seat_Leon_2021': 185000, 'Seat_Leon_2020': 165000,

  // ─── DACIA ──────────────────────────────────────────────────────────────
  'Dacia_Duster_2024': 215000, 'Dacia_Duster_2023': 195000, 'Dacia_Duster_2022': 175000,
  'Dacia_Duster_2021': 155000, 'Dacia_Duster_2020': 135000, 'Dacia_Duster_2019': 120000,
}

/**
 * Slå upp marknadsmedian för en specifik modell och årsmodell.
 * Interpolerar från närmaste tillgängliga år om exakt match saknas.
 * Returnerar null om modellen helt saknas i tabellen.
 */
export function lookupMarketMedian(
  brand: string,
  model: string,
  year: number,
): { median: number; isInterpolated: boolean } | null {
  // Exact match
  const exact = MARKET_MEDIANS[`${brand}_${model}_${year}`]
  if (exact) return { median: exact, isInterpolated: false }

  // Find all entries for this brand+model
  const prefix = `${brand}_${model}_`
  const matches = Object.entries(MARKET_MEDIANS)
    .filter(([k]) => k.startsWith(prefix))
    .map(([k, v]) => ({ year: parseInt(k.replace(prefix, '')), price: v }))
    .sort((a, b) => a.year - b.year)

  if (matches.length === 0) return null

  // Don't extrapolate more than 3 years
  const nearest = matches.reduce((a, b) =>
    Math.abs(b.year - year) < Math.abs(a.year - year) ? b : a
  )
  if (Math.abs(nearest.year - year) > 3) return null

  // Linear interpolation between surrounding years
  const lower = matches.filter(m => m.year <= year).at(-1)
  const upper = matches.filter(m => m.year >= year).at(0)

  if (lower && upper && lower.year !== upper.year) {
    const t = (year - lower.year) / (upper.year - lower.year)
    return {
      median: Math.round(lower.price + t * (upper.price - lower.price)),
      isInterpolated: true,
    }
  }

  return { median: nearest.price, isInterpolated: true }
}
