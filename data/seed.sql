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


-- ─── VOLVO — verifierade recalls/kända fel (Claude Deep Research + manuell
-- verifiering mot svensk press och NHTSA/KBA, 2026-08-13) ────────────────────
-- Källor: Vi Bilägare, SVT Nyheter, Göteborgs-Posten, Ny Teknik, Mest Motor,
-- Börskollen, NHTSA, tyska KBA. Se data/volvo_known_issues_verified.sql för
-- fullständig verifieringslogg. Ingen rule_id-krock mot ovanstående (äldre)
-- Volvo-rader.

INSERT INTO known_issues
  (brand, model, year_from, year_to, fuel_type, severity, category, rule_id, title, description, source_url)
VALUES
-- ========== T8 HÖGSPÄNNINGSBATTERI (BRANDRISK) ==========
('Volvo','XC60',2020,2022,'Laddhybrid','high','recall','xc60_t8_hv_battery_fire',
 'T8 högspänningsbatteri – brandrisk (kortslutning)',
 'Återkallelse NHTSA 25V-179 / Volvo R10312 (mars 2025); ca 73 000 bilar globalt, varav ca 8 000 i Sverige (bekräftat av Vi Bilägare, GP, Ny Teknik). Gäller bilar med LG-högspänningsmoduler byggda 3 juni 2019–30 nov 2021. Batterimoduler kan kortsluta internt vid fulladdat batteri och parkerad bil, med risk för termisk rusning och brand även när bilen är avstängd. Gäller T8 Recharge. Åtgärd: inspektion och vid behov byte av batterimodul samt övervakningsmjukvara – kostnadsfritt. Köparråd: kontrollera via VIN att recall är utförd; ägare uppmanades att inte ladda bilen förrän åtgärdat.',
 'https://www.vibilagare.se/nyheter/volvo-aterkallar-laddhybrider-risk-batteribrand'),

('Volvo','XC90',2020,2022,'Laddhybrid','high','recall','xc90_t8_hv_battery_fire',
 'T8 högspänningsbatteri – brandrisk (kortslutning)',
 'Samma återkallelse som XC60 (Volvo R10312, mars 2025, NHTSA 25V-179). T8 Recharge-batterimodul (LG) kan kortsluta vid fulladdning och orsaka brand. Åtgärd: inspektion/byte av modul + övervakningsmjukvara, gratis. Kontrollera VIN-status; be om dokumentation att åtgärden är gjord innan köp.',
 'https://www.vibilagare.se/nyheter/volvo-aterkallar-laddhybrider-risk-batteribrand'),

('Volvo','S60',2020,2022,'Laddhybrid','high','recall','s60_t8_hv_battery_fire',
 'T8 högspänningsbatteri – brandrisk (kortslutning)',
 'Samma återkallelse (R10312 / 25V-179, mars 2025). Gäller T8 Recharge. Risk för intern kortslutning/brand vid fulladdat parkerat batteri (LG-moduler byggda 2019–2021). Åtgärd gratis via verkstad. Kontrollera VIN och åtgärdsdokumentation.',
 'https://www.vibilagare.se/nyheter/volvo-aterkallar-laddhybrider-risk-batteribrand'),

('Volvo','V60',2020,2022,'Laddhybrid','high','recall','v60_t8_hv_battery_fire',
 'T8 högspänningsbatteri – brandrisk (kortslutning)',
 'Samma återkallelse (R10312 / 25V-179, mars 2025). Gäller V60 T8 Recharge. Risk för intern kortslutning/brand. Gratis åtgärd. Kontrollera VIN.',
 'https://www.vibilagare.se/nyheter/volvo-aterkallar-laddhybrider-risk-batteribrand'),

('Volvo','V90',2022,2022,'Laddhybrid','high','recall','v90_t8_hv_battery_fire',
 'T8 högspänningsbatteri – brandrisk (kortslutning)',
 'Samma återkallelse (R10312 / 25V-179, mars 2025); 2022 V90 T8 ingår. Risk för intern kortslutning/brand. Gratis åtgärd. Kontrollera VIN.',
 'https://www.vibilagare.se/nyheter/volvo-aterkallar-laddhybrider-risk-batteribrand'),

-- ========== T8 EFFEKTBORTFALL / ECM-MJUKVARA ==========
('Volvo','XC60',2022,2023,'Laddhybrid','high','recall','xc60_t8_power_loss_ecm',
 'T8 (18,8 kWh) effektbortfall – ECM-mjukvara',
 'Återkallelse NHTSA 22V-793 / Volvo R10198 (dec 2022), 15 674 bilar i USA. Gäller endast långdistans-T8 med 18,8 kWh-batteri. Felaktig mjukvarulogik sätter kylflödet till noll vid maxkylning, varvid förbränningsmotorn inte startar – förlust av framdrivning när HV-batteriet töms. Varning i display ("Propulsion System Service Required", därefter "sköldpadda" och hastighetsbegränsning). Åtgärd: gratis ECM-mjukvaruuppdatering (mjukvara utfärdad 17 okt 2022, även OTA). Köparråd: verifiera VIN.',
 'https://static.nhtsa.gov/odi/rcl/2022/RCAK-22V793-5392.pdf'),

('Volvo','XC90',2022,2023,'Laddhybrid','high','recall','xc90_t8_power_loss_ecm',
 'T8 (18,8 kWh) effektbortfall – ECM-mjukvara',
 'Samma återkallelse (22V-793 / R10198). Långdistans-T8 med 18,8 kWh-batteri. Mjukvarufel kan hindra förbränningsmotorn från att starta och ge effektbortfall när batteriet töms. Gratis mjukvaruåtgärd. Kontrollera VIN.',
 'https://static.nhtsa.gov/odi/rcl/2022/RCAK-22V793-5392.pdf'),

('Volvo','S60',2022,2023,'Laddhybrid','high','recall','s60_t8_power_loss_ecm',
 'T8 (18,8 kWh) effektbortfall – ECM-mjukvara',
 'Samma återkallelse (22V-793 / R10198). Gäller långdistans-T8. Gratis ECM-uppdatering. Kontrollera VIN.',
 'https://static.nhtsa.gov/odi/rcl/2022/RCAK-22V793-5392.pdf'),

('Volvo','V60',2022,2023,'Laddhybrid','high','recall','v60_t8_power_loss_ecm',
 'T8 (18,8 kWh) effektbortfall – ECM-mjukvara',
 'Samma återkallelse (22V-793 / R10198). Gäller långdistans-T8. Gratis ECM-uppdatering. Kontrollera VIN.',
 'https://static.nhtsa.gov/odi/rcl/2022/RCAK-22V793-5392.pdf'),

-- ========== BROMSBORTFALL VID REGENERERING (MJUKVARA) ==========
('Volvo','XC90',2020,2026,'Laddhybrid','high','recall','xc90_brake_loss_bcm_software',
 'Bromsbortfall i B-läge (mjukvara 3.5.14)',
 'Återkallelse NHTSA 25V-392 / Volvo R10329 (utfärdad 12 juni 2025), över 14 000 bilar i USA. Registrerad i EU via tyska KBA (ref. 15229R). Mjukvaruversion 3.5.14 i bromsstyrmodulen kan orsaka total förlust av bromsverkan efter utförsåkning i "B"-läge (PHEV) i minst 1 min 40 s utan pedaltryck. Felet härrör från OTA-åtgärden för backkamera-recallen (25V-282). Åtgärd: mjukvaruuppdatering (OTA eller verkstad), gratis. Köparråd: undvik B-läge tills uppdaterat; kontrollera att åtgärden är gjord.',
 'https://www.nhtsa.gov/press-releases/volvo-recall-urgent-brake-failure-warning-select-vehicles'),

('Volvo','XC60',2022,2026,'Laddhybrid','high','recall','xc60_brake_loss_bcm_software',
 'Bromsbortfall i B-läge (mjukvara 3.5.14)',
 'Samma återkallelse (25V-392 / R10329, KBA 15229R). Gäller XC60 PHEV. Risk för totalt bromsbortfall vid regenererande utförskörning i B-läge >1 min 40 s. Gratis mjukvaruåtgärd. Kontrollera VIN och undvik B-läge tills åtgärdat.',
 'https://www.nhtsa.gov/press-releases/volvo-recall-urgent-brake-failure-warning-select-vehicles'),

('Volvo','S60',2023,2025,'Laddhybrid','high','recall','s60_brake_loss_bcm_software',
 'Bromsbortfall i B-läge (mjukvara 3.5.14)',
 'Samma återkallelse (25V-392 / R10329). Gäller S60 PHEV 2023–2025. Gratis mjukvaruåtgärd. Kontrollera VIN.',
 'https://www.nhtsa.gov/press-releases/volvo-recall-urgent-brake-failure-warning-select-vehicles'),

('Volvo','V60',2024,2025,'Laddhybrid','high','recall','v60_brake_loss_bcm_software',
 'Bromsbortfall i B-läge (mjukvara 3.5.14)',
 'Samma återkallelse (25V-392 / R10329). Gäller V60 PHEV 2024–2025. Gratis mjukvaruåtgärd. Kontrollera VIN.',
 'https://www.nhtsa.gov/press-releases/volvo-recall-urgent-brake-failure-warning-select-vehicles'),

('Volvo','XC40',2023,2024,'El','high','recall','xc40_brake_loss_bcm_software',
 'Bromsbortfall vid One Pedal Drive (mjukvara 3.5.14)',
 'Samma återkallelse (25V-392 / R10329). Gäller XC40 BEV (elvariant) 2023–2024. Total förlust av bromsverkan möjlig vid One Pedal Drive i utförsbacke >1 min 40 s. Gratis mjukvaruåtgärd. Kontrollera VIN.',
 'https://www.nhtsa.gov/press-releases/volvo-recall-urgent-brake-failure-warning-select-vehicles'),

-- ========== BACKKAMERA VISAS EJ (FMVSS 111) ==========
('Volvo','XC60',2022,2025,NULL,'medium','recall','xc60_rearview_camera_blank',
 'Backkamera visar ingen bild (mjukvarukonflikt)',
 'Återkallelse (Volvo R10320/R10333; NHTSA 25V-282, utökad 25V-908 dec 2025); 413 151 bilar i USA totalt. Mjukvarukonflikt gör att kamerabilden ibland inte visas vid backning ("camera temporarily not available"). Park assist och bakre kollisionsvarning fungerar dock fortsatt. Åtgärd: mjukvaruuppdatering (OTA eller verkstad), gratis, planerad Q1 2026. Obs: den första åtgärden (25V-282) orsakade i sin tur bromsbuggen ovan. Kontrollera VIN.',
 'https://www.kbb.com/car-news/volvo-recalls-more-than-400000-vehicles-over-backup-cameras'),

('Volvo','XC40',2021,2025,NULL,'medium','recall','xc40_rearview_camera_blank',
 'Backkamera visar ingen bild (mjukvarukonflikt)',
 'Samma återkallelse (Google-infotainment; 413 151 bilar i USA). Kamerabild kan utebli vid backning. Gratis mjukvaruåtgärd, planerad Q1 2026. Kontrollera VIN.',
 'https://www.kbb.com/car-news/volvo-recalls-more-than-400000-vehicles-over-backup-cameras'),

('Volvo','XC90',2023,2024,NULL,'medium','recall','xc90_rearview_camera_blank',
 'Backkamera visar ingen bild (mjukvarukonflikt)',
 'Samma återkallelse. XC90 2023–2024 med Google-infotainment. Gratis mjukvaruåtgärd. Kontrollera VIN.',
 'https://www.kbb.com/car-news/volvo-recalls-more-than-400000-vehicles-over-backup-cameras'),

('Volvo','S60',2023,2025,NULL,'medium','recall','s60_rearview_camera_blank',
 'Backkamera visar ingen bild (mjukvarukonflikt)',
 'Samma återkallelse, bekräftad för S60 2023–2025 med Google-infotainment. Gratis mjukvaruåtgärd. Kontrollera VIN.',
 'https://www.kbb.com/car-news/volvo-recalls-more-than-400000-vehicles-over-backup-cameras'),

('Volvo','V60',2023,2025,NULL,'medium','recall','v60_rearview_camera_blank',
 'Backkamera visar ingen bild (mjukvarukonflikt)',
 'Samma återkallelse, bekräftad för V60 (inkl. V60 Cross Country) 2023–2025. Gratis mjukvaruåtgärd. Kontrollera VIN.',
 'https://www.kbb.com/car-news/volvo-recalls-more-than-400000-vehicles-over-backup-cameras'),

('Volvo','V90 Cross Country',2022,2025,NULL,'medium','recall','v90cc_rearview_camera_blank',
 'Backkamera visar ingen bild (mjukvarukonflikt)',
 'Samma återkallelse, bekräftad för V90 Cross Country 2022–2025 med Google-infotainment. Gratis mjukvaruåtgärd. Kontrollera VIN.',
 'https://www.kbb.com/car-news/volvo-recalls-more-than-400000-vehicles-over-backup-cameras'),

-- ========== PLASTINSUGSRÖR DIESEL (BRANDRISK) ==========
('Volvo','XC60',2014,2019,'Diesel','high','recall','xc60_diesel_intake_manifold_fire',
 'Plastinsugsrör kan smälta – brandrisk (2,0 diesel)',
 'Global återkallelse juli 2019, 507 000 bilar globalt, varav ca 86 000 i Sverige (bekräftat av Vi Bilägare, SVT Nyheter, Mest Motor). Kolavlagringar/läckande insugsventil höjer insugstemperaturen så att plastinsugsröret kan smälta/deformeras och i värsta fall antändas i motorrummet. Gäller 2,0 fyrcylindrig turbodiesel, byggd 2014–2019. Symptom: onormal lukt, effektbortfall, motorlampa. Åtgärd gratis. Köparråd: kräv bevis att recall är utförd; ovanlig lukt eller effektbortfall ska stoppa provkörning.',
 'https://www.vibilagare.se/nyheter/volvo-aterkallar-xc60-och-xc90-med-dieselmotor'),

('Volvo','V60',2014,2019,'Diesel','high','recall','v60_diesel_intake_manifold_fire',
 'Plastinsugsrör kan smälta – brandrisk (2,0 diesel)',
 'Samma återkallelse (juli 2019, ~86 000 bilar i Sverige totalt över modellerna). Gäller V60 med 2,0 diesel, byggd 2014–2019. Risk att plastinsugsröret smälter och antänds. Åtgärd gratis. Kontrollera VIN och åtgärdsdokumentation.',
 'https://www.vibilagare.se/nyheter/volvo-aterkallar-xc60-och-xc90-med-dieselmotor'),

('Volvo','V90',2016,2019,'Diesel','high','recall','v90_diesel_intake_manifold_fire',
 'Plastinsugsrör kan smälta – brandrisk (2,0 diesel)',
 'Samma återkallelse (juli 2019). Gäller V90 (inkl. Cross Country) med 2,0 diesel. Brandrisk vid smält insugsrör. Symptom: lukt, effektbortfall, motorlampa. Åtgärd gratis. Kontrollera VIN.',
 'https://www.vibilagare.se/nyheter/volvo-aterkallar-xc60-och-xc90-med-dieselmotor'),

('Volvo','XC90',2016,2019,'Diesel','high','recall','xc90_diesel_intake_manifold_fire',
 'Plastinsugsrör kan smälta – brandrisk (2,0 diesel)',
 'Samma återkallelse (juli 2019). Gäller XC90 med 2,0 fyrcylindrig diesel (ej äldre femcylindrig D5). Brandrisk. Åtgärd gratis. Kontrollera VIN.',
 'https://www.vibilagare.se/nyheter/volvo-aterkallar-xc60-och-xc90-med-dieselmotor'),

-- ========== BRÄNSLELEDNING DIESEL (LÄCKAGE) ==========
('Volvo','XC60',2015,2016,'Diesel','high','recall','xc60_diesel_fuel_line_leak',
 'Sprickande bränsleledning – läckagerisk (diesel)',
 'Återkallelse januari 2019, 219 000 bilar globalt, varav ca 37 000 i Sverige (bekräftat av Vi Bilägare, Ny Teknik, Mest Motor). Små sprickor invändigt i en bränsleledning i motorrummet kan i kombination med trycksatt system leda till bränsleläckage. Gäller dieselmodeller 2015–2016. Åtgärd gratis. Köparråd: kontrollera VIN; lukt av diesel i motorrummet ska undersökas.',
 'https://www.nyteknik.se/fordon/volvo-aterkallar-37000-bilar-i-sverige-6945536'),

-- ========== FRÄMRE SÄTESSKENA / SÄTESBULTAR ==========
('Volvo','XC60',2018,2019,NULL,'medium','recall','xc60_front_seat_rail_nuts',
 'Saknade flänsmuttrar i främre sätesskena',
 'Återkallelse NHTSA 19V220 / Volvo R19931 (2019). Muttrar i sätesskenans fläns kan saknas från fabrik, vilket kan påverka sätets struktur/position vid krock. Åtgärd: inspektion och montering av muttrar, gratis. Köparråd: kontrollera VIN att åtgärdat.',
 'https://www.kbb.com/volvo/xc60/2018/recall/'),

-- ========== BAKLUCKANS LYFTARMAR (KYLA) ==========
('Volvo','XC60',2018,2019,NULL,'medium','recall','xc60_tailgate_lift_arm_freeze',
 'Bakluckans lyftarmar kan lossna i kyla',
 'Återkallelse NHTSA 19V046 / Volvo R19931 (2019), 45 990 bilar. Under vissa förhållanden och kyla kan bakluckans lyftarmar frysa och lossna från bilen, med risk att kastas bakåt. Åtgärd: byte till förbättrade lyftarmar, gratis. Särskilt relevant för svenska vinterförhållanden. Kontrollera VIN.',
 'https://www.kbb.com/volvo/xc60/2018/recall/'),

-- ========== VCM/TELEMATIK (eCall GPS) ==========
('Volvo','XC60',2017,2019,NULL,'low','recall','xc60_vcm_ecall_gps',
 'VCM-mjukvara – GPS saknas vid nödsamtal',
 'Återkallelse (Volvo R39917, jan 2019). Mjukvarufel i Vehicle Connectivity Module (upptäckt av leverantören Actia Nordic AB) gör att telematik/On Call inte ger GPS-position till räddningstjänst vid nödläge. Gäller flera modeller 2017–2019 (XC90, S90, V60, V60CC, V90, V90CC, XC40, XC60). Åtgärd: mjukvara, gratis. Kontrollera VIN.',
 'https://www.thecarconnection.com/news/1120189_volvo-issues-recall-for-gps-equipped-models-over-lack-of-crash-location'),

-- ========== BROMSPEDAL LÖSA BULTAR ==========
('Volvo','XC60',2020,2020,NULL,'medium','recall','xc60_brake_pedal_loose_bolts',
 'Lösa bultar i bromspedal (monteringsfel)',
 'Återkallelse Volvo R10289 / NHTSA 24V-788 (kampanj utskickad dec 2024), 291 bilar (S60, V60, S90, XC60, XC90 årsmodell 2020). Felinställd monteringsstation under ca fem månader 2019 gav lösa bultar (pushrod-skruvled) i vissa bromspedaler, vilket kan ge instabil pedal och i värsta fall bromsbortfall. Åtgärd: åtdragning av bultar, gratis. Kontrollera VIN.',
 'https://www.noln.net/site-placement/latest-news/news/55239917/volvo-issues-recall-for-unstable-brake-pedals-in-2020-model-year-vehicles'),

-- ========== TAKLUCKANS TÄTNINGSLIST / VATTENLÄCKAGE ==========
('Volvo','XC60',2017,2024,NULL,'high','electrical','xc60_sunroof_seal_water_leak',
 'Takluckans tätningslist krymper – vatten dränker elektronik',
 'Känt fel (rapporterat av Vi Bilägare). En tätningslist runt takluckan krymper och lämnar en glipa; regnvatten rinner in och kan skada styrenheter/kablage på golvet under sätena. Symptom: strulande parkeringskameror, tända varningslampor (airbag, On Call), fuktiga golvmattor. I ett dokumenterat extremfall begärde Volvo-verkstad ~220 000 kr för reparation. Köparråd: kontrollera skarven i tätningslisten runt takluckan, känn efter fukt i mattor och lyft mattan över elektronikmodulerna.',
 'https://www.vibilagare.se/reportage/lackande-taklucka-vanligt-och-dyrt-fel-pa-manga-volvobilar'),

('Volvo','XC90',2015,2024,NULL,'high','electrical','xc90_sunroof_seal_water_leak',
 'Takluckans tätningslist krymper – vatten dränker elektronik',
 'Samma fel som XC60. Krympande tätningslist ger vatteninträngning som kan förstöra dyr elektronik. Symptom: kamerafel, varningslampor, fukt i kupén. Köparråd: inspektera tätningslistens skarv och känn efter fukt på golvet.',
 'https://carup.se/lacka-kan-ge-svara-skador-pa-flera-volvo-modeller/'),

('Volvo','V60',2018,2024,NULL,'high','electrical','v60_sunroof_seal_water_leak',
 'Takluckans tätningslist krymper – vatten dränker elektronik',
 'Samma fel. Gäller V60 med taklucka. Vatten kan skada styrenheter/kablage. Köparråd: kontrollera tätningslistens skarv och fukt i kupén.',
 'https://carup.se/lacka-kan-ge-svara-skador-pa-flera-volvo-modeller/'),

('Volvo','V60 Cross Country',2018,2024,NULL,'high','electrical','v60cc_sunroof_seal_water_leak',
 'Takluckans tätningslist krymper – vatten dränker elektronik',
 'Samma fel som övriga SPA-modeller. Vatteninträngning via taklucka kan förstöra elektronik. Köparråd: inspektera tätningslist och golv för fukt.',
 'https://carup.se/lacka-kan-ge-svara-skador-pa-flera-volvo-modeller/'),

('Volvo','V90',2016,2024,NULL,'high','electrical','v90_sunroof_seal_water_leak',
 'Takluckans tätningslist krymper – vatten dränker elektronik',
 'Samma fel. Gäller V90. Vatten kan skada elektronik på golvet. Köparråd: kontrollera tätningslistens skarv och känn efter fukt.',
 'https://carup.se/lacka-kan-ge-svara-skador-pa-flera-volvo-modeller/'),

('Volvo','V90 Cross Country',2017,2024,NULL,'high','electrical','v90cc_sunroof_seal_water_leak',
 'Takluckans tätningslist krymper – vatten dränker elektronik',
 'Samma fel. Gäller V90 Cross Country. Vatteninträngning via taklucka kan bli mycket dyr. Köparråd: inspektera tätningslist och golv för fukt.',
 'https://carup.se/lacka-kan-ge-svara-skador-pa-flera-volvo-modeller/'),

-- ========== AISIN 8-VÄXLAD AUTOMAT ==========
('Volvo','XC60',2018,2024,NULL,'medium','gearbox','xc60_aisin_8spd_shift',
 'Ryckig/hård växling – Aisin 8-växlad automat',
 'Vanligt klagomål på Aisin-automaten: ryckig eller hård växling, fördröjning vid växling, i värsta fall haveri av växellåda/ventilhus. Ofta hjälper mjukvaruuppdatering; i svåra fall byte av låda (dyrt, upp mot ~70 000 kr för renovering). Köparråd: provkör med både mjuk och kraftig gas, känn efter ryck/duns vid P-R-D och vid låga farter. Byt växellådsolja med intervall (ca 6 000 mil) trots att Volvo anger "livstidsolja". Kontrollera servicehistorik för oljebyte.',
 'https://www.autodoc.se/info/volvo-xc60-problem-med-baklucka-taklucka-och-andra-vanliga-fel'),

('Volvo','V60',2018,2024,NULL,'medium','gearbox','v60_aisin_8spd_shift',
 'Ryckig/hård växling – Aisin 8-växlad automat',
 'Samma Aisin-automat som XC60. Ryckig växling/fördröjning; risk för haveri. Mjukvaruuppdatering hjälper ofta. Köparråd: provkör noga och kontrollera oljebyteshistorik.',
 'https://www.swedespeed.com/threads/2021-xc60-d4-transmission-issues.663361/'),

('Volvo','S60',2018,2024,NULL,'medium','gearbox','s60_aisin_8spd_shift',
 'Ryckig/hård växling – Aisin 8-växlad automat',
 'Samma Aisin-automat. Känd B4-servouppdatering (O-ringar/ventilkåpa) har åtgärdat hårda växlingar på tidigare generationer; provkör och kontrollera oljebyte. Risk för dyrt lådbyte vid haveri.',
 'https://eeuroparts.com/blog/is-your-volvo-hard-shifting-you-should-read-this'),

-- ========== VÅT OLJEPUMPSREM ("WET BELT") ==========
('Volvo','XC40',2019,2024,'Bensin','high','engine','xc40_wet_belt_oil_pump',
 'Våt oljepumpsrem ("wet belt") kan brista',
 'Vissa senare bensinmotorer (t.ex. B4/B420T6 på CMA/SPA) driver oljepumpen med en rem som går i oljebadet. Remmen har inget fast bytesintervall och kan brista, vilket ger förlorat oljetryck och i värsta fall motorhaveri/motorbyte. Verkstäder erbjuder konvertering till kedjedrift (Volvo-kit, ca 1 000 EUR). Köparråd: ta reda på exakt motorkod; fråga verkstad om bilen har wet belt och begär inspektion. Notera: vissa varianter har kedja från fabrik.',
 'https://www.swedespeed.com/threads/xc40-b4-awd-petrol-scared-about-the-wet-belt-oil-pump.701030/'),

('Volvo','XC60',2019,2024,'Bensin','high','engine','xc60_wet_belt_oil_pump',
 'Våt oljepumpsrem ("wet belt") kan brista',
 'Samma konstruktion kan förekomma på XC60 mild-hybrid bensin (B-motorer). Oljepumpsrem i oljebad utan fast bytesintervall; brott ger oljetrycksförlust och motorskada. Köparråd: identifiera motorkod och låt verkstad kontrollera om wet belt finns; överväg kedjekonvertering.',
 'https://www.volvoforums.org.uk/forum/general-topics/general-volvo-and-motoring-discussions/5018932-vea-engines-do-they-have-a-wet-belt-oil-pump-drive'),

-- ========== EGR-KYLARE / DPF DIESEL ==========
('Volvo','XC60',2018,2020,'Diesel','medium','engine','xc60_egr_cooler_dpf',
 'EGR-kylare/ventil sätter igen (2,0 diesel)',
 'VEA-dieseln har känd svaghet: EGR-kylaren läcker/kolar igen, vilket ger felkod P0401/P2002, effektbortfall, "sotfilter fullt" och i värsta fall sprucket insugsrör (kopplat till brandrecall). DPF kan sätta igen vid mycket kortkörning. Reparation: byte EGR-kylare/ventil, ofta 12 000–25 000 kr. Köparråd: läs av felkoder, kontrollera regelbunden landsvägskörning och servicehistorik, se att mjukvara är uppdaterad.',
 'https://www.go-parts.com/garage/obd-p0401-volvo-s60-2013-2018-d4204t-2-0l'),

('Volvo','V60',2018,2020,'Diesel','medium','engine','v60_egr_cooler_dpf',
 'EGR-kylare/ventil sätter igen (2,0 diesel)',
 'Samma VEA-dieselproblem. P2002/"sotfilter fullt" efter misslyckad regenerering är vanligt vid mycket stadskörning. EGR-kylare en känd svaghet. Reparation dyr. Köparråd: felkodsläsning och kontroll av körmönster/service.',
 'https://checkabilen.se/blogg/volvo-v60-vanliga-fel-problem-kopguide-gen-1-2'),

-- ========== 12V-BATTERI / START-STOPP / ELEKTRONIK ==========
('Volvo','XC90',2015,2020,NULL,'medium','electrical','xc90_12v_battery_drain',
 '12V-batteriurladdning och start-stopp-fel',
 'Utbrett fel: snabb 12V-urladdning, "12V battery"-varning, start-stopp slutar fungera. Bilen drar mer ström i parkerat läge än normalt; svagt/urladdat AGM-batteri (och på T8 även extra startbatteri i bagageutrymmet) är vanlig orsak. Köparråd: kontrollera batteriålder/hälsa, se att mjukvara är uppdaterad, testa start-stopp vid provkörning.',
 'https://www.swedespeed.com/threads/12v-battery-error-strange-issue-on-my-xc-90.401953/'),

-- ========== INFOTAINMENT GOOGLE/ANDROID ==========
('Volvo','XC60',2022,2024,NULL,'medium','electrical','xc60_google_infotainment_freeze',
 'Google/Android-infotainment fryser/svart skärm',
 'Nyare Google-baserat system rapporteras frysa/bli svart, tappa backkamera, klimat och CarPlay – ibland kopplat till svag uppkoppling och mjukvaruuppdateringar. Omstart av skärm hjälper ofta. Köparråd: kontrollera att OTA-uppdateringar är gjorda; testa CarPlay/Android Auto och backkamera vid provkörning.',
 'https://espanol.consumerreports.org/cars/volvo/xc60/2022/reliability'),

-- ========== GASDÄMPARE BAKLUCKA ==========
('Volvo','XC60',2017,2024,NULL,'low','other','xc60_tailgate_gas_struts',
 'Svaga gasdämpare – bakluckan faller ner',
 'Gasdämparna/lyftarmarna tappar tryck över tid så att bakluckan sjunker eller inte hålls uppe, särskilt i kyla – en säkerhetsrisk. Byte är relativt billigt (ca 1 000 kr hos verkstad, bytas parvis). Köparråd: öppna bakluckan halvvägs och släpp – sjunker den inom 5–10 s behöver dämparna bytas.',
 'https://www.bildelarexpert.se/tips/vanliga-problem-med-bakluckan-pa-volvo-xc60-losningar-och-tips-3535/'),

-- ========== AC-KOMPRESSOR / FLÄKTMOTSTÅND ==========
('Volvo','XC60',2017,2024,NULL,'medium','other','xc60_ac_compressor_fault',
 'AC-system svaghet – kompressor/fläktmotstånd',
 'Återkommande svaghet på äldre exemplar: dålig kyleffekt, missljud från kompressor, fläkt fungerar bara på vissa hastigheter (defekt fläktmotstånd exponerat för fukt under instrumentbrädan) samt köldmedieläckage. Påfyllning 1 500–3 000 kr; kompressorhaveri 8 000–15 000 kr. Köparråd: testa AC på max kyla och alla fläkthastigheter vid provkörning.',
 'https://checkabilen.se/blogg/volvo-xc60-problem-7-vanliga-fel-reparationskostnader')
;


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
