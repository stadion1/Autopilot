/**
 * referenceData.ts
 *
 * Komplett referensdatabas för den svenska begagnatmarknaden.
 * Täcker ~80% av alla annonser på Blocket, Wayke och Bytbil.
 *
 * Datakällor:
 * - Mobility Sweden begagnatstatistik 2024
 * - Wayke API annons­priser 2024
 * - KVD Bil auktionsdata
 * - Blocket snabbförsäljningsstatistik april 2025
 * - OEM listapriser Sverige
 *
 * Fält per modell:
 *   basePrice          — Genomsnittligt nypris (SEK) för generationen
 *   depreciation       — Årlig värdesminskning som andel (typvärde för Sverige)
 *   avgMilPerYear      — Genomsnittlig körsträcka per år (mil, 1 mil = 10 km)
 *   pricePer1000ExtraMil — Prisjustering per 1 000 mil över förväntat (negativ = billigare)
 *   reliabilityBase    — Startvärde 0–100 för tillförlitlighets­score
 *   resaleBase         — Startvärde 0–100 för andrahandsvärde
 *   notes              — Redaktionell notering om modellen
 */

export interface ModelReference {
  brand: string
  model: string
  yearFrom: number
  yearTo: number
  basePrice: number
  depreciation: number
  avgMilPerYear: number
  pricePer1000ExtraMil: number
  reliabilityBase: number
  resaleBase: number
  notes?: string
  // Regex-källsträng (case-insensitive) för att matcha mot Skatteverkets
  // new_car_prices.model_raw, för modeller där `model` är en serie-
  // beteckning som ALDRIG förekommer bokstavligt i Skatteverkets data —
  // de listar bara trimkoder (BMW "320d xDrive", Mercedes "C 200
  // 4MATIC..."), aldrig "3-serie"/"C-klass". Utan detta fält matchas
  // model_raw med en enkel substräng (ILIKE %model%), vilket räcker för de
  // flesta modeller (RAV4, Corolla, Cooper, CX-5 m.fl. förekommer
  // bokstavligt). Används av pages/api/admin/recompute-depreciation-curves.ts.
  skatteverketModelPattern?: string
}

export const MODEL_REFERENCES: ModelReference[] = [

  // ─── VOLVO ────────────────────────────────────────────────────────────────
  // Volvo är det dominerande märket på svenska begagnatmarknaden.
  // Hög efterfrågan håller upp andrahandsvärdet jämfört med europeiska konkurrenter.

  {
    brand: 'Volvo', model: 'XC60',
    yearFrom: 2017, yearTo: 2027,
    basePrice: 620000, depreciation: 0.120,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -3000,
    reliabilityBase: 74, resaleBase: 76,
    notes: 'Sveriges mest sålda bil 2024. Stark efterfrågan håller värdet väl. T8 PHEV-varianter tappar snabbare på grund av äldre batteriteknik.',
  },
  {
    brand: 'Volvo', model: 'V60',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 480000, depreciation: 0.125,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -2800,
    reliabilityBase: 75, resaleBase: 74,
    notes: 'Kombibilens flaggskepp i Sverige. Cross Country-variant håller värdet bättre än standard. T5/T6 bensin mest efterfrågat begagnat.',
  },
  {
    brand: 'Volvo', model: 'V60 Cross Country',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 530000, depreciation: 0.115,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2600,
    reliabilityBase: 75, resaleBase: 78,
    notes: 'Snabbast säljande modell på Blocket 2025 — 43% av annonserna borta inom en vecka. Premium på andrahandspriset jämfört med standard V60.',
  },
  {
    brand: 'Volvo', model: 'XC40',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 430000, depreciation: 0.130,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2500,
    reliabilityBase: 72, resaleBase: 72,
    notes: 'Populär hos yngre köpare. El-variant (EX40) deprecierar snabbare än bensinversion p.g.a. snabb teknikutveckling.',
  },
  {
    brand: 'Volvo', model: 'V90',
    yearFrom: 2016, yearTo: 2027,
    basePrice: 620000, depreciation: 0.130,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -3200,
    reliabilityBase: 74, resaleBase: 72,
    notes: 'Flaggskepps­kombinen. T8 PHEV vanlig på begagnatmarknaden från tjänstebilsflottor. Kontrollera alltid batteristatus på laddhybrid­versioner.',
  },
  {
    brand: 'Volvo', model: 'V90 Cross Country',
    yearFrom: 2017, yearTo: 2027,
    basePrice: 680000, depreciation: 0.120,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -3000,
    reliabilityBase: 74, resaleBase: 75,
    notes: '42% av Blocket-annonserna säljs inom en vecka. Stark nisch: kombi + terrängklarhet. Håller värdet bättre än standard V90.',
  },
  {
    brand: 'Volvo', model: 'XC90',
    yearFrom: 2015, yearTo: 2027,
    basePrice: 820000, depreciation: 0.130,
    avgMilPerYear: 1300, pricePer1000ExtraMil: -3500,
    reliabilityBase: 71, resaleBase: 73,
    notes: 'Premium 7-sitsig SUV. T8 PHEV kräver kontroll av batterihälsa. Hög servicekostnad — räkna med 15 000–25 000 kr/år på auktoriserad verkstad.',
  },
  {
    brand: 'Volvo', model: 'S60',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 450000, depreciation: 0.130,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -2600,
    reliabilityBase: 75, resaleBase: 70,
    notes: 'Sedan är mindre populär än kombi i Sverige. Lägre efterfrågan ger lite sämre andrahandsvärde än V60 av samma generation.',
  },

  // ─── TOYOTA ───────────────────────────────────────────────────────────────
  // Toyota toppar tillförlitlighets­rankingar. Hybrid­tekniken är mogen och beprövad.
  // Starkt andrahandsvärde tack vare renommé och låga driftkostnader.

  {
    brand: 'Toyota', model: 'RAV4',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 440000, depreciation: 0.110,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2400,
    reliabilityBase: 87, resaleBase: 76,
    notes: 'Hybrid­versionen (2019+) är klart att föredra begagnat — lägre driftkostnad och bättre andrahandsvärde. PHEV (Plug-in) kräver batterikontroll.',
  },
  {
    brand: 'Toyota', model: 'Corolla',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 310000, depreciation: 0.105,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -1800,
    reliabilityBase: 89, resaleBase: 72,
    notes: 'En av Toyotas mest tillförlitliga modeller historiskt. Hybrid standard från 2019. Låga service­kostnader — idealisk för kostnadsmedvetna köpare.',
  },
  {
    brand: 'Toyota', model: 'Yaris',
    yearFrom: 2020, yearTo: 2027,
    basePrice: 240000, depreciation: 0.105,
    avgMilPerYear: 1200, pricePer1000ExtraMil: -1400,
    reliabilityBase: 90, resaleBase: 70,
    notes: 'Fjärde generationen (2020+) är ett tydligt kliv framåt. Hybrid standard. Enastående driftsäkerhet. Liten bil — priset tappar mer i absoluta tal men andelen är stabil.',
  },
  {
    brand: 'Toyota', model: 'C-HR',
    yearFrom: 2016, yearTo: 2027,
    basePrice: 330000, depreciation: 0.115,
    avgMilPerYear: 1300, pricePer1000ExtraMil: -1900,
    reliabilityBase: 85, resaleBase: 68,
    notes: 'Polariserande design påverkar andrahandsvärdet negativt i vissa regioner. Hybrid­versionen tekniskt pålitlig. Begränsat lastutrymme.',
  },
  {
    brand: 'Toyota', model: 'Land Cruiser',
    yearFrom: 2008, yearTo: 2021,
    basePrice: 750000, depreciation: 0.090,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2000,
    reliabilityBase: 88, resaleBase: 82,
    notes: 'Extremt högt andrahandsvärde — äldre modeller håller priset remarkabelt väl. Diesel­versioner (D-4D) kända för lång livslängd. Hög efterfrågan på marknader utanför Sverige håller priset uppe.',
  },

  // ─── VOLKSWAGEN ───────────────────────────────────────────────────────────

  {
    brand: 'Volkswagen', model: 'Golf',
    yearFrom: 2019, yearTo: 2027,
    basePrice: 330000, depreciation: 0.115,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -2000,
    reliabilityBase: 72, resaleBase: 67,
    notes: 'Golf 8 (2019+) haft DSG/infotainment-problem. Golf 7 (2012–2019) mer beprövad. Kontrollera DSG-uppdateringar. Stark efterfrågan håller priset.',
  },
  {
    brand: 'Volkswagen', model: 'Passat',
    yearFrom: 2014, yearTo: 2023,
    basePrice: 380000, depreciation: 0.120,
    avgMilPerYear: 1600, pricePer1000ExtraMil: -2200,
    reliabilityBase: 71, resaleBase: 64,
    notes: 'Populär tjänstebil — många ex-leasingbilar på marknaden med hög mätarställning. GTE (PHEV) kräver batterikontroll. Ny generation 2024 höjer prisnivån på äldre.',
  },
  {
    brand: 'Volkswagen', model: 'Tiguan',
    yearFrom: 2016, yearTo: 2027,
    basePrice: 420000, depreciation: 0.120,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2500,
    reliabilityBase: 70, resaleBase: 68,
    notes: 'Välsäljande familje-SUV. DSG-problem kända på tidiga 2016–2018-exemplar. Allspace (7-sits) håller värdet något bättre.',
  },
  {
    brand: 'Volkswagen', model: 'T-Cross',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 260000, depreciation: 0.118,
    avgMilPerYear: 1300, pricePer1000ExtraMil: -1600,
    reliabilityBase: 73, resaleBase: 68,
    notes: 'Snabbast säljande modell på Blocket april 2025 — 44% av annonserna borta inom en vecka. Liten SUV med hög efterfrågan.',
  },
  {
    brand: 'Volkswagen', model: 'ID.3',
    yearFrom: 2020, yearTo: 2027,
    basePrice: 380000, depreciation: 0.160,
    avgMilPerYear: 1200, pricePer1000ExtraMil: -1500,
    reliabilityBase: 65, resaleBase: 58,
    notes: 'Tidig mjukvara (2020–2021) hade allvarliga buggar — kontrollera att uppdateringar är utförda. Deprecierar snabbt. Kontrollera batterihälsa (SoH) alltid.',
  },
  {
    brand: 'Volkswagen', model: 'ID.4',
    yearFrom: 2021, yearTo: 2027,
    basePrice: 480000, depreciation: 0.155,
    avgMilPerYear: 1300, pricePer1000ExtraMil: -2000,
    reliabilityBase: 67, resaleBase: 60,
    notes: 'Mer mogen elbil än ID.3. Kontrollera alltid batterihälsa och att senaste mjukvara­uppdateringar är installerade. Snabb depreciation gynnar köparen.',
  },

  // ─── BMW ─────────────────────────────────────────────────────────────────
  // Hög servicekostnad är den viktigaste faktorn att kommunicera till köparen.
  // Andrahandsvärdet är relativt starkt tack vare märkes­attraktivitet.

  {
    brand: 'BMW', model: '3-serie',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 520000, depreciation: 0.140,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -3000,
    reliabilityBase: 62, resaleBase: 70,
    notes: 'G20-generationen (2018+) mer pålitlig än F30. N20 4-cylindrig motor (äldre) — kontrollera timing chain. Räkna med 20 000–30 000 kr/år i service.',
    skatteverketModelPattern: '^M?3\\d{2}',
  },
  {
    brand: 'BMW', model: '5-serie',
    yearFrom: 2016, yearTo: 2027,
    basePrice: 680000, depreciation: 0.145,
    avgMilPerYear: 1600, pricePer1000ExtraMil: -3500,
    reliabilityBase: 60, resaleBase: 68,
    notes: 'G30-generationen (2016+) har fler elektronisk­problem än föregångaren. Hög servicekostnad. 530e PHEV kräver batterikontroll.',
    skatteverketModelPattern: '^M?5\\d{2}',
  },
  {
    brand: 'BMW', model: 'X3',
    yearFrom: 2017, yearTo: 2027,
    basePrice: 620000, depreciation: 0.135,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -3200,
    reliabilityBase: 63, resaleBase: 70,
    notes: 'G01 (2017+) stor förbättring mot föregångaren. Stark efterfrågan. Kontrollera oljekonsumtion på B58 6-cylindrig motor.',
  },
  {
    brand: 'BMW', model: 'X5',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 900000, depreciation: 0.140,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -4000,
    reliabilityBase: 60, resaleBase: 69,
    notes: 'G05 (2018+). Komplex bil med höga underhålls­kostnader. xDrive45e PHEV kräver batterikontroll. Räkna med 30 000+ kr/år i service.',
  },

  // ─── AUDI ────────────────────────────────────────────────────────────────
  // Basprisen för A4/A6/Q5 är uppskattade genom jämförelse mot redan verifierade
  // BMW/Mercedes-motsvarigheter i samma segment (3-serie/C-klass, 5-serie/E-klass,
  // X3/GLC) — inga officiella nypriser hittades för just dessa vid research.
  // A3, Q3 och övriga fält är hämtade från Audi Sveriges prislista/återförsäljardata.

  {
    brand: 'Audi', model: 'A3',
    yearFrom: 2020, yearTo: 2027,
    basePrice: 370000, depreciation: 0.135,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -2000,
    reliabilityBase: 66, resaleBase: 68,
    notes: 'Golf-konkurrent med Audi-premium. EA888-motorer delar konstruktion med VW/Skoda — samma kedjespännar­problem kan förekomma på tidiga exemplar.',
  },
  {
    brand: 'Audi', model: 'Q3',
    yearFrom: 2019, yearTo: 2027,
    basePrice: 400000, depreciation: 0.135,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2400,
    reliabilityBase: 65, resaleBase: 68,
    notes: 'Populär kompakt-SUV. Delar plattform med VW Tiguan/Skoda Karoq. Stark efterfrågan i Sverige håller andrahandsvärdet uppe.',
  },
  {
    brand: 'Audi', model: 'A4',
    yearFrom: 2019, yearTo: 2027,
    basePrice: 470000, depreciation: 0.140,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -3000,
    reliabilityBase: 65, resaleBase: 69,
    notes: 'Direkt konkurrent till BMW 3-serie och Mercedes C-klass. Tidiga 2.0 TFSI (EA888 Gen1) kan ha kedjespännar­problem — kontrollera servicehistorik.',
  },
  {
    brand: 'Audi', model: 'A6',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 680000, depreciation: 0.145,
    avgMilPerYear: 1600, pricePer1000ExtraMil: -3500,
    reliabilityBase: 64, resaleBase: 68,
    notes: 'Storsäljande tjänstebil. Komplex elektronik och luftfjädring på högre utrustningsnivåer ger högre servicekostnad. Stark efterfrågan andrahand.',
  },
  {
    brand: 'Audi', model: 'Q5',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 630000, depreciation: 0.135,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -3200,
    reliabilityBase: 66, resaleBase: 70,
    notes: 'Konkurrerar med BMW X3 och Mercedes GLC. Bra andrahandsvärde tack vare stark efterfrågan på premium-SUV i Sverige.',
  },

  // ─── MERCEDES-BENZ ────────────────────────────────────────────────────────

  {
    brand: 'Mercedes-Benz', model: 'C-klass',
    yearFrom: 2014, yearTo: 2027,
    basePrice: 560000, depreciation: 0.140,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -3000,
    reliabilityBase: 63, resaleBase: 68,
    notes: 'W205 (2014–2021): kända problem med rost på bakre fjädring och infotainment-fel. W206 (2021+) mer pålitlig. Höga servicekostnader.',
    skatteverketModelPattern: '^C\\s',
  },
  {
    brand: 'Mercedes-Benz', model: 'E-klass',
    yearFrom: 2016, yearTo: 2027,
    basePrice: 720000, depreciation: 0.140,
    avgMilPerYear: 1600, pricePer1000ExtraMil: -3500,
    reliabilityBase: 62, resaleBase: 67,
    notes: 'W213 (2016+). Komplex elektronik — undvika tidiga exemplar. 300de PHEV kräver batterikontroll. Hög servicekostnad men starkt andrahandsvärde.',
    skatteverketModelPattern: '^E\\s',
  },
  {
    brand: 'Mercedes-Benz', model: 'GLC',
    yearFrom: 2015, yearTo: 2027,
    basePrice: 640000, depreciation: 0.135,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -3200,
    reliabilityBase: 63, resaleBase: 69,
    notes: 'X253 (2015–2022) och C254 (2022+). Populär tjänstebils-SUV. 300e/300de PHEV kräver batterikontroll. Stark efterfrågan håller priset.',
  },

  // ─── SKODA ───────────────────────────────────────────────────────────────
  // VW-grupp teknologi till lägre pris. Utmärkt värde­alternativ.

  {
    brand: 'Skoda', model: 'Octavia',
    yearFrom: 2012, yearTo: 2027,
    basePrice: 310000, depreciation: 0.115,
    avgMilPerYear: 1600, pricePer1000ExtraMil: -1900,
    reliabilityBase: 76, resaleBase: 67,
    notes: 'En av marknadens bästa värde­bilar. Combi-variant starkt att föredra. DSG-problem förekommer — uppdatera programvara. Låga servicekostnader relativt sett.',
  },
  {
    brand: 'Skoda', model: 'Superb',
    yearFrom: 2015, yearTo: 2027,
    basePrice: 380000, depreciation: 0.120,
    avgMilPerYear: 1600, pricePer1000ExtraMil: -2200,
    reliabilityBase: 75, resaleBase: 65,
    notes: 'Enormt bagageutrymme. Utmärkt värde mot pris. iV (PHEV) kräver batterikontroll. Låg profil ger bra priser på begagnat.',
  },
  {
    brand: 'Skoda', model: 'Kodiaq',
    yearFrom: 2016, yearTo: 2027,
    basePrice: 400000, depreciation: 0.120,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2400,
    reliabilityBase: 74, resaleBase: 66,
    notes: '7-sits familje-SUV till bra pris. RS-version håller värdet bättre. DSG-problem på tidiga exemplar.',
  },

  // ─── HYUNDAI ─────────────────────────────────────────────────────────────

  {
    brand: 'Hyundai', model: 'Tucson',
    yearFrom: 2020, yearTo: 2027,
    basePrice: 400000, depreciation: 0.120,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2300,
    reliabilityBase: 77, resaleBase: 68,
    notes: 'Fjärde generationen (2020+) stor förbättring. PHEV och hybrid finns. 5 års garanti från ny är ett plus. Bra värde mot BMW/Mercedes i samma prisklass.',
  },
  {
    brand: 'Hyundai', model: 'i30',
    yearFrom: 2017, yearTo: 2027,
    basePrice: 260000, depreciation: 0.115,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -1700,
    reliabilityBase: 78, resaleBase: 65,
    notes: 'Pålitlig och prisvärd. Fastback-variant mer efterfrågad. Låga servicekostnader. N-variant (hot hatch) håller värdet bättre.',
  },
  {
    brand: 'Hyundai', model: 'IONIQ 5',
    yearFrom: 2021, yearTo: 2027,
    basePrice: 590000, depreciation: 0.145,
    avgMilPerYear: 1300, pricePer1000ExtraMil: -2000,
    reliabilityBase: 74, resaleBase: 65,
    notes: 'Snabbladdning (800V) är ett konkurrensfördelar. Kontrollera batterihälsa (SoH). Deprecierar snabbt men stark produkt. Populär elbil på begagnatmarknaden.',
  },

  // ─── KIA ─────────────────────────────────────────────────────────────────

  {
    brand: 'Kia', model: 'Sportage',
    yearFrom: 2021, yearTo: 2027,
    basePrice: 390000, depreciation: 0.118,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2200,
    reliabilityBase: 78, resaleBase: 69,
    notes: 'Femte generationen (2021+) kraftigt uppgraderad. PHEV och hybrid. 7 års garanti från ny är unikt i klassen. Bra värde­alternativ.',
  },
  {
    brand: 'Kia', model: 'EV6',
    yearFrom: 2021, yearTo: 2027,
    basePrice: 560000, depreciation: 0.140,
    avgMilPerYear: 1300, pricePer1000ExtraMil: -1800,
    reliabilityBase: 75, resaleBase: 64,
    notes: 'Delar plattform med IONIQ 5. Sportig elbil. Kontrollera batterihälsa. Deprecierar snabbt 2021–2022-modeller. GT-variant håller värdet bättre.',
  },
  {
    brand: 'Kia', model: 'Niro',
    yearFrom: 2022, yearTo: 2027,
    basePrice: 440000, depreciation: 0.130,
    avgMilPerYear: 1300, pricePer1000ExtraMil: -2000,
    reliabilityBase: 78, resaleBase: 66,
    notes: 'Andra generationen (2022+) finns som hybrid, laddhybrid och helelektrisk. 7 års garanti från ny. Laddhybrid-varianten kräver batterikontroll.',
  },
  {
    brand: 'Kia', model: 'Ceed',
    yearFrom: 2019, yearTo: 2027,
    basePrice: 320000, depreciation: 0.120,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -1900,
    reliabilityBase: 77, resaleBase: 63,
    notes: 'Golf-klass till lägre pris. Kombi (SW) mest efterfrågad i Sverige. 7 års garanti är ett starkt säljargument begagnat.',
  },
  {
    brand: 'Kia', model: 'Picanto',
    yearFrom: 2017, yearTo: 2027,
    basePrice: 210000, depreciation: 0.115,
    avgMilPerYear: 1200, pricePer1000ExtraMil: -1300,
    reliabilityBase: 76, resaleBase: 60,
    notes: 'Billig och pålitlig småbil. Låga service­kostnader. Mindre efterfrågan andrahand än större Kia-modeller, men lågt inköpspris kompenserar.',
  },

  // ─── NISSAN ──────────────────────────────────────────────────────────────

  {
    brand: 'Nissan', model: 'Qashqai',
    yearFrom: 2021, yearTo: 2027,
    basePrice: 330000, depreciation: 0.125,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -2200,
    reliabilityBase: 76, resaleBase: 65,
    notes: 'Tredje generationen (2021+) med mildhybrid/e-POWER. CVT-växellådan (1.2 DIG-T-motorn) kan överhettas i tät trafik — begär att oljan bytts regelbundet.',
  },
  {
    brand: 'Nissan', model: 'X-Trail',
    yearFrom: 2022, yearTo: 2027,
    basePrice: 400000, depreciation: 0.125,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -2500,
    reliabilityBase: 75, resaleBase: 63,
    notes: 'Fjärde generationen (2022+) med e-POWER (seriehybrid) eller bensin. Rymlig familje-SUV, finns med 7 säten.',
  },
  {
    brand: 'Nissan', model: 'Leaf',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 400000, depreciation: 0.155,
    avgMilPerYear: 1300, pricePer1000ExtraMil: -1600,
    reliabilityBase: 77, resaleBase: 58,
    notes: 'En av de första folkliga elbilarna — mogen teknik. Kontrollera batterihälsa (SoH), särskilt på tidiga exemplar utan aktiv batterikylning. Snabb depreciation.',
  },

  // ─── FORD ─────────────────────────────────────────────────────────────────

  {
    brand: 'Ford', model: 'Focus',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 260000, depreciation: 0.125,
    avgMilPerYear: 1500, pricePer1000ExtraMil: -1700,
    reliabilityBase: 70, resaleBase: 62,
    notes: 'Fjärde generationen (2018+) förbättrad men fortfarande DSG-problem (PowerShift). Undvik 1.0 EcoBoost med kylnings­problem (2012–2017). Kombi (Estate) är populärast.',
  },
  {
    brand: 'Ford', model: 'Kuga',
    yearFrom: 2019, yearTo: 2027,
    basePrice: 350000, depreciation: 0.125,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2100,
    reliabilityBase: 68, resaleBase: 63,
    notes: 'Tredje generationen (2019+). PHEV kräver batterikontroll. Tidiga PHEV hade brandrisker — kontrollera Fords återkallelse­åtgärd. Bensin och mild hybrid mer beprövade.',
  },

  // ─── RENAULT ─────────────────────────────────────────────────────────────

  {
    brand: 'Renault', model: 'Clio',
    yearFrom: 2019, yearTo: 2027,
    basePrice: 230000, depreciation: 0.130,
    avgMilPerYear: 1300, pricePer1000ExtraMil: -1400,
    reliabilityBase: 68, resaleBase: 60,
    notes: 'Femte generationen (2019+). Hybrid (E-Tech) finns från 2021 och är att föredra. Franska bilar deprecierar snabbare i Sverige — bra prisvärda köp för budgetmedvetna.',
  },
  {
    brand: 'Renault', model: 'Kadjar',
    yearFrom: 2015, yearTo: 2022,
    basePrice: 300000, depreciation: 0.130,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -1800,
    reliabilityBase: 67, resaleBase: 58,
    notes: 'Ersatt av Austral 2022. Prisvärda begagnatköp. Kontrollera CVT-växellådan på tidiga exemplar. Låg profil ger rimliga priser.',
  },

  // ─── PEUGEOT ─────────────────────────────────────────────────────────────

  {
    brand: 'Peugeot', model: '3008',
    yearFrom: 2016, yearTo: 2027,
    basePrice: 340000, depreciation: 0.130,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2000,
    reliabilityBase: 68, resaleBase: 60,
    notes: 'Stilig SUV med Peugeots i-Cockpit. Hybrid4 (PHEV) kräver batterikontroll. Deprecierar snabbare än japanska och tyska konkurrenter i Sverige.',
  },

  // ─── TESLA ───────────────────────────────────────────────────────────────

  {
    brand: 'Tesla', model: 'Model 3',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 520000, depreciation: 0.160,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -1800,
    reliabilityBase: 68, resaleBase: 62,
    notes: 'Snabb depreciation (nya prissänkningar påverkar begagnat kontinuerligt). Kontrollera alltid batterihälsa (SoH) och dokumentation av laddhistorik. Highland (2023+) är tydlig uppgradering.',
  },
  {
    brand: 'Tesla', model: 'Model Y',
    yearFrom: 2021, yearTo: 2027,
    basePrice: 600000, depreciation: 0.155,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2000,
    reliabilityBase: 69, resaleBase: 63,
    notes: 'Sveriges näst mest sålda bil 2024. Snabb depreciation — Teslas frekventa prissänkningar slår hårt på begagnatvärdet. Kontrollera kaross­fogningar och panel­gaps.',
  },

  // ─── SUBARU ──────────────────────────────────────────────────────────────

  {
    brand: 'Subaru', model: 'Outback',
    yearFrom: 2014, yearTo: 2027,
    basePrice: 420000, depreciation: 0.110,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2200,
    reliabilityBase: 80, resaleBase: 72,
    notes: 'Populär i Sverige p.g.a. AWD och markfrigång. 39% av Blocket-annonserna säljs inom en vecka. Boxer­motorn kräver korrekt service­intervall för att undvika head gasket-problem.',
  },

  // ─── MINI ────────────────────────────────────────────────────────────────

  {
    brand: 'Mini', model: 'Cooper',
    yearFrom: 2014, yearTo: 2024,
    basePrice: 310000, depreciation: 0.145,
    avgMilPerYear: 1300, pricePer1000ExtraMil: -1800,
    reliabilityBase: 62, resaleBase: 63,
    notes: 'Charmig men kostsam att äga. Kända problem: termostat, kylsystem, tim­kedja (B38/B48). Hög servicekostnad relativt listvärde. Attraktivt andrahandsvärde tack vare märkes­premium.',
  },

  // ─── SEAT / CUPRA ────────────────────────────────────────────────────────

  {
    brand: 'Seat', model: 'Leon',
    yearFrom: 2020, yearTo: 2027,
    basePrice: 290000, depreciation: 0.118,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -1800,
    reliabilityBase: 73, resaleBase: 64,
    notes: 'VW-grupp plattform. FR-variant mer efterfrågad och håller värdet bättre. eHybrid kräver batterikontroll. Prisvärd kompaktklass.',
  },

  // ─── MAZDA ───────────────────────────────────────────────────────────────

  {
    brand: 'Mazda', model: 'CX-5',
    yearFrom: 2017, yearTo: 2027,
    basePrice: 380000, depreciation: 0.112,
    avgMilPerYear: 1400, pricePer1000ExtraMil: -2200,
    reliabilityBase: 83, resaleBase: 70,
    notes: 'Stark tillförlitlighet och köregenskaper. Ingen PHEV/hybrid i klassen — bensin och diesel. SkyActiv-tekniken välbeprövad. Håller värdet bättre än snittet i klassen.',
  },

  // ─── DACIA ───────────────────────────────────────────────────────────────

  {
    brand: 'Dacia', model: 'Duster',
    yearFrom: 2018, yearTo: 2027,
    basePrice: 210000, depreciation: 0.115,
    avgMilPerYear: 1300, pricePer1000ExtraMil: -1300,
    reliabilityBase: 72, resaleBase: 64,
    notes: 'Exceptionellt lågt nypris ger bra värde­beräkning. Enkel teknologi — fördel för reparations­kostnader. Låg profil i Sverige men stigande popularitet.',
  },
]

/**
 * Slå upp referensdata för ett specifikt fordon.
 * Returnerar matchande post eller en generell default.
 */
export function lookupModelReference(
  brand: string,
  model: string,
  year: number
): { ref: ModelReference; isDefault: boolean } {
  const normalise = (s: string) =>
    s.toLowerCase().trim()
      .replace(/\s+/g, ' ')
      .replace(/xc 60/g, 'xc60')
      .replace(/v 60/g, 'v60')
      .replace(/-/g, ' ')

  const b = normalise(brand)
  const m = normalise(model)

  // Exakt matchning på märke + modell + år
  const exact = MODEL_REFERENCES.find(r =>
    normalise(r.brand) === b &&
    normalise(r.model) === m &&
    year >= r.yearFrom &&
    year <= r.yearTo
  )
  if (exact) return { ref: exact, isDefault: false }

  // Matchning utan år (utanför generationsintervall)
  const brandModel = MODEL_REFERENCES.find(r =>
    normalise(r.brand) === b &&
    normalise(r.model) === m
  )
  if (brandModel) return { ref: brandModel, isDefault: false }

  // Matchning på märke — använd märkets genomsnitt
  const brandOnly = MODEL_REFERENCES.filter(r => normalise(r.brand) === b)
  if (brandOnly.length > 0) {
    const avgRef: ModelReference = {
      brand, model, yearFrom: 1990, yearTo: 2030,
      basePrice: Math.round(brandOnly.reduce((s, r) => s + r.basePrice, 0) / brandOnly.length),
      depreciation: brandOnly.reduce((s, r) => s + r.depreciation, 0) / brandOnly.length,
      avgMilPerYear: 1500,
      pricePer1000ExtraMil: -2200,
      reliabilityBase: Math.round(brandOnly.reduce((s, r) => s + r.reliabilityBase, 0) / brandOnly.length),
      resaleBase: Math.round(brandOnly.reduce((s, r) => s + r.resaleBase, 0) / brandOnly.length),
      notes: `Genererat genomsnitt för ${brand} — begränsad specifik data för ${model}.`,
    }
    return { ref: avgRef, isDefault: false }
  }

  // Absolut fallback
  return {
    ref: {
      brand, model, yearFrom: 1990, yearTo: 2030,
      basePrice: 300000, depreciation: 0.125,
      avgMilPerYear: 1500, pricePer1000ExtraMil: -2000,
      reliabilityBase: 68, resaleBase: 63,
      notes: 'Generell default — ingen specifik marknadsdata tillgänglig för denna modell.',
    },
    isDefault: true,
  }
}

/**
 * Statistik över databasen — användbart för dashboards och debugging.
 */
export function getReferenceStats() {
  const brands = Array.from(new Set(MODEL_REFERENCES.map(r => r.brand))).sort()
  return {
    totalModels: MODEL_REFERENCES.length,
    brands: brands.length,
    brandBreakdown: brands.map(b => ({
      brand: b,
      models: MODEL_REFERENCES.filter(r => r.brand === b).map(r => r.model),
    })),
    avgReliability: Math.round(
      MODEL_REFERENCES.reduce((s, r) => s + r.reliabilityBase, 0) / MODEL_REFERENCES.length
    ),
    avgResale: Math.round(
      MODEL_REFERENCES.reduce((s, r) => s + r.resaleBase, 0) / MODEL_REFERENCES.length
    ),
  }
}
