-- ============================================================
-- Bilanalys — Referensdata seed
-- Kör i Supabase Dashboard → SQL Editor
-- Raderar och återskapar all referensdata.
-- ============================================================

TRUNCATE model_references, known_issues RESTART IDENTITY CASCADE;

-- ─── MODEL REFERENCES ────────────────────────────────────────────────────────

INSERT INTO model_references
  (brand, model, year_from, year_to, base_price_sek, depreciation_rate,
   avg_mil_per_year, price_per_1000_extra_mil, reliability_base, resale_base, notes)
VALUES

-- VOLVO
('Volvo','XC60',       2017,2025, 620000, 0.120, 1400,-3000, 74,76, 'Sveriges mest sålda bil 2024. Stark efterfrågan. T8 PHEV-varianter tappar snabbare p.g.a. äldre batteri.'),
('Volvo','V60',        2018,2025, 480000, 0.125, 1500,-2800, 75,74, 'Kombibilens flaggskepp. Cross Country håller värdet bättre. T5/T6 bensin mest efterfrågat begagnat.'),
('Volvo','V60 Cross Country',2018,2025,530000,0.115,1400,-2600,75,78,'Snabbast säljande modell Blocket 2025 — 43% borta inom en vecka. Premium mot standard V60.'),
('Volvo','XC40',       2018,2025, 430000, 0.130, 1400,-2500, 72,72, 'Populär hos yngre köpare. EX40 (el) deprecierar snabbare än bensin p.g.a. snabb teknikutveckling.'),
('Volvo','V90',        2016,2025, 620000, 0.130, 1500,-3200, 74,72, 'T8 PHEV vanlig från tjänstebilsflottor. Kontrollera alltid batteristatus på laddhybrid.'),
('Volvo','V90 Cross Country',2017,2025,680000,0.120,1400,-3000,74,75,'42% av Blocket-annonserna säljs inom en vecka. Stark nisch: kombi + terrängklarhet.'),
('Volvo','XC90',       2015,2025, 820000, 0.130, 1300,-3500, 71,73, 'T8 PHEV kräver batterikontroll. Hög servicekostnad — 15 000–25 000 kr/år auktoriserad verkstad.'),
('Volvo','S60',        2018,2025, 450000, 0.130, 1500,-2600, 75,70, 'Sedan är mindre populär än kombi i Sverige. Lägre efterfrågan ger sämre andrahandsvärde än V60.'),

-- TOYOTA
('Toyota','RAV4',      2018,2025, 440000, 0.110, 1400,-2400, 87,76, 'Hybrid (2019+) klart att föredra — lägre driftkostnad och bättre andrahandsvärde. PHEV kräver batterikontroll.'),
('Toyota','Corolla',   2018,2025, 310000, 0.105, 1500,-1800, 89,72, 'En av Toyotas mest tillförlitliga. Hybrid standard 2019+. Låga servicekostnader.'),
('Toyota','Yaris',     2020,2025, 240000, 0.105, 1200,-1400, 90,70, 'Gen 4 (2020+) stort kliv framåt. Hybrid standard. Enastående driftsäkerhet.'),
('Toyota','C-HR',      2016,2025, 330000, 0.115, 1300,-1900, 85,68, 'Polariserande design påverkar andrahandsvärdet negativt i vissa regioner. Hybrid tekniskt pålitlig.'),
('Toyota','Land Cruiser',2008,2021,750000,0.090,1400,-2000, 88,82, 'Extremt högt andrahandsvärde. Diesel D-4D känd för lång livslängd. Global efterfrågan håller priset uppe.'),

-- VOLKSWAGEN
('Volkswagen','Golf',  2019,2025, 330000, 0.115, 1500,-2000, 72,67, 'Golf 8 (2019+) haft DSG/infotainment-problem. Golf 7 mer beprövad. Kontrollera DSG-uppdateringar.'),
('Volkswagen','Passat',2014,2023, 380000, 0.120, 1600,-2200, 71,64, 'Populär tjänstebil — många ex-leasing med hög miltal. GTE PHEV kräver batterikontroll.'),
('Volkswagen','Tiguan',2016,2025, 420000, 0.120, 1400,-2500, 70,68, 'Välsäljande familje-SUV. DSG-problem 2016–2018. Allspace 7-sits håller värdet något bättre.'),
('Volkswagen','T-Cross',2018,2025,260000, 0.118, 1300,-1600, 73,68, 'Snabbast säljande modell Blocket april 2025 — 44% borta inom en vecka.'),
('Volkswagen','ID.3',  2020,2025, 380000, 0.160, 1200,-1500, 65,58, 'Tidig mjukvara 2020–2021 hade allvarliga buggar. Kontrollera uppdateringar och batterihälsa (SoH).'),
('Volkswagen','ID.4',  2021,2025, 480000, 0.155, 1300,-2000, 67,60, 'Mer mogen elbil än ID.3. Kontrollera batterihälsa. Snabb depreciation gynnar köparen.'),

-- BMW
('BMW','3-serie',      2018,2025, 520000, 0.140, 1500,-3000, 62,70, 'G20 (2018+) mer pålitlig än F30. N20 4-cyl äldre motor — kontrollera timing chain. 20–30 kkr/år i service.'),
('BMW','5-serie',      2016,2025, 680000, 0.145, 1600,-3500, 60,68, 'G30 (2016+) fler elektronisk­problem. 530e PHEV kräver batterikontroll. Hög servicekostnad.'),
('BMW','X3',           2017,2025, 620000, 0.135, 1400,-3200, 63,70, 'G01 (2017+) stor förbättring. Stark efterfrågan. Kontrollera oljekonsumtion på B58 6-cyl.'),
('BMW','X5',           2018,2025, 900000, 0.140, 1400,-4000, 60,69, 'G05 (2018+). Komplex med höga underhålls­kostnader. xDrive45e PHEV kräver batterikontroll.'),

-- AUDI
('Audi','A3',          2020,2027, 370000, 0.135, 1500,-2000, 66,68, 'Golf-konkurrent med Audi-premium. EA888-motorer delar konstruktion med VW/Skoda — samma kedjespännar­problem kan förekomma på tidiga exemplar.'),
('Audi','Q3',          2019,2027, 400000, 0.135, 1400,-2400, 65,68, 'Populär kompakt-SUV. Delar plattform med VW Tiguan/Skoda Karoq. Stark efterfrågan i Sverige håller andrahandsvärdet uppe.'),
('Audi','A4',          2019,2027, 470000, 0.140, 1500,-3000, 65,69, 'Direkt konkurrent till BMW 3-serie och Mercedes C-klass. Tidiga 2.0 TFSI (EA888 Gen1) kan ha kedjespännar­problem — kontrollera servicehistorik.'),
('Audi','A6',          2018,2027, 680000, 0.145, 1600,-3500, 64,68, 'Storsäljande tjänstebil. Komplex elektronik och luftfjädring på högre utrustningsnivåer ger högre servicekostnad. Stark efterfrågan andrahand.'),
('Audi','Q5',          2018,2027, 630000, 0.135, 1400,-3200, 66,70, 'Konkurrerar med BMW X3 och Mercedes GLC. Bra andrahandsvärde tack vare stark efterfrågan på premium-SUV i Sverige.'),

-- MERCEDES-BENZ
('Mercedes-Benz','C-klass',2014,2025,560000,0.140,1500,-3000,63,68,'W205: kända rost­problem bakre fjädring, infotainment-fel. W206 (2021+) mer pålitlig. Höga servicekostnader.'),
('Mercedes-Benz','E-klass',2016,2025,720000,0.140,1600,-3500,62,67,'W213 (2016+). Komplex elektronik — undvik tidiga exemplar. 300de PHEV kräver batterikontroll.'),
('Mercedes-Benz','GLC', 2015,2025, 640000, 0.135, 1400,-3200, 63,69, 'X253 och C254 (2022+). Populär tjänstebils-SUV. 300e/300de PHEV kräver batterikontroll.'),

-- SKODA
('Skoda','Octavia',    2012,2025, 310000, 0.115, 1600,-1900, 76,67, 'En av marknadens bästa värde­bilar. DSG-uppdateringar viktiga. Combi-variant starkt att föredra.'),
('Skoda','Superb',     2015,2025, 380000, 0.120, 1600,-2200, 75,65, 'Enormt bagageutrymme. iV PHEV kräver batterikontroll. Låg profil ger bra priser begagnat.'),
('Skoda','Kodiaq',     2016,2025, 400000, 0.120, 1400,-2400, 74,66, '7-sits familje-SUV till bra pris. RS håller värdet bättre. DSG-problem tidiga exemplar.'),

-- HYUNDAI
('Hyundai','Tucson',   2020,2025, 400000, 0.120, 1400,-2300, 77,68, 'Gen 4 (2020+) stor förbättring. 5 års garanti från ny är ett plus. Bra värde mot tyska konkurrenter.'),
('Hyundai','i30',      2017,2025, 260000, 0.115, 1400,-1700, 78,65, 'Pålitlig och prisvärd. Fastback mer efterfrågad. N-variant håller värdet bättre.'),
('Hyundai','IONIQ 5',  2021,2025, 590000, 0.145, 1300,-2000, 74,65, 'Snabbladdning 800V är ett plus. Kontrollera batterihälsa (SoH). Deprecierar snabbt.'),

-- KIA
('Kia','Sportage',     2021,2025, 390000, 0.118, 1400,-2200, 78,69, 'Gen 5 (2021+) kraftigt uppgraderad. 7 års garanti unik i klassen. Bra värde­alternativ.'),
('Kia','EV6',          2021,2025, 560000, 0.140, 1300,-1800, 75,64, 'Delar plattform med IONIQ 5. GT håller värdet bättre. Kontrollera batterihälsa.'),
('Kia','Niro',         2022,2027, 440000, 0.130, 1300,-2000, 78,66, 'Andra generationen (2022+) finns som hybrid, laddhybrid och helelektrisk. 7 års garanti från ny. Laddhybrid-varianten kräver batterikontroll.'),
('Kia','Ceed',         2019,2027, 320000, 0.120, 1500,-1900, 77,63, 'Golf-klass till lägre pris. Kombi (SW) mest efterfrågad i Sverige. 7 års garanti är ett starkt säljargument begagnat.'),
('Kia','Picanto',      2017,2027, 210000, 0.115, 1200,-1300, 76,60, 'Billig och pålitlig småbil. Låga service­kostnader. Mindre efterfrågan andrahand än större Kia-modeller, men lågt inköpspris kompenserar.'),

-- NISSAN
('Nissan','Qashqai',   2021,2027, 330000, 0.125, 1500,-2200, 76,65, 'Tredje generationen (2021+) med mildhybrid/e-POWER. CVT-växellådan (1.2 DIG-T-motorn) kan överhettas i tät trafik — begär att oljan bytts regelbundet.'),
('Nissan','X-Trail',   2022,2027, 400000, 0.125, 1500,-2500, 75,63, 'Fjärde generationen (2022+) med e-POWER (seriehybrid) eller bensin. Rymlig familje-SUV, finns med 7 säten.'),
('Nissan','Leaf',      2018,2027, 400000, 0.155, 1300,-1600, 77,58, 'En av de första folkliga elbilarna — mogen teknik. Kontrollera batterihälsa (SoH), särskilt på tidiga exemplar utan aktiv batterikylning. Snabb depreciation.'),

-- FORD
('Ford','Focus',       2018,2025, 260000, 0.125, 1500,-1700, 70,62, 'Gen 4 (2018+) förbättrad men DSG-problem. Kombi (Estate) populärast. Undvik äldre PowerShift.'),
('Ford','Kuga',        2019,2025, 350000, 0.125, 1400,-2100, 68,63, 'Gen 3 (2019+). PHEV kräver batterikontroll — tidig brandriskretur kontrollera utförd.'),

-- RENAULT
('Renault','Clio',     2019,2025, 230000, 0.130, 1300,-1400, 68,60, 'Gen 5 (2019+). Hybrid (E-Tech) 2021+ att föredra. Franska bilar deprecierar snabbare i Sverige.'),
('Renault','Kadjar',   2015,2022, 300000, 0.130, 1400,-1800, 67,58, 'Ersatt av Austral 2022. Prisvärda begagnatköp. Kontrollera CVT-växellådan.'),

-- PEUGEOT
('Peugeot','3008',     2016,2025, 340000, 0.130, 1400,-2000, 68,60, 'i-Cockpit. Hybrid4 PHEV kräver batterikontroll. Deprecierar snabbare än japanska/tyska konkurrenter.'),

-- TESLA
('Tesla','Model 3',    2018,2025, 520000, 0.160, 1400,-1800, 68,62, 'Snabb depreciation (prissänkningar påverkar). Kontrollera batterihälsa och laddhistorik. Highland 2023+ är uppgradering.'),
('Tesla','Model Y',    2021,2025, 600000, 0.155, 1400,-2000, 69,63, 'Sveriges näst mest sålda bil 2024. Frekventa prissänkningar slår hårt på begagnatvärdet. Kontrollera karossfogningar.'),

-- SUBARU
('Subaru','Outback',   2014,2025, 420000, 0.110, 1400,-2200, 80,72, 'Populär i Sverige p.g.a. AWD. 39% av Blocket-annonserna säljs inom en vecka. Kontrollera boxer­motorns service.'),

-- MINI
('Mini','Cooper',      2014,2024, 310000, 0.145, 1300,-1800, 62,63, 'Kända problem: termostat, kylsystem, timkedja (B38/B48). Hög servicekostnad. Stark märkes­premium.'),

-- SEAT
('Seat','Leon',        2020,2025, 290000, 0.118, 1400,-1800, 73,64, 'VW-grupp plattform. FR-variant mer efterfrågad. eHybrid kräver batterikontroll.'),

-- MAZDA
('Mazda','CX-5',       2017,2025, 380000, 0.112, 1400,-2200, 83,70, 'Stark tillförlitlighet. Ingen PHEV/hybrid. SkyActiv välbeprövad. Håller värdet bättre än snittet.'),

-- DACIA
('Dacia','Duster',     2018,2025, 210000, 0.115, 1300,-1300, 72,64, 'Exceptionellt lågt nypris. Enkel teknologi — lägre reparations­kostnader. Stigande popularitet i Sverige.');


-- ─── KNOWN ISSUES ────────────────────────────────────────────────────────────

INSERT INTO known_issues
  (brand, model, year_from, year_to, fuel_type, severity, category, rule_id, title, description, source_url)
VALUES

-- VOLVO
('Volvo','V60',  2020,2021, NULL,    'low',    'recall',     'volvo_v60_2020_brakes',
 'Återkallelse: bromsmjukvara (2020–2021)',
 'Volvo återkallade V60 och XC60 2020–2021 för en uppdatering av ABS-systemets mjukvara. Kontrollera med Volvos återförsäljare att åtgärden är utförd (ta med reg­nummer).',
 'https://www.transportstyrelsen.se/sv/vagtrafik/fordon/aterkallelse/'),

('Volvo','XC60', 2020,2021, NULL,    'low',    'recall',     'volvo_xc60_2020_brakes',
 'Återkallelse: bromsmjukvara (2020–2021)',
 'Samma ABS-mjukvaruåterkallelse som V60 2020–2021. Kontrollera med Volvos återförsäljare att åtgärden är utförd.',
 'https://www.transportstyrelsen.se/sv/vagtrafik/fordon/aterkallelse/'),

('Volvo','XC60', 2018,2020, NULL,    'low',    'electrical', 'volvo_xc60_sensus_freeze',
 'Sensus infotainment: uppfrysningar',
 'Volvo XC60 2018–2020 kan uppleva att Sensus-systemet fryser eller startar om spontant. Lösning: mjukvaruuppdatering via auktoriserad Volvo-verkstad. Ofta kostnadsfritt under garantiperioden.',
 NULL),

('Volvo','XC90', 2015,2019, 'Laddhybrid', 'medium', 'engine', 'volvo_xc90_t8_oil_dilution',
 'T8 PHEV: oljespädning vid kortdistans­körning',
 'XC90 T8 laddhybrid 2015–2019 kan drabbas av oljespädning med bensin vid frekvent kortdistans­körning på el. Kontrollera oljans kvalitet och byt oftare än rekommenderat om bilen körts mycket kort.',
 NULL),

-- BMW
('BMW','3-serie',2012,2018, 'Bensin',  'high',   'engine',   'bmw_n20_timing_chain',
 'N20/N26 motor: för tidigt timing chain-slitage',
 'BMW:s N20 och N26 fyrcylindriga bensin­motorer (2012–2018) kan drabbas av för tidigt timing chain-slitage, vilket kan leda till motorhaveri. Kontrollera servicehistorik noggrant och lyssna efter skrammel vid kallstart. Åtgärd: byte av timing chain guide och spännar­arm.',
 'https://www.bmwblog.com/2019/01/15/bmw-n20-timing-chain/'),

('BMW','3-serie',2006,2013, 'Bensin',  'high',   'engine',   'bmw_n52_valve_cover',
 'N52 motor: ventilkåpa och oljespill',
 'N52-motorns ventilkåpa av plast spricker med åren och ger oljespill. Vanligt på E90/E91 316i–328i. Kontrollera undersidan av motorn för oljespår. Relativt billig reparation men symptom­atisk för åldrande plastdetaljer.',
 NULL),

('BMW','5-serie',2016,2020, NULL,      'medium', 'electrical','bmw_g30_infotainment_crash',
 'G30 iDrive 6: programvarukrascher',
 'BMW 5-serie G30 2016–2020 har rapporterats ge sporadiska iDrive-krascher och fördröjd start. Mjukvaru­uppdatering finns via BMW-verkstad. Kontrollera att senaste programvara är installerad.',
 NULL),

-- VOLKSWAGEN
('Volkswagen','Golf',  2013,2016,'Bensin','high','gearbox','vw_dsg7_dq200_shudder',
 'DSG7 (DQ200) 7-stegs torrkoppling: ryckningar',
 'VW Golf med 7-stegs DSG-låda (DQ200, används på 1.0/1.2/1.4 TSI) kan ge ryckningar vid låga hastigheter och vid parkerings­manövrar. Mjukvaruuppdatering och mekatro­nikbyte finns via auktoriserad VW-verkstad.',
 'https://www.vw.com/en/models/golf.html'),

('Volkswagen','Golf',  2019,2022, NULL, 'medium','electrical','vw_golf8_infotainment_bugs',
 'Golf 8: allvarliga mjukvarufel vid lansering',
 'Golf 8 (2019–2022) levererades med ett infotainmentsystem fullt av buggar: fördröjd respons, kraschande mjukvara och felande säkerhetssystem. VW har publicerat flera uppdateringar. Kontrollera alltid att senaste mjukvara är installerad.',
 NULL),

('Volkswagen','Passat',2014,2018,'Diesel','medium','engine','vw_ea288_egr_fouling',
 'EA288 diesel: EGR-ventil och insugs­rör',
 'VW:s EA288 2.0 TDI-motor (2014–2018) kan drabbas av EGR-ventil­problem och sotning av insugs­rör, vilket ger ojämn tomgång och reducerad effekt. Förebygg med regelbundna motorvärmare och undvik frekventa kortdistans­körningar.',
 NULL),

-- MERCEDES-BENZ
('Mercedes-Benz','C-klass',2014,2018,NULL,'medium','engine','mercedes_w205_rustcorrosion',
 'W205 C-klass: rostangrepp bakre fjädring',
 'Mercedes-Benz C-klass W205 (2014–2018) har dokumenterade rost­problem på bakre fjädrings­ben och subframe i saltbältesklimat. Kontrollera undersidan noggrant, särskilt vid köp av bil med saltzonhistorik (norra Sverige, kustområden).',
 NULL),

('Mercedes-Benz','E-klass',2016,2019,NULL,'low','electrical','mercedes_w213_magic_body_fail',
 'W213 E-klass: Magic Body Control-fel',
 'E-klass W213 med Magic Body Control-fjädring kan ge dyrbara reparationer om systemet fallerar. Kontrollera om bilen är utrustad med detta system och om det fungerar korrekt. Service­kostnad kan överstiga 30 000 kr vid haveri.',
 NULL),

-- FORD
('Ford','Kuga',        2019,2020,'Laddhybrid','high','recall','ford_kuga_phev_fire_risk',
 'Kuga PHEV: brandriskretur (2021)',
 'Ford återkallade Kuga PHEV 2019–2020 p.g.a. risk för att batteriet kan ta eld vid laddning i vissa fall. Ford erbjöd mjukvaruåtgärd följt av batteriinspektioner. Kontrollera alltid att återkallelseåtgärden är utförd på Kuga PHEV.',
 'https://media.ford.com/content/fordmedia/feu/en/news/2021/kuga-phev-recall.html'),

('Ford','Focus',       2011,2016,'Bensin','high','gearbox','ford_focus_powershift_slip',
 'PowerShift DCT: slirning och hackning',
 'Ford Focus med PowerShift automatiserad manuell växellåda (2011–2016, 1.0/1.6 EcoBoost) är ökänd för slirning, hackning och plötsliga kraftbortfall. Undvik dessa årsmodeller med denna växellåda.',
 NULL),

-- TOYOTA
('Toyota','Land Cruiser',2002,2015,'Diesel','medium','engine','toyota_1kd_ftv_injector',
 'Land Cruiser 1KD-FTV: injektor­problem',
 'Toyotas 3.0 D-4D motor (1KD-FTV) kan drabbas av injektorproblem och höjd oljekonsumtion vid hög miltal (>15 000 mil). Kontrollera kompression och oljekvalitet. Inspektera alltid vid köp av exemplar med hög miltal.',
 NULL),

-- SUBARU
('Subaru','Outback',   2010,2018, NULL,   'medium','engine','subaru_boxer_head_gasket',
 'Boxer­motor: head gasket vid högt miltal',
 'Subarus boxer­motorer (EJ25 och tidiga FA20) är kända för att kunna drabbas av head gasket-problem vid högt miltal (>12 000 mil) om service­intervallen inte följts. Kontrollera kylvätskenivå och förekomst av kylvätska i oljan.',
 NULL),

-- MINI
('Mini','Cooper',      2014,2019,'Bensin','medium','engine','mini_b38_timing_chain',
 'B38/B48 motor: timing chain-slitage',
 'Minis trebladiga B38-motor (och fyrcylindriga B48) kan drabbas av för tidigt timing chain-slitage, likt BMW N20. Kontrollera servicehistorik och lyssna efter skrammel vid kallstart. Rekommendera motorinspektion före köp.',
 NULL),

('Mini','Cooper',      2007,2015,'Bensin','medium','engine','mini_n12_n14_timing_chain',
 'N12/N14 motor: timing chain och thermostat',
 'Tidigare Mini med N12/N14-motor (2007–2015) har välkänd timing chain-problematik och kylsystemsproblem (termostat, vattenpump). Dessa motorer bör alltid inspekteras noga vid köp.',
 NULL),

-- TESLA
('Tesla','Model 3',    2018,2020, 'El',   'medium','electrical','tesla_m3_panel_gaps_early',
 'Tidig Model 3: karossfogar och lackkvalitet',
 'Tidiga Tesla Model 3 (2018–2020, Fremont-produktion) levererades med ojämna karossfogar och varierande lackkvalitet. Kontrollera karossens jämnhet visuellt vid alla kanter och hörn. Cosmetic issues — påverkar inte funktion men är förhandlings­argument.',
 NULL),

('Tesla','Model Y',    2021,2022, 'El',   'low',   'electrical','tesla_my_heat_pump_cold',
 'Model Y värmepump: problem i extrem kyla',
 'Tesla Model Y med värmepump (standard 2021+) har i vissa fall rapporterats ge felmeddelanden och reducerad prestanda vid temperaturer under -15°C. Tesla har åtgärdat med OTA-uppdateringar. Kontrollera att senaste mjukvara är installerad.',
 NULL),

-- HYUNDAI
('Hyundai','IONIQ 5',  2021,2022, 'El',   'low',   'recall',   'ioniq5_brake_recall',
 'IONIQ 5: bromskraft­återkallelse (2022)',
 'Hyundai återkallade vissa IONIQ 5 från 2021–2022 för en mjukvaruuppdatering av bromssystemet. Kontrollera med Hyundai-verkstad att åtgärden är utförd med bilens VIN-nummer.',
 NULL),

-- VOLKSWAGEN ID
('Volkswagen','ID.3',  2020,2021, 'El',   'high',  'electrical','vw_id3_software_launch',
 'ID.3 (2020–2021): genomgripande mjukvarubugg­ar',
 'ID.3 levererades 2020–2021 med allvarliga mjukvarufel: felande bakhjuls­styrning, instabil infotainment och felande förarassistans. VW skickade bilar tillbaka till fabrik för mjukvarufix. Kontrollera ALLTID att senaste mjukvara är installerad (>3.0) och provkör alla assistans­system.',
 NULL);


-- ─── Verifiering ──────────────────────────────────────────────────────────────

SELECT
  'model_references' AS table_name,
  COUNT(*) AS rows,
  COUNT(DISTINCT brand) AS brands
FROM model_references

UNION ALL

SELECT
  'known_issues',
  COUNT(*),
  COUNT(DISTINCT brand)
FROM known_issues;


-- ─── MARKET MEDIANS TABLE ────────────────────────────────────────────────────
-- Faktiska marknadsmedian-priser per modell/årsmodell.
-- Speglar data/marketMedians.ts.
-- Fas 2: populeras automatiskt av nightly-scrapern.

CREATE TABLE IF NOT EXISTS market_medians (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand      TEXT NOT NULL,
  model      TEXT NOT NULL,
  year       INT  NOT NULL,
  median_sek INT  NOT NULL,
  source     TEXT DEFAULT 'manual_seed',
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (brand, model, year)
);

CREATE INDEX IF NOT EXISTS market_medians_lookup ON market_medians (brand, model, year);

-- Seed data (top modeller, maj 2025)
INSERT INTO market_medians (brand, model, year, median_sek) VALUES
-- Volvo V60
('Volvo','V60',2024,390000),('Volvo','V60',2023,360000),('Volvo','V60',2022,325000),
('Volvo','V60',2021,300000),('Volvo','V60',2020,280000),('Volvo','V60',2019,250000),
('Volvo','V60',2018,215000),('Volvo','V60',2017,185000),('Volvo','V60',2016,165000),
-- Volvo V60 Cross Country
('Volvo','V60 Cross Country',2024,440000),('Volvo','V60 Cross Country',2023,405000),
('Volvo','V60 Cross Country',2022,370000),('Volvo','V60 Cross Country',2021,335000),
('Volvo','V60 Cross Country',2020,300000),('Volvo','V60 Cross Country',2019,265000),
-- Volvo XC60
('Volvo','XC60',2024,490000),('Volvo','XC60',2023,455000),('Volvo','XC60',2022,420000),
('Volvo','XC60',2021,385000),('Volvo','XC60',2020,345000),('Volvo','XC60',2019,305000),
('Volvo','XC60',2018,265000),('Volvo','XC60',2017,235000),
-- Volvo XC40
('Volvo','XC40',2024,380000),('Volvo','XC40',2023,350000),('Volvo','XC40',2022,315000),
('Volvo','XC40',2021,280000),('Volvo','XC40',2020,245000),('Volvo','XC40',2019,210000),
-- Volvo V90
('Volvo','V90',2024,510000),('Volvo','V90',2023,470000),('Volvo','V90',2022,430000),
('Volvo','V90',2021,390000),('Volvo','V90',2020,350000),('Volvo','V90',2019,310000),
('Volvo','V90',2018,270000),
-- Volvo XC90
('Volvo','XC90',2024,650000),('Volvo','XC90',2023,600000),('Volvo','XC90',2022,550000),
('Volvo','XC90',2021,500000),('Volvo','XC90',2020,450000),('Volvo','XC90',2019,400000),
('Volvo','XC90',2018,355000),('Volvo','XC90',2017,315000),
-- BMW 3-serie
('BMW','3-serie',2024,430000),('BMW','3-serie',2023,395000),('BMW','3-serie',2022,360000),
('BMW','3-serie',2021,320000),('BMW','3-serie',2020,285000),('BMW','3-serie',2019,255000),
('BMW','3-serie',2018,225000),('BMW','3-serie',2017,195000),('BMW','3-serie',2016,170000),
('BMW','3-serie',2015,145000),('BMW','3-serie',2014,125000),('BMW','3-serie',2013,105000),
-- Toyota Corolla
('Toyota','Corolla',2024,290000),('Toyota','Corolla',2023,270000),('Toyota','Corolla',2022,250000),
('Toyota','Corolla',2021,225000),('Toyota','Corolla',2020,200000),('Toyota','Corolla',2019,175000),
-- Toyota RAV4
('Toyota','RAV4',2024,420000),('Toyota','RAV4',2023,390000),('Toyota','RAV4',2022,355000),
('Toyota','RAV4',2021,320000),('Toyota','RAV4',2020,290000),('Toyota','RAV4',2019,260000),
-- Volkswagen Golf
('Volkswagen','Golf',2024,275000),('Volkswagen','Golf',2023,255000),('Volkswagen','Golf',2022,235000),
('Volkswagen','Golf',2021,210000),('Volkswagen','Golf',2020,190000),('Volkswagen','Golf',2019,170000),
('Volkswagen','Golf',2018,150000),
-- Tesla Model 3
('Tesla','Model 3',2024,390000),('Tesla','Model 3',2023,355000),('Tesla','Model 3',2022,315000),
('Tesla','Model 3',2021,275000),('Tesla','Model 3',2020,235000),('Tesla','Model 3',2019,200000),
('Tesla','Model 3',2018,170000),
-- Tesla Model Y
('Tesla','Model Y',2024,435000),('Tesla','Model Y',2023,395000),
('Tesla','Model Y',2022,350000),('Tesla','Model Y',2021,305000),
-- Skoda Octavia
('Skoda','Octavia',2024,280000),('Skoda','Octavia',2023,260000),('Skoda','Octavia',2022,235000),
('Skoda','Octavia',2021,210000),('Skoda','Octavia',2020,185000),('Skoda','Octavia',2019,165000),
-- Mercedes-Benz C-klass
('Mercedes-Benz','C-klass',2024,500000),('Mercedes-Benz','C-klass',2023,460000),
('Mercedes-Benz','C-klass',2022,420000),('Mercedes-Benz','C-klass',2021,370000),
('Mercedes-Benz','C-klass',2020,320000),('Mercedes-Benz','C-klass',2019,275000),
('Mercedes-Benz','C-klass',2018,240000),('Mercedes-Benz','C-klass',2017,205000),
-- Volkswagen Tiguan
('Volkswagen','Tiguan',2024,360000),('Volkswagen','Tiguan',2023,335000),
('Volkswagen','Tiguan',2022,305000),('Volkswagen','Tiguan',2021,275000),
('Volkswagen','Tiguan',2020,245000),('Volkswagen','Tiguan',2019,215000),
-- Hyundai Tucson
('Hyundai','Tucson',2024,335000),('Hyundai','Tucson',2023,305000),
('Hyundai','Tucson',2022,275000),('Hyundai','Tucson',2021,245000)
ON CONFLICT (brand, model, year) DO UPDATE SET median_sek = EXCLUDED.median_sek, updated_at = now();

-- Supabase RPC-funktion för att hämta median med fallback
CREATE OR REPLACE FUNCTION get_market_median_v2(
  p_brand TEXT, p_model TEXT, p_year INT
)
RETURNS TABLE (median_sek INT, source TEXT)
LANGUAGE SQL STABLE AS $$
  -- First try exact match in market_medians
  SELECT median_sek, source FROM market_medians
  WHERE LOWER(brand) = LOWER(p_brand)
    AND LOWER(model) = LOWER(p_model)
    AND year = p_year
  UNION ALL
  -- Then try computed median from actual listings (Phase 2)
  SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_sek)::INT,
    'market_listings'
  FROM market_listings
  WHERE LOWER(brand) = LOWER(p_brand)
    AND LOWER(model) = LOWER(p_model)
    AND year = p_year
    AND scraped_at > NOW() - INTERVAL '90 days'
    AND price_sek > 0
  HAVING COUNT(*) >= 5
  LIMIT 1;
$$;

-- Verifiering
SELECT brand, model, COUNT(*) as years_covered, MIN(year), MAX(year)
FROM market_medians
GROUP BY brand, model
ORDER BY brand, model;
