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
('Volvo','S90',        2016,2027, 590000, 0.135, 1500,-3000, 74,68, 'Sedan-motsvarighet till V90 — svagare efterfrågan än kombi ger sämre andrahandsvärde.'),
('Volvo','V70',        2008,2016, 340000, 0.100, 1800,-1500, 78,70, 'Utgången sedan 2016 men Sveriges mest sålda BEGAGNADE bil enligt Kvdbil 2025 (52 865 st). Pris extremt känsligt för miltal/rost. Kontrollera EGR/DPF på D-motorer.'),
('Volvo','C40',        2022,2025, 500000, 0.150, 1300,-2000, 71,60, 'Elektrisk coupé-SUV på XC40-plattform. Utgår som eget namn 2025. Kontrollera batterihälsa.'),
('Volvo','EX30',       2023,2027, 380000, 0.150, 1300,-1800, 70,60, 'Volvos minsta/billigaste elbil. För ny för tillförlitlig andrahandsdata. Kontrollera batterihälsa.'),

-- TOYOTA
('Toyota','RAV4',      2018,2025, 440000, 0.110, 1400,-2400, 87,76, 'Hybrid (2019+) klart att föredra — lägre driftkostnad och bättre andrahandsvärde. PHEV kräver batterikontroll.'),
('Toyota','Corolla',   2018,2025, 310000, 0.105, 1500,-1800, 89,72, 'En av Toyotas mest tillförlitliga. Hybrid standard 2019+. Låga servicekostnader.'),
('Toyota','Yaris',     2020,2025, 240000, 0.105, 1200,-1400, 90,70, 'Gen 4 (2020+) stort kliv framåt. Hybrid standard. Enastående driftsäkerhet.'),
('Toyota','C-HR',      2016,2025, 330000, 0.115, 1300,-1900, 85,68, 'Polariserande design påverkar andrahandsvärdet negativt i vissa regioner. Hybrid tekniskt pålitlig.'),
('Toyota','Land Cruiser',2008,2021,750000,0.090,1400,-2000, 88,82, 'Extremt högt andrahandsvärde. Diesel D-4D känd för lång livslängd. Global efterfrågan håller priset uppe.'),
('Toyota','Yaris Cross',2021,2027, 310000, 0.108, 1300,-1600, 88,74, 'Höjd Yaris med SUV-utseende, hybrid standard. Stark efterfrågan i Sverige.'),
('Toyota','Corolla Cross',2022,2027,360000, 0.108, 1400,-1900, 88,73, 'SUV-version av Corolla, hybrid standard. Delar Corollas beprövade drivlina.'),
('Toyota','bZ4X',      2022,2027, 500000, 0.150, 1300,-1800, 78,60, 'Toyotas första renodlade elbil. 2022 kallades in för hjulbultsproblem — kontrollera åtgärd utförd.'),

-- VOLKSWAGEN
('Volkswagen','Golf',  2019,2025, 330000, 0.115, 1500,-2000, 72,67, 'Golf 8 (2019+) haft DSG/infotainment-problem. Golf 7 mer beprövad. Kontrollera DSG-uppdateringar.'),
('Volkswagen','Passat',2014,2023, 380000, 0.120, 1600,-2200, 71,64, 'Populär tjänstebil — många ex-leasing med hög miltal. GTE PHEV kräver batterikontroll.'),
('Volkswagen','Tiguan',2016,2025, 420000, 0.120, 1400,-2500, 70,68, 'Välsäljande familje-SUV. DSG-problem 2016–2018. Allspace 7-sits håller värdet något bättre.'),
('Volkswagen','T-Cross',2018,2025,260000, 0.118, 1300,-1600, 73,68, 'Snabbast säljande modell Blocket april 2025 — 44% borta inom en vecka.'),
('Volkswagen','ID.3',  2020,2025, 380000, 0.160, 1200,-1500, 65,58, 'Tidig mjukvara 2020–2021 hade allvarliga buggar. Kontrollera uppdateringar och batterihälsa (SoH).'),
('Volkswagen','ID.4',  2021,2025, 480000, 0.155, 1300,-2000, 67,60, 'Mer mogen elbil än ID.3. Kontrollera batterihälsa. Snabb depreciation gynnar köparen.'),
('Volkswagen','ID.7',  2023,2027, 600000, 0.150, 1500,-2200, 68,58, 'Stor elbils-sedan/liftback, ID-familjens flaggskepp. Kontrollera batterihälsa och mjukvaruversion.'),
('Volkswagen','T-Roc', 2018,2027, 320000, 0.120, 1400,-1800, 72,66, 'Kompakt SUV, delar plattform med Golf/T-Cross. DSG-uppdateringar värda att kontrollera tidiga exemplar.'),
('Volkswagen','Taigo', 2021,2027, 290000, 0.120, 1300,-1600, 72,64, 'Coupé-SUV, mindre etablerad i Sverige än T-Cross/T-Roc.'),

-- BMW
('BMW','3-serie',      2018,2025, 520000, 0.140, 1500,-3000, 62,70, 'G20 (2018+) mer pålitlig än F30. N20 4-cyl äldre motor — kontrollera timing chain. 20–30 kkr/år i service.'),
('BMW','5-serie',      2016,2025, 680000, 0.145, 1600,-3500, 60,68, 'G30 (2016+) fler elektronisk­problem. 530e PHEV kräver batterikontroll. Hög servicekostnad.'),
('BMW','X3',           2017,2025, 620000, 0.135, 1400,-3200, 63,70, 'G01 (2017+) stor förbättring. Stark efterfrågan. Kontrollera oljekonsumtion på B58 6-cyl.'),
('BMW','X5',           2018,2025, 900000, 0.140, 1400,-4000, 60,69, 'G05 (2018+). Komplex med höga underhålls­kostnader. xDrive45e PHEV kräver batterikontroll.'),
('BMW','X1',           2019,2027, 460000, 0.130, 1400,-2400, 65,66, 'Instegs-SUV. Lägre servicekostnad än 3-serie/X3 men samma elektronikkomplexitet.'),
('BMW','1-serie',      2019,2027, 340000, 0.135, 1400,-2000, 64,63, 'F40 (2019+) framhjulsdriven plattform, delad med X1/2-serie Active Tourer. Billigaste vägen in i BMW-märket.'),
('BMW','i4',           2022,2027, 650000, 0.155, 1500,-2600, 68,55, 'Elektrisk gran coupé på 4-seriens kaross. Snabb depreciation typisk för premium-elbilar. Kontrollera batterihälsa.'),
('BMW','i5',           2024,2027, 750000, 0.150, 1500,-3000, 68,58, 'Elektrisk 5-serie, för ny för tillförlitlig andrahandsdata.'),

-- AUDI
('Audi','A3',          2020,2027, 370000, 0.135, 1500,-2000, 66,68, 'Golf-konkurrent med Audi-premium. EA888-motorer delar konstruktion med VW/Skoda — samma kedjespännar­problem kan förekomma på tidiga exemplar.'),
('Audi','Q3',          2019,2027, 400000, 0.135, 1400,-2400, 65,68, 'Populär kompakt-SUV. Delar plattform med VW Tiguan/Skoda Karoq. Stark efterfrågan i Sverige håller andrahandsvärdet uppe.'),
('Audi','A4',          2019,2027, 470000, 0.140, 1500,-3000, 65,69, 'Direkt konkurrent till BMW 3-serie och Mercedes C-klass. Tidiga 2.0 TFSI (EA888 Gen1) kan ha kedjespännar­problem — kontrollera servicehistorik.'),
('Audi','A6',          2018,2027, 680000, 0.145, 1600,-3500, 64,68, 'Storsäljande tjänstebil. Komplex elektronik och luftfjädring på högre utrustningsnivåer ger högre servicekostnad. Stark efterfrågan andrahand.'),
('Audi','Q5',          2018,2027, 630000, 0.135, 1400,-3200, 66,70, 'Konkurrerar med BMW X3 och Mercedes GLC. Bra andrahandsvärde tack vare stark efterfrågan på premium-SUV i Sverige.'),
('Audi','Q2',          2017,2026, 350000, 0.135, 1300,-1900, 66,65, 'Minsta Audi-SUV:en, utgår ~2026. Mindre efterfrågad än Q3 — något svagare andrahandsvärde.'),
('Audi','Q4 e-tron',   2021,2027, 540000, 0.150, 1300,-2000, 68,60, 'Elektrisk Q3-motsvarighet på MEB-plattform, delar teknik med ID.4/Enyaq. Kontrollera batterihälsa.'),
('Audi','Q6 e-tron',   2024,2027, 700000, 0.140, 1400,-2200, 68,62, 'Ny PPE-plattform (2024+), för ny för tillförlitlig andrahandsdata.'),
('Audi','Q8 e-tron',   2019,2027, 820000, 0.155, 1400,-3000, 67,55, 'Namnbytt från "e-tron" 2023. Stor, tung premium-elbil — deprecierar snabbt.'),

-- MERCEDES-BENZ
('Mercedes-Benz','C-klass',2014,2025,560000,0.140,1500,-3000,63,68,'W205: kända rost­problem bakre fjädring, infotainment-fel. W206 (2021+) mer pålitlig. Höga servicekostnader.'),
('Mercedes-Benz','E-klass',2016,2025,720000,0.140,1600,-3500,62,67,'W213 (2016+). Komplex elektronik — undvik tidiga exemplar. 300de PHEV kräver batterikontroll.'),
('Mercedes-Benz','GLC', 2015,2025, 640000, 0.135, 1400,-3200, 63,69, 'X253 och C254 (2022+). Populär tjänstebils-SUV. 300e/300de PHEV kräver batterikontroll.'),
('Mercedes-Benz','GLE', 2019,2027, 950000, 0.140, 1500,-4000, 62,65, 'Stor premium-SUV, ofta tjänstebil. Komplex luftfjädring/elektronik. 350de PHEV kräver batterikontroll.'),
('Mercedes-Benz','CLA', 2019,2027, 460000, 0.140, 1400,-2400, 64,62, 'Kompakt coupé/sedan, delar plattform med A-klass. Populär bland yngre köpare.'),
('Mercedes-Benz','GLA', 2020,2027, 440000, 0.138, 1400,-2200, 64,62, 'Instegs-SUV, delar plattform med A-klass/CLA. Lägre servicekostnad än GLC.'),
('Mercedes-Benz','EQE', 2022,2027, 850000, 0.170, 1500,-3500, 65,48, 'Elektrisk E-klass-motsvarighet. Ovanligt brant depreciation, väldokumenterat för hela EQ-serien.'),
('Mercedes-Benz','EQB', 2021,2027, 580000, 0.165, 1300,-2200, 65,50, 'Elektrisk 7-sits kompakt-SUV på GLA-plattform. Samma branta EQ-depreciation.'),
('Mercedes-Benz','EQA', 2021,2027, 500000, 0.165, 1300,-2000, 65,50, 'Elektrisk GLA-motsvarighet, EQ-seriens instegsmodell. Kontrollera batterihälsa.'),

-- SKODA
('Skoda','Octavia',    2012,2025, 310000, 0.115, 1600,-1900, 76,67, 'En av marknadens bästa värde­bilar. DSG-uppdateringar viktiga. Combi-variant starkt att föredra.'),
('Skoda','Superb',     2015,2025, 380000, 0.120, 1600,-2200, 75,65, 'Enormt bagageutrymme. iV PHEV kräver batterikontroll. Låg profil ger bra priser begagnat.'),
('Skoda','Kodiaq',     2016,2025, 400000, 0.120, 1400,-2400, 74,66, '7-sits familje-SUV till bra pris. RS håller värdet bättre. DSG-problem tidiga exemplar.'),
('Skoda','Enyaq',      2021,2027, 500000, 0.145, 1300,-1900, 74,62, 'Skodas första renodlade elbil, delar MEB-plattform med VW ID.4/Audi Q4 e-tron till lägre pris.'),
('Skoda','Fabia',      2021,2027, 220000, 0.115, 1300,-1300, 77,62, 'Gen 4 (2021+). Prisvärd småbil, delar teknik med VW Polo/Seat Ibiza.'),
('Skoda','Kamiq',      2019,2027, 280000, 0.118, 1400,-1600, 76,64, 'Kompakt SUV, Skodas svar på VW T-Cross/Audi Q2.'),

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
('Kia','EV9',          2023,2027, 700000, 0.140, 1400,-2600, 76,62, 'Stor 3-rads elbil, för ny för tillförlitlig andrahandsdata. 7 års garanti hjälper andrahandsvärdet.'),
('Kia','Sorento',      2020,2027, 530000, 0.120, 1500,-2600, 78,65, '7-sits familje-SUV, hybrid/laddhybrid. 7 års garanti från ny.'),
('Kia','Stonic',       2021,2027, 270000, 0.118, 1300,-1500, 77,61, 'Liten SUV, prisvärt alternativ till Sportage. 7 års garanti från ny.'),

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
('Renault','Austral',  2022,2027, 400000, 0.130, 1400,-2100, 68,58, 'Ersätter Kadjar. För ny för tillförlitlig andrahandsdata.'),
('Renault','Captur',   2019,2027, 300000, 0.128, 1300,-1700, 68,58, 'Populär liten SUV. E-Tech laddhybrid 2020+ kräver batterikontroll.'),

-- PEUGEOT
('Peugeot','3008',     2016,2025, 340000, 0.130, 1400,-2000, 68,60, 'i-Cockpit. Hybrid4 PHEV kräver batterikontroll. Deprecierar snabbare än japanska/tyska konkurrenter.'),
('Peugeot','2008',     2019,2027, 310000, 0.130, 1300,-1700, 67,60, 'Kompakt SUV med i-Cockpit. e-2008 (el) — kontrollera batterihälsa.'),
('Peugeot','408',      2023,2027, 420000, 0.135, 1400,-2200, 67,58, 'Fastback/crossover, för ny för tillförlitlig andrahandsdata. Laddhybrid kräver batterikontroll.'),
('Peugeot','5008',     2017,2027, 430000, 0.135, 1500,-2200, 66,58, '7-sits familje-SUV. Hybrid4 PHEV kräver batterikontroll.'),

-- TESLA
('Tesla','Model 3',    2018,2025, 520000, 0.160, 1400,-1800, 68,62, 'Snabb depreciation (prissänkningar påverkar). Kontrollera batterihälsa och laddhistorik. Highland 2023+ är uppgradering.'),
('Tesla','Model Y',    2021,2025, 600000, 0.155, 1400,-2000, 69,63, 'Sveriges näst mest sålda bil 2024. Frekventa prissänkningar slår hårt på begagnatvärdet. Kontrollera karossfogningar.'),

-- SUBARU
('Subaru','Outback',   2014,2025, 420000, 0.110, 1400,-2200, 80,72, 'Populär i Sverige p.g.a. AWD. 39% av Blocket-annonserna säljs inom en vecka. Kontrollera boxer­motorns service.'),
('Subaru','Forester',  2019,2027, 430000, 0.108, 1400,-2200, 82,74, 'Samma AWD-profil och andrahandsvärde som Outback. Kontrollera boxer­motorns serviceintervall.'),

-- MINI
('Mini','Cooper',      2014,2024, 310000, 0.145, 1300,-1800, 62,63, 'Kända problem: termostat, kylsystem, timkedja (B38/B48). Hög servicekostnad. Stark märkes­premium.'),

-- SEAT
('Seat','Leon',        2020,2025, 290000, 0.118, 1400,-1800, 73,64, 'VW-grupp plattform. FR-variant mer efterfrågad. eHybrid kräver batterikontroll.'),
('Seat','Arona',       2018,2027, 270000, 0.120, 1300,-1600, 73,62, 'Kompakt SUV på samma plattform som VW T-Cross/Skoda Kamiq.'),

-- CUPRA
('Cupra','Leon',       2020,2027, 340000, 0.120, 1400,-1900, 72,63, 'Sportigare systermodell till Seat Leon. eHybrid kräver batterikontroll.'),
('Cupra','Formentor',  2020,2027, 410000, 0.125, 1400,-2000, 71,65, 'Cupras första unika modell. Stark försäljning i Sverige.'),
('Cupra','Born',       2021,2027, 440000, 0.148, 1300,-1700, 71,60, 'Elektrisk halvsyster till VW ID.3 på MEB-plattform. Kontrollera batterihälsa.'),

-- MAZDA
('Mazda','CX-5',       2017,2025, 380000, 0.112, 1400,-2200, 83,70, 'Stark tillförlitlighet. Ingen PHEV/hybrid. SkyActiv välbeprövad. Håller värdet bättre än snittet.'),
('Mazda','CX-60',      2022,2027, 540000, 0.125, 1400,-2600, 78,62, 'Större/mer komplex än CX-5 — raka 6-cyl diesel och laddhybrid. Tidiga PHEV haft mjukvaruproblem.'),

-- DACIA
('Dacia','Duster',     2018,2025, 210000, 0.115, 1300,-1300, 72,64, 'Exceptionellt lågt nypris. Enkel teknologi — lägre reparations­kostnader. Stigande popularitet i Sverige.'),
('Dacia','Sandero',    2021,2027, 190000, 0.105, 1300,-1000, 73,68, 'Sveriges billigaste nybil i sin klass. Enkel teknik, låga reparationskostnader.'),

-- PORSCHE
('Porsche','Cayenne',  2018,2027, 1100000,0.115, 1300,-5000, 72,78, 'Porsche håller andrahandsvärdet anmärkningsvärt väl. Höga servicekostnader (luftfjädring, bromsar).'),
('Porsche','Macan',    2018,2027, 800000, 0.115, 1300,-4200, 71,76, 'Instegs-SUV, delar plattform med Audi Q5. Starkt andrahandsvärde för märket.'),

-- LEXUS
('Lexus','NX',         2021,2027, 580000, 0.115, 1300,-2600, 88,70, 'Delar Toyotas rykte för tillförlitlighet. Litet återförsäljarnät i Sverige.'),

-- MG
('MG','MG4 Electric',  2022,2027, 350000, 0.150, 1300,-1600, 68,52, 'Nytt märke i Sverige, begränsad servicehistorik. Aggressiv nybilsprissättning pressar begagnatvärdet.'),
('MG','ZS EV',         2021,2027, 400000, 0.155, 1300,-1700, 68,50, 'Budget-elbil, samma märkesosäkerhet som MG4. Kontrollera batterihälsa.'),

-- LYNK & CO
('Lynk & Co','01',     2021,2027, 470000, 0.140, 1300,-2200, 70,55, 'Säljs huvudsakligen via abonnemang i Sverige — kontrollera om annonsen avser ägd bil eller abonnemangsöverlåtelse.'),

-- OPEL
('Opel','Mokka',       2021,2027, 310000, 0.130, 1300,-1700, 68,58, 'Gen 2 (2021+) på Stellantis-plattform. Mokka-e (el) kräver batterikontroll.'),
('Opel','Grandland',   2018,2027, 370000, 0.135, 1400,-2000, 67,55, 'Hette Grandland X till 2021. Laddhybrid kräver batterikontroll.'),

-- CITROËN
('Citroën','C4',       2021,2027, 320000, 0.135, 1300,-1700, 66,55, 'Crossover-hatchback. ë-C4 (el) — kontrollera batterihälsa.'),

-- POLESTAR
('Polestar','2',       2020,2027, 500000, 0.155, 1300,-1800, 70,58, 'Upprepade nypris­sänkningar har pressat andrahandsvärdet hårt. Kontrollera batterihälsa.'),
('Polestar','4',       2023,2027, 600000, 0.150, 1300,-2000, 72,60, 'Ovanlig lösning utan bakruta. För ny för tillförlitlig andrahandsdata.'),

-- ZEEKR
('Zeekr','X',          2024,2027, 400000, 0.150, 1300,-1600, 68,45, 'Helt nytt märke i Sverige (2024). Väldigt begränsad servicehistorik och återförsäljarnät.');


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


-- ─── TOYOTA — verifierade recalls/kända fel (Claude Deep Research + manuell
-- verifiering mot NHTSA och svensk press, 2026-08-13) ────────────────────────
-- Se data/toyota_known_issues_verified.sql för fullständig verifieringslogg.
-- En rad ('yaris_epb_ecu_software') hittades under verifieringen och saknades
-- i researchens ursprungliga output.

INSERT INTO known_issues
  (brand, model, year_from, year_to, fuel_type, severity, category, rule_id, title, description, source_url)
VALUES

-- ============ RAV4 (femte generationen, 2018–) ============

('Toyota','RAV4',2019,2020,NULL,'high','recall','rav4_denso_bransleumpump','Denso lågtrycksbränslepump kan sluta fungera – motorstopp',
'Del av den globala Denso-återkallelsen (NHTSA 20V-012, Toyota 20TA02/20TB02) som omfattade 3 356 494 fordon i USA och över 5,8 miljoner globalt. Bränslepumpens impeller är tillverkad av resin med för låg densitet som kan suga upp bränsle, svälla, spricka och deformeras. Pumpen kan då sluta fungera med varningslampor, ojämn gång och i värsta fall motorstopp under körning utan möjlighet att starta om. Gäller både 2.5 hybrid (A25A-FXS) och 2.5 bensin (A25A-FKS). Åtgärd: byte av pumpenhet gratis. Kontrollera i servicehistorik/VIN att åtgärden är utförd.',
'https://www.cars.com/research/toyota-rav4-2019/recalls/'),

('Toyota','RAV4',2019,2020,NULL,'high','recall','rav4_framre_lankarm_spricka','Sprickor i främre nedre länkarmar kan lossna',
'Bekräftad återkallelse (NHTSA 20V-286, Toyota 20TB08/20TA08), ca 9 500 bilar. Främre nedre länkarmar tillverkade av en svagare stålsats (leverantörsproblem, "improper production conditions") kan spricka och i värsta fall lossna från hjulupphängningen, med förlorad kontroll som följd. Åtgärd: byte av båda främre nedre länkarmarna gratis (kampanj startad 10 aug 2020). Kontrollera VIN-status.',
'https://static.nhtsa.gov/odi/rcl/2020/RCMN-20V286-4079.pdf'),

('Toyota','RAV4',2019,2020,NULL,'high','engine','rav4_motorblock_porositet','Porositet i motorblock (2.5 A25A) – kylvätskeläckage och motorskada',
'Bekräftad återkallelse (NHTSA 20V-064, Toyota 20TA04), 44 191 fordon (Toyota + Lexus). Porositet i gjutningen av 2.5-liters fyrcylindriga motorer kan orsaka sprickor som läcker kylvätska internt/externt. Kan leda till överhettning, motorstopp (bensinversion) och i värsta fall mekanisk motorskada med oljeläckage och brandrisk. Åtgärd: inspektion och vid behov byte av motorblock/motor gratis (kampanj startad 3 april 2020). Symptom att kontrollera: kylvätskeförlust, vit rök, överhettning. Kontrollera VIN.',
'https://www.greencarreports.com/news/1127163_some-2019-2020-toyota-and-lexus-hybrids-recalled-for-coolant-leak-concern'),

('Toyota','RAV4',2019,2019,'Hybrid','high','recall','rav4_bromsservopump','Bromsservopump kan sluta fungera – förlorad bromsassistans',
'NHTSA 19V-544 (Toyota K0L/K1L), ca 6 925 bilar totalt över flera modeller (RAV4 Hybrid, Corolla Hybrid, Prius). Felaktigt formad plastborsthållare i bromsservopumpens motor kan fastna så att pumpen slutar fungera. Bromsassistansen kan då försvinna efter flera inbromsningar och ESC/VSC avaktiveras, med längre bromssträcka. Gäller vissa 2019 RAV4 Hybrid tillverkade april–maj 2019. Flera varningslampor tänds vid fel. Åtgärd: inspektion och vid behov byte av pump gratis.',
'https://static.nhtsa.gov/odi/rcl/2019/RCONL-19V544-4869.pdf'),

('Toyota','RAV4',2019,2020,'Hybrid','medium','other','rav4_hybrid_tank_fyllning','Går inte att fylla tanken full (hybridens saddle-tank)',
'Konstruktionsfel i bränsletankens form på RAV4 Hybrid (nytt längsgående saddle-design från 2019) gör att den nominellt 55-liters tanken ofta bara tar ca 30–40 liter innan pistolen slår av, vilket kapar räckvidden med upp till ca 200 km. Toyota erkände felet och tog fram ett kundserviceprogram: 2019-bilar får ny tank plus ny givarenhet, vissa 2020 får ny givarenhet. Vid köp: fråga om tanken/givaren bytts och testa att fylla full. Ej säkerhetskritiskt men påverkar bruksvärde.',
'https://www.torquenews.com/1083/toyota-rav4-hybrid-fuel-tank-issue-fixed-customer-support-program'),

('Toyota','RAV4',2021,2022,'Laddhybrid','high','recall','rav4_prime_dcdc_brand','Laddhybrid: DC/DC-omvandlare kan kortsluta – brandrisk vid laddning',
'Bekräftad återkallelse (NHTSA 23V-478, Toyota 23TB07/23LB01), 43 442 RAV4 Prime/Plug-in Hybrid och Lexus NX450h+ tillverkade 25 nov 2019–27 maj 2022. Likriktarmodulen i DC/DC-omvandlaren kan ha skadats i produktion och kortsluta, vilket genererar värme och brandrisk (igensatt breather-plugg kan smälta aluminiumhöljet). Ägare uppmanades att inte ladda när temperaturen är under 5 grader C tills omvandlaren bytts. Åtgärd: byte av DC/DC-omvandlare gratis (utskick 29 dec 2023). Mycket relevant i svenskt klimat – kontrollera att åtgärden är utförd.',
'https://static.nhtsa.gov/odi/rcl/2023/RCAK-23V478-7262.pdf'),

('Toyota','RAV4',2021,2021,'Laddhybrid','medium','recall','rav4_prime_kallstart_stall','Laddhybrid: mjukvara kan stänga av drivlinan i EV-läge vid kyla',
'NHTSA-återkallelse, ca 16 000 st 2021 RAV4 Prime (exakt antal bör VIN-verifieras). Mjukvaran som styr batteriets laddnivå kan vid kall väderlek, när batteriet tömts till viss nivå i EV-läge och man accelererar hårt, oväntat stänga av batteriet och orsaka effektförlust – risk vid högre hastigheter. En kort varning visas innan. Åtgärd: mjukvaruuppdatering hos dealer (ej OTA). Kontrollera att uppdateringen är gjord.',
'https://www.greencarreports.com/news/1138775_toyota-rav4-prime-plug-in-hybrid-recalled-over-stalling-issue'),

('Toyota','RAV4',2019,2020,NULL,'medium','recall','rav4_styrservo_vatten','Vatten i styrväxel kan ge förlorad servostyrning',
'NHTSA-återkallelse (Toyota 20TB11/20TA11). Vatten kan tränga in genom locket på styrväxeln (elektrisk servostyrning EPS) och orsaka förlust av servoassistans, vilket ökar styrkraften vid låga hastigheter. Gäller vissa 2019-2020 RAV4 och 2020 RAV4 Hybrid. Åtgärd: byte av styrväxel gratis. Kontrollera VIN och känn efter tung/ojämn styrning vid provkörning.',
'https://www.cars.com/research/toyota-rav4-2020/recalls/'),

('Toyota','RAV4',2019,2019,NULL,'low','recall','rav4_backkamera','Backkamera aktiveras inte alltid vid backning',
'NHTSA-återkallelse, ca 14 215 st 2019 RAV4/RAV4 Hybrid tillverkade maj–juli 2019. Skadad elkontakt gör att backkameran inte alltid tänds vid backläge (bryter mot FMVSS 111). Åtgärd: inspektion och vid behov byte av ljud-/displayenhet gratis. Kontrollera att kameran fungerar vid provkörning.',
'https://www.consumerreports.org/car-recalls-defects/new-toyota-rav4-recalled-for-faulty-rearview-camera'),

('Toyota','RAV4',2019,2025,'Hybrid','low','electrical','rav4_hybrid_12v_urladdning','Svagt/urladdat 12V-startbatteri vid korta resor',
'Hybridens lilla 12V-batteri laddas bara i READY-läge och har begränsad laddeffekt för bränslebesparingens skull. Vid mycket korta resor, långa stillestandsperioder eller strömmande tillbehör (dashcam) kan det laddas ur så att bilen inte startar. Inte ett fabriksfel i strikt mening men vanligt. Kontrollera batteriets ålder och skick; åtgärd är billig (byte av 12V-batteri).',
'https://www.whocanfixmycar.com/advice/common-problems-with-the-toyota-corolla'),

('Toyota','RAV4',2019,2025,'Hybrid','low','gearbox','rav4_ecvt_inverter','Hybridväxel (eCVT): sällsynta inverter-/lagerfel vid höga mil',
'Toyotas eCVT/power-split-transaxel saknar rem och är mycket tålig (klarar ofta 30 000–50 000 mil). Ovanliga men förekommande fel vid höga mil eller mycket bogsering: vinande/tjutande ljud från slitet MG2-lager, samt överhettning om inverterns separata elektriska kylvattenpump havererar (kan ge limp mode och felkoder som P0A93/P0A78). Byte av kylvätska och periodiskt oljebyte i transaxeln förlänger livslängden. Vid provkörning: lyssna efter tjut och kontrollera avsaknad av hybridvarningar.',
'https://www.cherishyourcar.com/toyota-e-cvt-problems/'),

-- ============ Corolla (tolfte generationen, 2018–) ============

('Toyota','Corolla',2019,2020,NULL,'high','recall','corolla_denso_bransleumpump','Denso lågtrycksbränslepump kan sluta fungera – motorstopp',
'Corolla (2018–2020) och Corolla Hatchback (2019) ingår i den globala Denso-återkallelsen (Toyota 20TB02, del av NHTSA 20V-012 som totalt omfattade över 5,8 miljoner fordon globalt). Bränslepumpens resin-impeller kan suga upp bränsle, svälla och spricka så att pumpen slutar fungera – varningslampor, ojämn gång och motorstopp under körning. Berör 1.8 hybrid (2ZR-FXE), 2.0 (M20A) och bensinvarianter. Åtgärd: byte av pumpenhet gratis. Kontrollera VIN/servicehistorik.',
'https://www.toyotanation.com/threads/toyotas-fuel-pump-recall-list-thus-far.1687811/'),

('Toyota','Corolla',2020,2020,'Hybrid','high','recall','corolla_bromsservopump','Bromsservopump kan sluta fungera – förlorad bromsassistans',
'NHTSA 19V-544 (Toyota K0L). Vissa 2020 Corolla Hybrid ingår tillsammans med RAV4 Hybrid/Prius. Felaktigt tillverkad bromsservopump kan sluta fungera, varvid bromsassistansen kan försvinna efter flera inbromsningar och VSC/ESC avaktiveras. Flera varningslampor och/eller ljudsignaler visas vid fel. Åtgärd: inspektion och vid behov byte av pump gratis. Kontrollera VIN.',
'https://toyota.oemdtc.com/442/recall-k0l-potential-loss-of-power-brake-assist-2019-2020-toyota'),

('Toyota','Corolla',2023,2024,NULL,'high','recall','corolla_styraxel_spricka','Mellanaxel i styrningen kan spricka och lossna',
'Bekräftad återkallelse (NHTSA 24V-878, Toyota 24TB13/24TA13), exakt 8 057 st 2023-2024 Corolla/Corolla Hybrid tillverkade juli–sep 2023. Övre universalknuten på styrningens mellanaxel (leverantör JTEKT) kan ha sprickor från tillverkningen. Normala styrutslag förvärrar dem och kan leda till onormala vibrationer, glapp och i värsta fall att axeln lossnar med förlorad styrkontroll. Symptom: onormalt ljud, vibration och glapp i styrningen. Åtgärd: byte av mellanaxel gratis, tar ca 1 timme (utskick 17 jan 2025). Kontrollera VIN.',
'https://static.nhtsa.gov/odi/rcl/2024/RCMN-24V878-9383.pdf'),

('Toyota','Corolla',2023,2023,NULL,'medium','recall','corolla_spiralkabel_krockkudde','Spiralkabel i rattstången kan avaktivera förarkrockkudden',
'NHTSA-återkallelse (kopplad till 23V-480). En elektrisk anslutning i rattstångens spiralkabel (klockfjäder) kan vara otillräckligt svetsad och lossna, vilket avaktiverar förarens krockkudde (bryter mot FMVSS 208). Gäller vissa 2023 Corolla m.fl. Symptom: tänd krockkuddelampa. Åtgärd: inspektion och byte av spiralkabel vid behov gratis. Kontrollera att krockkuddelampan är släckt.',
'https://www.cars.com/research/toyota-corolla-2023/recalls/'),

('Toyota','Corolla',2019,2025,'Hybrid','low','electrical','corolla_hybrid_12v_urladdning','Svagt/urladdat 12V-batteri vid korta resor',
'Enligt What Car? tillhörde 12V-batteriet de vanligaste problemen för Corolla-ägare. Hybridernas 12V-batteri laddas bara i READY-läge och med begränsad effekt, vilket vid korta resor eller långa stillestånd kan ge urladdning och startproblem. Billig åtgärd (byte av 12V-batteri). Kontrollera batteriets ålder/skick vid köp.',
'https://www.whatcar.com/toyota/corolla/hatchback/used-review/n20451/reliability'),

('Toyota','Corolla',2019,2025,NULL,'low','engine','corolla_evap_check_engine','EVAP-relaterad felkod / tänd motorlampa',
'Återkommande men lindrigt: en fastnad purge-ventil eller igensatt kolfilter (EVAP-systemet för bränsleångor) kan tända motorlampan; åtgärd varierar från tanklock till kolfilter. Diagnos via felkodsläsning och kontroll av EVAP-slangar/ventiler. Kontrollera att inga felkoder ligger och att motorlampan är släckt.',
'https://www.whocanfixmycar.com/advice/common-problems-with-the-toyota-corolla'),

-- ============ Yaris (fjärde generationen, 2020–) ============

('Toyota','Yaris',2020,2020,'Hybrid','high','recall','yaris_hybrid_failsafe','Hybridsystem kan misslyckas gå i nödläge vid slirning',
'Europeisk/global återkallelse (Toyota 22SMD-092), 47 413 Yaris HEV (modellkod MXPH11) tillverkade 7 juli–13 nov 2020. Felaktig programmering gör att bilen kanske inte går in i fail-safe/nödkörläge vid tillfällig slirning i hybridväxeln, vilket ökar olycksrisken (effektförlust). Gäller 1.5 hybrid (M15A-FXE). Åtgärd: mjukvaruuppdatering. Kontrollera VIN/servicehistorik.',
'https://car-recalls.eu/recall/toyota-yaris-hev-2020-fail-safe-driving-mode/'),

('Toyota','Yaris',2020,2021,'Hybrid','high','recall','yaris_epb_ecu_software','Elektronisk parkeringsbroms kan sluta fungera (ECU-mjukvara)',
'Europeisk återkallelse (tillverkningsperiod juli 2020–april 2021), bekräftad av Vi Bilägare: ca 140 000 bilar i Europa, varav ca 4 000 i Sverige. Felaktig mjukvara i motorstyrenheten (ECU) på Yaris Hybrid kan göra att den elektroniska parkeringsbromsen inte går att lägga i eller inte går att lossa. Varningslampor tänds på instrumentpanelen. Den vanliga färdbromsen påverkas inte. Åtgärd: mjukvaruuppdatering hos auktoriserad verkstad, gratis. Kontrollera att åtgärden är utförd.',
'https://www.vibilagare.se/nyheter/toyota-yaris-aterkallas-parkeringsbroms-kan-sluta-fungera'),

('Toyota','Yaris',2020,2021,NULL,'medium','recall','yaris_radarsensor_init','Radarsensor kan vara felinitierad – nödbroms/ACC kanske ej känner av fordon',
'Europeisk återkallelse (april 2022). Radarsensorns initialisering kan ha blivit felaktig så att den inte upptäcker framförvarande fordon, vilket ökar kollisionsrisken (pre-collision/adaptiv farthållare). Gäller Yaris 2020-2021. Åtgärd: ominitiering/uppdatering hos verkstad. Kontrollera att åtgärden är utförd.',
'https://car-recalls.eu/common-problems/toyota/yaris/'),

('Toyota','Yaris',2020,2021,NULL,'low','electrical','yaris_ecall','Nödanropssystem (eCall) kan sluta fungera',
'Europeisk återkallelse (nov 2021). eCall-systemet kanske inte fungerar när det behövs, vilket hindrar automatiskt nödanrop vid olycka. Gäller Yaris tillverkade 16 juli 2020–26 mars 2021. Åtgärd hos verkstad. Ej körkritiskt men säkerhetsrelaterat.',
'https://car-recalls.eu/common-problems/toyota/yaris/'),

('Toyota','Yaris',2020,2021,NULL,'medium','recall','yaris_baltesfaste_skarp_kant','Skarp kant på bakre bältesfäste kan skada bältet',
'Återkallelse (januari 2021): en skarp kant på bakre säkerhetsbältets fäste/beslag kan skada bältesväven och minska dess effektivitet i en kollision. Gäller Yaris 2020-2021. Åtgärd hos verkstad. Kontrollera VIN/servicehistorik.',
'https://www.clickmechanic.com/blog/common-problems-with-toyota-yaris/'),

('Toyota','Yaris',2020,2025,'Hybrid','medium','electrical','yaris_hybrid_12v_urladdning','Svagt/urladdat 12V-batteri – vanligaste felet',
'What Car? tillförlitlighetsundersökning: 20 procent av Yaris Hybrid-ägarna rapporterade fel, varav 15 procent gällde 12V-batteriet (många bilar blev ostartbara; 60 procent åtgärdades på en dag eller mindre). Batteriet laddas ur vid korta resor eller långa stillestånd. Även rapporter om att varningslampor för hybridsystemet tänds och kräver verkstadsbesök. Kontrollera batteriets skick och läs av felkoder vid köp.',
'https://www.whatcar.com/toyota/yaris/hatchback/used-review/n24498/reliability'),

-- ============ C-HR (första gen 2016–2023, andra gen 2023–) ============

('Toyota','C-HR',2018,2018,NULL,'medium','recall','chr_elektronisk_handbroms','Elektronisk parkeringsbroms kan sluta fungera',
'Bekräftad återkallelse (Toyota H0W), ca 28 600 st 2018 C-HR. Den elektroniska parkeringsbromsen (EPB) kan sluta fungera korrekt – kan misslyckas att lossa efter att den lagts i, eller inte gå att lägga i. Risk för rullning om bilen parkeras i backe utan P-läge. Åtgärd: mjukvaruuppdatering av skid control-ECU gratis (påbörjades 30 nov 2017). Kontrollera funktion vid provkörning.',
'https://www.carcomplaints.com/news/2017/toyota-recalls-c-hr-parking-brake-problems.shtml'),

('Toyota','C-HR',2019,2020,NULL,'medium','recall','chr_bakre_balteslas','Bakre bältets låsmekanism kanske inte låser',
'NHTSA-återkallelse (Toyota 19TB22/19TA22). Bakre säkerhetsbältenas väv-sensorlås (dual-mode) kanske inte låser som avsett vid multipla islag i en krock, vilket minskar skyddet. Gäller vissa 2019-2020 C-HR och 2020 Corolla. Åtgärd: inspektion och byte av bältesenheter vid behov gratis (påbörjades 7 feb 2020). Kontrollera VIN.',
'https://www.cars.com/research/toyota-c_hr/recalls/'),

('Toyota','C-HR',2017,2020,'Hybrid','medium','electrical','chr_12v_batteri_elektronik','Svagt 12V-batteri och elektronik-/startfel (hybrid)',
'Ägarforum och verkstadskällor rapporterar att C-HR hybrids 12V-batteri ofta laddas ur tidigare än väntat (ofta 3 000–5 000 mil), med startproblem och elektronikfel. Även rapporter om varningar/startproblem kopplade till givare (BSM/PCS) och felkoder. På högmilade exemplar bör även traktionsbatteriets hälsa kontrolleras (felkod P0A80 = byt hybridbatteri). Kontrollera 12V-batteriets skick och läs av felkoder vid köp.',
'https://www.autodoc.co.uk/info/problems-with-the-toyota-c-hr'),

-- ============ Land Cruiser (J150/"Prado", diesel D-4D, 2010–2021/2022) ============

('Toyota','Land Cruiser',2010,2013,'Diesel','high','engine','landcruiser_1kd_spruckna_kolvar','3.0 D-4D (1KD-FTV): spruckna/smälta kolvar',
'Euro IV-versioner av 3.0 D-4D (1KD-FTV) har ett allvarligt problem med spruckna kolvar, typiskt vid ca 10 000–15 000 mil. Värst på bilar med kolvrevision 13101-30150 (juni 2009–dec 2013). Symptom: svart rök, kraftigt metalliskt knackljud (särskilt kallstart), högt vevhustryck, effektförlust och hög oljeförbrukning. Toyota införde omformade kolvar och nya oljemunstycken 2014. Reparation är mycket dyr (motorrenovering, indikativt ca 25 000–40 000 kr enligt specialistkällor — ej officiell prisuppgift). Vid köp: lyssna efter kallstartsknack, kontrollera blow-by och avgasrök.',
'https://www.motorreviewer.com/engine.php?engine_id=114'),

('Toyota','Land Cruiser',2010,2015,'Diesel','high','engine','landcruiser_1kd_injektorer','3.0 D-4D (1KD-FTV): injektorfel och brända kopparbrickor',
'Injektorernas kopparsäten/brickor kan brinna och läcka; injektorer kan fela runt ca 12 000 mil även med bra bränsle. Symptom: vit rök, ojämn tomgång, hög bränsleförbrukning och knack vid kyla. Trasiga injektorer är dessutom en vanlig underliggande orsak till kolvskador. Byte av injektorset är dyrt. Vid köp: begär kvitton på genuina, kodade injektorer och kontrollera rök/tomgång.',
'https://www.motorreviewer.com/engine.php?engine_id=114'),

('Toyota','Land Cruiser',2010,2015,'Diesel','medium','engine','landcruiser_1kd_egr_sot','3.0 D-4D (1KD-FTV): sotigt EGR/insug',
'EGR-systemet och insugsgrenröret sotar igen med kolavlagringar; ger effektförlust, svart rök under last, dålig bränsleekonomi och ojämn tomgång. Rekommenderad rengöring var ca 6 000 mil för att undvika dyra skador på insug/turbo. Vid köp: kontrollera servicehistorik för EGR-/insugsrengöring och kör på motorlampa/felkoder.',
'https://www.enginefinder.co.za/blog/problems/toyota-1kd-ftv-problems/'),

('Toyota','Land Cruiser',2015,2021,'Diesel','high','engine','landcruiser_1gd_dpf_oljespadning','2.8 D-4D (1GD-FTV): igensatt DPF och oljespädning',
'2.8 D-4D (1GD-FTV) har ett känt problem med igensatt partikelfilter (DPF) och hög oljeförbrukning/oljespädning redan från låga mil. Vid misslyckade regenerationer (mycket kortkörning) spolas oförbränd diesel ner i oljetråget: oljenivån STIGER över max och luktar diesel, och utspädd olja kan i förlängningen förstöra lager och motorn. Toyota släppte en ECU-mjukvaruuppdatering/kundserviceprogram (från 2018/MY2019) för att åtgärda DPF och oljespädning. Symptom att kontrollera: stigande oljenivå, diesellukt i oljan, DPF-varning/limp mode, felkoder P2002/P2463/P242F. Kräver regelbunden landsvägskörning. Bekräfta att mjukvaruuppdateringen är utförd. DPF-byte är dyrt.',
'https://www.motorreviewer.com/engine.php?engine_id=126'),

('Toyota','Land Cruiser',2016,2021,'Diesel','medium','engine','landcruiser_1gd_adblue_scr','2.8 D-4D (1GD-FTV): AdBlue/SCR-fel',
'Den europeiska 2.8 D-4D (1GD-FTV) från 2016 var Toyotas första SCR/AdBlue-system för att klara Euro 6. AdBlue kan kristallisera i tank, nivågivare, doseringspump och injektor. Vanliga fel: "Check exhaust system"-varning, felaktig tanknivå, NOx-sensorfel, doseringspump/tankvärmare som havererar, samt nedräkning "no start in X km". Reparation kan bli dyr (ny tankenhet). Vid köp: kontrollera att inga avgas-/AdBlue-varningar finns och att systemet är intakt (ej manipulerat/"deletat").',
'https://www.greencarcongress.com/2015/09/20150922-toyota.html'),

('Toyota','Land Cruiser',2010,2019,NULL,'medium','recall','landcruiser_baltesgivare_krockkudde','Bältesgivare kan avaktivera passagerarkrockkuddar',
'Bekräftad återkallelse (Toyota Interim J15/Remedy J05), gäller 2008-2019 Land Cruiser och Lexus LX 570. Kablaget till passagerarplatsens bältesspänningssensor kan brytas med tiden och avaktivera främre passagerarkrockkudde, knäkrockkudde och sidokrockkudde. Symptom: tänd krockkuddelampa eller "passenger airbag OFF". Åtgärd: modifiering/byte av passagerarbälte gratis (påbörjades 11 feb 2019). Gäller både bensin och diesel. Kontrollera VIN.',
'https://www.cars.com/research/toyota-land_cruiser/recalls/')
;


-- ─── VOLKSWAGEN — verifierade recalls/kända fel (Claude Deep Research +
-- manuell verifiering mot NHTSA/KBA/DVSA, 2026-08-13) ─────────────────────────
-- Se data/vw_known_issues_verified.sql för fullständig verifieringslogg.
-- fuel_type normaliserad till samma versalkonvention som resten av
-- databasen ('bensin'->'Bensin' osv, researchens råa output var gemener).

INSERT INTO known_issues
  (brand, model, year_from, year_to, fuel_type, severity, category, rule_id, title, description, source_url)
VALUES

-- ============ Golf (åttonde generationen, 2019–) ============

('Volkswagen','Golf',2020,2026,'Bensin','high','gearbox','golf8_dq200_mechatronic_clutch','DQ200 torrkoppling: mekatronik- och kopplingsfel',
'Golf 8 med 1.0 TSI och 1.5 TSI/eTSI använder nästan uteslutande den 7-stegs DSG DQ200 (0CW) med torrkoppling. Vanliga symptom är ryckiga växlingar vid låg fart, skakning vid igångkörning, fördröjd gasrespons och sporadiskt nödläge (limp mode). Roten är ofta mekatronikens tryckackumulator som spricker av värmecykling, samt kopplingsslitage. Reparation av mekatronik hos specialist ca 8 000–15 000 kr, komplett byte hos VW ca 25 000–35 000 kr. VW anger oljan som livstidsfylld men byte var 60 000 km sänker risken markant. Köparråd: provkör länge i köbilstrafik och kräv historik på DSG-service.',
'https://www.carchecker.pro/reports/vw_golf_mk8_1.5_etsi.html'),

('Volkswagen','Golf',2015,2019,NULL,'high','recall','golf_rear_coil_spring_42j5','Återkallelse: bakre spiralfjäder kan brista (42J5)',
'Bekräftad återkallelse (NHTSA 19V-188, VW 42J5, start 12 april 2019) för att bakre spiralfjädrar kan brista i förtid pga fjädrar med material utanför specifikation. En bruten fjäder kan skada bakdäcket och leda till förlorad kontroll. Omfattar 2015–2019 Golf, 2017–2019 Golf Sportwagen, 2019 Jetta och 2018–2019 Tiguan. Åtgärd: byte av bakaxelns spiralfjädrar utan kostnad. Köparråd: kontrollera att åtgärden utförts.',
'https://static.nhtsa.gov/odi/rcl/2019/RCRIT-19V188-9241.pdf'),

('Volkswagen','Golf',2020,2020,NULL,'high','recall','golf8_brake_pedal_weld','Återkallelse: bromspedal kan brista (svetsfog)',
'Bekräftad KBA-återkallelse för bromspedal med defekt svetsfog: pedalplattan kan deformeras eller helt lossna, vilket försämrar bromsverkan. Gäller 2020 års modell med DSG-automatlåda, tillverkade 26 juni–31 augusti 2020. Ursprungligen ca 38 100 Golf/Tiguan/Touran/T-Roc, senare utökat till totalt 63 328 Audi/Seat/Skoda/VW-fordon. Berörda bilar bör inte köras innan kontroll. Åtgärd: hela bromspedalen kan bytas. Köparråd: verifiera via VIN att kampanjen är stängd.',
'https://car-recalls.eu/audi-seat-vw-skoda-brake-pedal-recall/'),

('Volkswagen','Golf',2020,2026,'Bensin','medium','engine','golf8_ea211_evo_kangaroo','1.5 TSI EVO: rycking/"kangaroo" vid låg fart',
'1.5 TSI EA211 EVO kan uppvisa rycking/"kangaroo-effekt" vid låg fart, särskilt kall motor och i stadstrafik, kopplat till Miller-cykel, cylinderavstängning (ACT) och tidig mjukvarustyrning. VW släppte mjukvaruuppdateringar (bl.a. mars 2020) som mildrade men enligt ägare inte helt eliminerade problemet på tidiga exemplar; EVO2 (från 2022) är bättre. Mindre kännbart med DSG. Köparråd: provkör kall bil från stillastående, kontrollera att senaste mjukvara är installerad.',
'https://www.volkswagenforum.co.uk/threads/1-5-tsi-evo-engine-juddering-and-a-kangarooing-effect.51130/'),

('Volkswagen','Golf',2019,2026,'Bensin','medium','engine','golf_ea211_thermostat_housing_leak','EA211: läckande termostathus/vattenpump',
'EA211 (1.0/1.4/1.5 TSI) har integrerat plasthus för vattenpump/termostat som kan spricka av värmecykling och ge långsam kylvätskeförlust (söt lukt, lågt nivålarm, i värsta fall överhettning). VW har erkänt svagheten via TSB och en reviderad del finns. Byte av pump + termostathus ca 4 000–12 000 kr pga demontering av insugsgrenrör. Köparråd: kontrollera kylvätskenivå och leta läckage.',
'https://www.carchecker.pro/reports/vw_golf_mk7_1.5_tsi.html'),

-- ============ Passat (B8, 2014–2023) ============

('Volkswagen','Passat',2014,2023,'Bensin','high','engine','passat_ea888_waterpump','EA888 Gen3: läckande vattenpump/termostathus',
'Passat B8 2.0 TSI (EA888 Gen3) delar plasthus-svagheten på vattenpump/termostat med Tiguan/Golf. Sprickor i plasthuset ger långsam kylvätskeförlust, söt lukt och risk för överhettning. Byt pump + termostat som enhet. Köparråd: leta läckagespår, kontrollera kylvätskenivå och servicehistorik.',
'https://www.go-parts.com/garage/ps-2017-2024-volkswagen-tiguan-engine-water-pump'),

('Volkswagen','Passat',2015,2022,'Laddhybrid','high','gearbox','passat_gte_dq400e_mechatronic','Passat GTE: DQ400e hybrid-DSG mekatronikfel',
'Passat GTE använder den hybridspecifika 6-stegs DQ400e. Tidiga exemplar (2015–2017) gick ofta i nödläge med växellådsfelkoder och VW bytte många mekatronikenheter på garanti. Växellådsolja/filter bör bytas var 60 000 km men servicen är svår då filtret sitter bakom hybridkomponenter. Köparråd: kräv dokumenterad DSG-service och läs felkoder.',
'https://www.carchecker.pro/reports/vw_passat_b8_gte.html'),

('Volkswagen','Passat',2015,2022,'Laddhybrid','high','electrical','passat_gte_hv_battery_12v','Passat GTE: hybridsystemfel och HV-batteri/12V-problem',
'GTE-ägare rapporterar återkommande varningar "Error: Hybrid system. STOP!", "12V-batteri laddas inte" och begränsat varvtal, ibland kopplat till en känd problematisk säkring mellan HV- och 12V-systemet, svagt 12V-batteri eller i värre fall HV-batteriets cellbalansering (felkoder P0DBC/P0DAB). GTE saknar generator; 12V laddas via DC/DC från HV-systemet. Reparation kan bli mycket dyr utanför batterigaranti. Köparråd: full VAG-felkodsläsning och test av laddning både på wallbox och schuko.',
'https://www.speakev.com/threads/passat-gte-error-hybrid-system-stop.187390/'),

('Volkswagen','Passat',2019,2022,'Laddhybrid','high','recall','passat_gte_hv_fuse_fire_93n4','Återkallelse: brandrisk HV-batterisäkring (93N4)',
'Bekräftad återkallelse (VW-kampanj 93N4), 42 571 fordon globalt, produktion 12 april 2019–22 februari 2022. Otillräcklig mängd släcksand i högvoltssystemets säkring kan göra att den brister vid kortslutning, vilket ökar risk för skador och kan avbryta strömflödet med spänningsfall och brandrisk som följd. Åtgärd: extra isolerande skyddsmatta monteras vid brytarenheten för HV-batteriet. Ytterligare kampanj 97FF rör otillräcklig avsäkring av 12V-batterikabel (produktion mars 2020–mars 2021). Köparråd: verifiera via VIN hos VW/Transportstyrelsen att båda kampanjerna är utförda innan köp.',
'https://car-recalls.eu/recall/volkswagen-passat-hybrid-2022-high-voltage-fire/'),

-- ============ Tiguan (andra generationen, 2016–) ============

('Volkswagen','Tiguan',2016,2026,NULL,'high','gearbox','tiguan_dq381_mechatronic','DQ381 våtkoppling: mekatronik- och kopplingsfel',
'Tiguan med starkare motorer (2.0 TSI/2.0 TDI) använder ofta 7-stegs DQ381 (0GC) våtkoppling. Trots våtkopplingens rykte om hållbarhet rapporteras felkoder P1735/P1736 (kopplingens lägesgivare) som slår ut udda eller jämna växlar, samt överhettning som ger limp mode, kopplingsslir och hårda växlingar vid hård/varm körning. Även total växellådshaveri förekommer. Åtgärd oftast mekatronikbyte, inte hela lådan. Köparråd: läs av felkoder med OBD, kontrollera DSG-oljebyten, undvik exemplar utan servicehistorik.',
'https://eco-torque.co.uk/blogs/news/vw-tiguan-gearbox-problems-by-year-gearbox-code'),

('Volkswagen','Tiguan',2017,2024,'Bensin','high','engine','tiguan_ea888_waterpump_thermostat','EA888 Gen3: läckande vattenpump/termostathus',
'2.0 TSI (EA888 Gen3) i Tiguan Mk2 har en känd svaghet där plasthuset till vattenpump/termostat blir sprött och spricker av värmecykling, vilket ger kylvätskeläckage. Symptom: söt lukt i motorrummet, lågt kylvätskenivålarm, i värsta fall överhettning. Olja som läcker uppifrån kan svälla packningen. VW förlängde garantin på vattenpump/termostat/termostathus till 8 år/128 000 km i vissa marknader. Byt pump och termostat som enhet; aluminiumhus i eftermarknad rekommenderas. Kostnad ca 4 000–12 000 kr. Köparråd: kontrollera kylvätskenivå och leta läckage vid provkörning.',
'https://www.go-parts.com/garage/ps-2017-2024-volkswagen-tiguan-engine-water-pump'),

('Volkswagen','Tiguan',2018,2020,'Bensin','medium','engine','tiguan_ea888_oil_consumption','EA888 Gen3: förhöjd oljeförbrukning',
'EA888 Gen3 2.0 TSI använder lågspända kolvringar för minskad friktion, vilket ger oljeförbrukning. VW anser upp till ca 0,5 liter per 1 000 km som "inom spec", vilket många ägare upplever som högt. Mest uttalat på 2018–2020. VW reviderade kolvringar på senare produktion vilket minskade men inte eliminerade problemet. Neglekterad oljenivå kan sekundärt ge lager-/vevaxelskada. Köparråd: begär oljeförbrukningstest, kontrollera nivå ofta, undvik exemplar med dokumenterat hög förbrukning.',
'https://apextechnation.com/articles/vw-tiguan-common-problems'),

('Volkswagen','Tiguan',2018,2019,NULL,'medium','recall','tiguan_seatbelt_webbing','Återkallelse: främre bältesväv kan rivas sönder',
'2018 Tiguan: främre säkerhetsbältesväv kan rivas vid krock, vilket minskar skyddet. Köparråd: verifiera via VIN att åtgärd utförts.',
'https://www.carchecker.pro/reports/vw_tiguan_mk2_2.0_tsi.html'),

-- ============ T-Cross (första generationen, 2018–) ============

('Volkswagen','T-Cross',2018,2026,'Bensin','high','gearbox','tcross_dq200_mechatronic','DQ200 torrkoppling: mekatronik-/kopplingsfel',
'T-Cross med DSG använder 7-stegs DQ200 torrkoppling. Vanliga symptom är ryckiga lågfartsväxlingar, skakning vid igångkörning och sporadiskt limp mode; tryckackumulatorn i mekatroniken kan spricka. Problem uppträder ofta vid 40 000–80 000 km. Köparråd: provkör i köbilstrafik, undvik exemplar utan DSG-servicehistorik; överväg manuell växellåda.',
'https://www.carchecker.pro/reports/vw_t_cross_1.0_tsi.html'),

('Volkswagen','T-Cross',2019,2019,NULL,'high','recall','tcross_curtain_airbag_r2020055','Återkallelse: takkrockkudde kanske inte veckas ut helt',
'DVSA-återkallelse R/2020/055 (utfärdad 26/02/2020): gasgeneratorn kan vara felaktigt svetsad mot utströmningsröret så att takkrockkudden inte veckas ut helt vid krock. Berör T-Cross byggda ca 21 maj–10 juni 2019 (766 bilar världen över, ca 102 i Tyskland). Säljs inte i USA, så återkallelsen finns i DVSA/KBA, inte NHTSA. Åtgärd: byte av berörda krockkuddemoduler. Köparråd: verifiera via VIN att åtgärden utförts.',
'https://vehicle-recall.co.uk/recalls/cars/vw/t-cross'),

('Volkswagen','T-Cross',2020,2022,NULL,'medium','recall','tcross_seatbelt_reminder_software','Återkallelse: bältespåminnelse baksäte visas ej (mjukvara)',
'Mjukvarufel i instrumentklustrets styrenhet gör att föraren inte alltid får optisk/akustisk varning när baksätespassagerare inte har bälte. DVSA R/2021/392 (21/10/2021); KBA-referens 013014 / VW-koder 90S4 och 90V6 (46 858 Polo/T-Cross/Taigo byggda 2020–2022). Åtgärd: mjukvaruuppdatering. Köparråd: verifiera att uppdateringen gjorts.',
'https://car-recalls.eu/vw-polo-t-cross-taigo-failure-seatbelt-reminder-kba/'),

-- ============ ID.3 (MEB-elbil, 2020–) ============

('Volkswagen','ID.3',2020,2026,'El','high','recall','id3_hv_battery_module_fire','Återkallelse: HV-batterimoduler brandrisk',
'Bekräftad återkallelse (UK, ca 2 261 ID.3 Pro S, produktion 17 feb 2022–23 aug 2024; del av en global kampanj på över 100 000 fordon inkl. Cupra). Högspänningsbatteriets cellmoduler kan överhettas vid laddning, med brandrisk som följd. Interimråd: ladda endast utomhus och till max 80 %. Del av samma cellproblem som drabbat ID.4 (SK Battery America-celler). Åtgärd: mjukvaruuppdatering och batterimodulkontroll/-byte vid behov. Köparråd: verifiera via VIN att kontroll/byte gjorts.',
'https://www.autoexpress.co.uk/news/369250/volkswagen-and-cupra-recall-almost-100000-evs-due-battery-fire-risk'),

('Volkswagen','ID.3',2020,2021,'El','high','recall','id3_passenger_airbag_bolt','Återkallelse: passagerarkrockkudde ej fastbultad (R/2023/072)',
'VW konstaterade att på ett fåtal ID.3 kan främre passagerarkrockkudden inte vara ordentligt fastbultad. DVSA R/2023/072 (09/03/2023): krockkudden ska avaktiveras tills kampanjen utförts, sedan inspekteras och vid behov fästas. Köparråd: verifiera via VIN.',
'https://vehicle-recall.co.uk/recalls/cars/vw/id-3'),

('Volkswagen','ID.3',2020,2021,'El','high','recall','id3_steering_worm_gear_bush','Återkallelse: saknad lagerbussning i styrväxel (R/2021/409)',
'DVSA R/2021/409 (05/11/2021): möjlig saknad lagerbussning i området vid styrsnäckan. Säkerhetskritiskt. Åtgärd: styrväxeln (styrstången) ska bytas på alla berörda fordon. Köparråd: verifiera via VIN att åtgärden utförts.',
'https://vehicle-recall.co.uk/recalls/cars/vw/id-3'),

('Volkswagen','ID.3',2020,2022,'El','medium','electrical','id3_12v_battery_drain','12V-batteri laddar ur / bil startar ej',
'Tidiga ID.3 drabbades av att 12V-batteriet laddade ur om bilen stod parkerad ett par dagar, vilket gjorde bilen orörlig. VW åtgärdade tidiga fall via mjukvara (uppdatering 0783/ME-versioner) och bytte i vissa fall 12V-batteriet kostnadsfritt. Vissa fall berodde på korroderat 12V-kablage/kontakt. Köparråd: kontrollera senaste mjukvara, aktivera "batterioptimerad användning" i appen, ha startbooster.',
'https://insideevs.com/news/464773/how-0783-update-avoids-id3-12v-issues/'),

('Volkswagen','ID.3',2020,2022,'El','medium','other','id3_battery_degradation','Batteridegradering vid hård snabbladdning',
'ID.3 med 58 kWh (62 brutto) uppvisade i tidiga tester påtaglig kapacitetsförlust: VW:s egen mätning bekräftade 92 % SOH (dvs 8 % degradering) efter 14 månader/25 000 km i ett fall med 90 % DC-snabbladdning till full och regelbunden urladdning under 10 % SOC. Degraderingen är högst första året och planar sedan ut; ett ADAC-uthållighetstest på en ID.3 Pro S (77 kWh netto) visade 91 % (±3 %) kvar efter 160 000 km/4 år trots att snabbladdare användes vid över 40 % av tillfällena. VW garanterar 70 % kvarvarande kapacitet i 8 år/160 000 km. Köparråd: begär SOH-mätning hos VW, undvik exemplar som nästan bara DC-snabbladdats.',
'https://insideevs.com/news/548404/volkswagen-confirms-8percent-degradation-id3/'),

-- ============ ID.4 (MEB-elbil, 2021–) ============

('Volkswagen','ID.4',2021,2024,'El','high','recall','id4_door_handle_water_ingress','Återkallelse: dörrhandtag släpper in vatten – dörr kan öppnas',
'Bekräftad återkallelse (NHTSA 24V-651, VW 57J9), 98 806 fordon 2021–2024, byggda i Zwickau och Chattanooga. Elektroniska dörrhandtag med otillräckligt tätat hus kan släppa in vatten till kretskortet, störa kommunikationen med styrenheten och ge en felaktig upplåsningskommando under körning. Utökar tidigare 23V213/23V312 och ledde till stoppförsäljning/produktionsstopp i USA. Åtgärd: inspektion/byte av handtag + mjukvara. Köparråd: verifiera via VIN, lyssna efter klickljud/oväntad upplåsning.',
'https://static.nhtsa.gov/odi/rcl/2024/RCLRPT-24V651-7277.PDF'),

('Volkswagen','ID.4',2023,2025,'El','high','recall','id4_hv_battery_fire','Återkallelse: HV-batteri brandrisk (SK-celler)',
'Bekräftad återkallelse (NHTSA 26V-030, inlämnad 21 jan 2026), 43 881 ID.4 av årsmodell 2023–2025 (produktion 2 sep 2022–10 apr 2025), plus 8 526 i Kanada, pga defekta högvoltsceller från SK Battery America (felinriktade elektroder vid tillverkning) som kan orsaka självurladdning och överhettning. Åtgärd: Self-Discharge Detection-mjukvara plus batterimodulbyte vid behov. Separat, mer akut kampanj 26V-028 omfattar ca 670 bilar där hela populationen bedöms ha defekten — ägare uppmanas parkera utomhus direkt efter laddning, undvika DC-snabbladdning och ladda max 80 % tills åtgärdat. Köparråd: verifiera via VIN att modulbyte/mjukvara utförts.',
'https://static.nhtsa.gov/odi/rcl/2026/RCAK-26V030-3884.pdf'),

('Volkswagen','ID.4',2020,2022,'El','high','recall','id4_pulse_inverter_stall','Återkallelse: pulsomriktare kan slås av – bil tappar drivkraft',
'Bekräftad återkallelse (NHTSA-kampanj 97ZZ), 20 904 ID.4 byggda 26 maj 2020–20 jan 2022: mjukvara kan få batteristyrenheten att återställas eller pulsomriktaren att avaktiveras, vilket ger plötslig förlust av drivkraft under körning (styrning/broms påverkas ej). Åtgärd: mjukvaruuppdatering av HV-batteristyrenhet och pulsomriktare (ej OTA – kräver verkstad). Köparråd: verifiera via VIN.',
'https://insideevs.com/news/651386/vw-id4-recall-battery-management-pulse-inverter/'),

('Volkswagen','ID.4',2021,2023,'El','medium','recall','id4_display_reboot_919a','Återkallelse: skärmar startar ej/återställs (speedometer/backkamera)',
'NHTSA-kampanj 919A: ca 79 953–88 004 ID.4 (2021–2023) kan få mitt-/instrumentdisplayer som inte startar eller sporadiskt startar om, vilket kan släcka hastighetsmätare och backkamerabild. Åtgärd: mjukvaruuppdatering. Köparråd: verifiera via VIN och testa skärmar/backkamera noga vid provkörning.',
'https://www.thecarconnection.com/news/1143294_volkswagen-id-4-recalled-for-software-and-display-issues'),

('Volkswagen','ID.4',2022,2023,'El','high','recall','id4_12v_cable_short_fire','Återkallelse: 12V-kabel kan skava mot rattstång – kortslutning/brand',
'Ca 1 000 ID.4 (2022–2023): kabeln till 12V-batteriet kan komma i kontakt med rattstången, nöta isoleringen och orsaka kortslutning, effektförlust och möjligen brand. Åtgärd hos verkstad. Köparråd: verifiera via VIN.',
'https://www.carcomplaints.com/news/2023/volkswagen-id4-recalled-loss-power.shtml'),

('Volkswagen','ID.4',2024,2024,'El','high','recall','id4_ocdc_12v_charge_loss','Återkallelse: ombordladdare (OCDC) kan sluta ladda 12V',
'2024 ID.4 (och Audi Q4 e-tron): ombordladdaren med DC/DC-omvandlare (OCDC) kan sluta ladda 12V-batteriet pga kondens/otillräcklig skyddslackering på kretskort, vilket kan ge förlust av drivkraft. Åtgärd hos verkstad. Köparråd: verifiera via VIN.',
'https://www.cars.com/research/volkswagen-id.4/recalls/')
;


-- ─── BMW — verifierade recalls/kända fel (Claude Deep Research + manuell
-- verifiering mot NHTSA/svensk press, 2026-08-14) ─────────────────────────────
-- Se data/bmw_known_issues_verified.sql för fullständig verifieringslogg.
-- Researchens råtext saknade svenska diakritiska tecken (å/ä/ö) genomgående
-- — skrivet om med korrekt svenska här, samma sakinnehåll.

INSERT INTO known_issues
  (brand, model, year_from, year_to, fuel_type, severity, category, rule_id, title, description, source_url)
VALUES

-- ============ B58-MOTORNS OLJEPUMP (INGEN OFFICIELL RECALL) ============

('BMW','3-serie',2019,2022,'Bensin','high','engine','b58tu_oil_pump_plastic_ring','B58 oljepump med plastdel kan haverera',
'B58TU-motorn (6-cylindrig bensin, t.ex. M340i) 2018–2022 har en variabel oljepump vars termoplastiska justerring blir spröd och spricker. Följden är kollapsat oljetryck och risk för totalt motorhaveri. Första symptom: oljenivåmätningen i iDrive kan inte slutföras (fastnar ofta vid 16–20 procent på varm motor) samt röd oljetrycksvarning. Ingen officiell återkallelse finns (bekräftat: "no official safety recall from BMW for this specific issue" per tidigt 2026) — kostnaden är helt köparens ansvar. Åtgärd är en uppdaterad helmetallpump. Reparation kräver att framvagnsbalken sänks: pump ca 6 500–8 000 kr plus 15 000–25 000 kr arbete hos fristående, 50 000–80 000 kr hos märkesverkstad. Köparråd: testa alltid att oljenivåmätningen går att slutföra efter 25–30 min körning; be om kvitto på att metallpump monterats.',
'https://www.go-parts.com/garage/engine-oil-pump-bmw-x5-bmw-x6-bmw-x7-2018-2025'),

('BMW','X3',2018,2022,'Bensin','high','engine','b58tu_oil_pump_plastic_ring_x3','B58 oljepump med plastdel kan haverera (X3 M40i/30i)',
'X3 M40i och vissa xDrive30i (G01) med B58TU (6-cylindrig bensin) 2018–2022 delar oljepumpen med plastring som kan spricka och orsaka oljetrycksfall och motorhaveri. Symptom: oljenivåmätning går ej att slutföra, lågt oljetryck. Ingen återkallelse — köparens risk. Åtgärd: helmetallpump; arbetet kräver sänkt framvagnsbalk och kostar 50 000–80 000 kr hos märkesverkstad. Köparråd: kontrollera oljenivåmätning och servicehistorik.',
'https://x3.xbimmers.com/forums/showthread/2230748/128680-b58-owners-help-force-an-oil-pump-recall'),

('BMW','X5',2019,2023,'Bensin','high','engine','b58tu_oil_pump_plastic_ring_x5','B58 oljepump med plastdel kan haverera (X5 40i)',
'X5 xDrive40i (G05) med B58TU (6-cylindrig bensin) 2019–2023 har oljepumpen med spröd plastring som kan spricka. Följd: oljetrycksfall och motorhaveri. Symptom: oljenivåmätning stannar vid 16–20 procent, oljetrycksvarning. Ingen officiell återkallelse. Åtgärd: helmetallpump, mycket arbetskrävande (subframe sänks), 50 000–80 000 kr hos märkesverkstad. Köparråd: testa oljenivåmätning på varm motor före köp.',
'https://g05.bimmerpost.com/forums/showthread/2219966/the-dreaded-b58-oil-pump'),

('BMW','X5',2020,2023,'Laddhybrid','high','engine','b58tu_oil_pump_plastic_ring_x5_45e','B58 oljepump med plastdel (X5 xDrive45e PHEV)',
'X5 xDrive45e (G05) är en laddhybrid som använder B58 (6-cylindrig bensin) och ärver därför samma oljepumpsdefekt med spröd plastring 2020–2023. Kan ge oljetrycksfall och motorhaveri. Symptom: oljenivåmätning går ej att slutföra, oljetrycksvarning. Ingen återkallelse. Köparråd: kontrollera både oljepump och högspänningsbatteriets status vid köp.',
'https://www.go-parts.com/garage/engine-oil-pump-bmw-x5-bmw-x6-bmw-x7-2018-2025'),

('BMW','5-serie',2019,2022,'Bensin','high','engine','b58tu_oil_pump_plastic_ring_540i','B58 oljepump med plastdel (540i)',
'540i (G30/G31) med B58TU (6-cylindrig bensin) 2019–2022 kan drabbas av oljepumpens spruckna plastring (delnummer 11419895359 i metallversionen vid byte), med oljetrycksfall och motorhaveri som följd. Färre rapporter än på X5 men samma grundfel. Symptom: oljenivåmätning stannar, oljetrycksvarning. Ingen återkallelse. Åtgärd: helmetallpump, 50 000–80 000 kr hos märkesverkstad.',
'https://g30.bimmerpost.com/forums/showthread/2111697/b58-is-this-a-serious-source-of-concern-or-overblown'),

-- ============ B58 STARTMOTORELEKTRONIK (BRANDRISK, 24V-576) ============

('BMW','3-serie',2018,2025,'Bensin','high','recall','b58_starter_electronics_fire','Återkallelse: B58 startmotorelektronik kan överhetta (brand)',
'Bekräftad återkallelse (NHTSA 24V-576) för B58-motorns (6-cylindrig bensin) startmotor: intern mekanisk skada kan göra att starten misslyckas, och om föraren upprepar långa startförsök kan startmotorn elektriskt överbelastas och överhettas — i värsta fall en termisk händelse eller motorbrand, särskilt om ljudisoleringen är förorenad av oljeläckage. Över 100 000 B58-fordon i USA (bl.a. M340i, 540i, 740i, 840i, X3/X4/X5/X6/X7), byggda 2019–2021. Ursprunglig åtgärd var en mjukvaruuppdatering av motorstyrenheten för att förhindra överbelastning — en senare, utökad kampanj (25V-644) krävde istället fysiskt byte av startmotorn eftersom mjukvarufixen visade sig otillräcklig. Köparråd: VIN-kontrollera att BÅDA kampanjerna (mjukvara och ev. fysiskt byte) är utförda.',
'https://www.vibilagare.se/nyheter/bmw-aterkallar-13-miljoner-bilar-risk-brand'),

('BMW','X5',2018,2025,'Bensin','high','recall','b58_starter_electronics_fire_x5','Återkallelse: B58 startmotorelektronik kan överhetta (X5)',
'X5, X6 och X7 med B58 (6-cylindrig bensin) omfattas av återkallelsen (NHTSA 24V-576) för startmotorelektronik som kan överhettas och orsaka brand vid upprepade startförsök. Byggda 2018–2025. En senare, utökad kampanj (25V-644) krävde fysiskt byte av startmotorn utöver den ursprungliga mjukvaruuppdateringen. Köparråd: kontrollera VIN hos BMW-verkstad att båda åtgärderna är utförda före köp.',
'https://www.vibilagare.se/nyheter/bmw-aterkallar-13-miljoner-bilar-risk-brand'),

-- ============ STARTRELÄ (BRANDRISK, >1,1 MILJONER GLOBALT) ============

('BMW','3-serie',2015,2021,NULL,'high','recall','starter_relay_water_corrosion_fire','Återkallelse: startrelä kan korrodera och orsaka brand',
'Global återkallelse (över 1,1 miljoner bilar, 196 355 i USA, bekräftat av NHTSA) där vatten kan tränga in i startmotorns relä och orsaka korrosion, kortslutning och brand — även med parkerad, avstängd bil, ibland timmar efter senaste körningen. Drabbar 3-serie (G20) m.fl. byggda 28 september 2015–7 september 2021. Både bensin och diesel. NHTSA/BMW uppmanade ägare att parkera utomhus, borta från byggnader, tills åtgärdat. Åtgärd: kostnadsfritt byte av startmotor/reläbrytare. Köparråd: kontrollera att kampanjen är utförd innan köp.',
'https://www.autoevolution.com/news/bmw-recalls-nearly-200000-vehicles-over-b48-engine-starter-relay-issue-258181.html'),

('BMW','5-serie',2015,2021,NULL,'high','recall','starter_relay_water_corrosion_fire_5','Återkallelse: startrelä kan korrodera (5-serie)',
'5-serie (G30/G31) omfattas av den globala startrelä-återkallelsen (över 1,1 miljoner bilar globalt) där vatteninträngning ger korrosion, kortslutning och brandrisk, även vid parkerad bil. Byggda 2015–2021. Både bensin och diesel. Kostnadsfri åtgärd — VIN-kontrollera före köp, och parkera utomhus tills åtgärdat.',
'https://www.vibilagare.se/nyheter/bmw-utokar-aterkallelsen-brandrisk-i-575-000-bilar'),

('BMW','X3',2015,2021,NULL,'high','recall','starter_relay_water_corrosion_fire_x3','Återkallelse: startrelä kan korrodera (X3)',
'X3 (G01) omfattas av startrelä-återkallelsen (vatten → korrosion → kortslutning → brand, även vid parkerad bil). Byggda 2015–2021. Kostnadsfri åtgärd hos verkstad. Kontrollera öppna kampanjer via VIN.',
'https://www.vibilagare.se/nyheter/bmw-aterkallar-744-000-bilar-brandrisk-i-startmotorn'),

-- ============ INTEGRERAT BROMSSYSTEM (CONTINENTAL, 24V-104) ============

('BMW','5-serie',2023,2025,NULL,'high','recall','continental_integrated_brake','Återkallelse: integrerat bromssystem (brake-by-wire) kan svikta',
'Bekräftad återkallelse (NHTSA 24V-104), 79 670 fordon i USA, ca 1,5 miljoner globalt, ca 10 000 i Sverige (BMW Sverige). Continental-levererat integrerat bromssystem (IB) kan inte fungera enligt specifikation: bromsservo minskar, och ABS/DSC kan sluta fungera — längre stoppsträcka och risk för kontrollförlust. Modellår 2023–2025 (bl.a. 5-serie/i5), byggda 2 aug 2022–26 okt 2023. Åtgärd: kostnadsfritt byte av IB-modul (ca 3,5 tim). OBS: bilar som redan fått en ersättningsdel under den ursprungliga kampanjen kan behöva få den bytt igen. Köparråd: nyare G-bilar — kontrollera VIN.',
'https://www.cars.com/research/bmw-x5-2024/recalls/'),

('BMW','X5',2023,2025,NULL,'high','recall','continental_integrated_brake_x5','Återkallelse: integrerat bromssystem (X5)',
'X5 (G05) 2023–2025 omfattas av Continental-bromssystemets återkallelse (NHTSA 24V-104, 79 670 i USA, ~1,5 miljoner globalt). IB-modulen kan tappa bromsservo och slå ut ABS/DSC. Kostnadsfritt byte av modul. Kontrollera VIN före köp av senare årsmodell.',
'https://www.cars.com/research/bmw-x5-2024/recalls/'),

('BMW','X5',2019,2021,NULL,'high','recall','integrated_brake_21v062','Återkallelse: tidig integrerad broms ej producerad enligt specifikation',
'Tidigare, separat bromsåterkallelse (NHTSA 21V-062) där IB-styrenheten inte producerats enligt specifikation: vid hård inbromsning kan bromsassistansen minska och stoppsträckan bli längre. Modellår 2019–2021, byggda 4 dec 2018–8 dec 2020, bl.a. G05 X5. Åtgärd: kostnadsfritt byte av IB.',
'https://static.nhtsa.gov/odi/rcl/2021/RCRIT-21V062-2025.pdf'),

-- ============ DIESEL EGR-KYLARE (BRANDRISK) ============

('BMW','3-serie',2013,2018,'Diesel','high','recall','b47_n47_egr_cooler_fire','Återkallelse: EGR-kylare kan läcka glykol och orsaka brand',
'Dieselmotorernas (N47/B47, 4-cylindrig) EGR-kylare kan spricka invändigt så att glykol läcker, blandas med sot och antänds — kan smälta insugsröret och ge motorbrand. Ursprunglig återkallelse (NHTSA 18V-755, ~44 000 fordon, MY 2013–2017) visade sig otillräcklig och expanderades kraftigt (NHTSA 21V-907, senare kampanjer till 2021–2022) till totalt ca 800 000 fordon globalt, uppskattningsvis ca 35 000 i Sverige (Vi Bilägare/Auto Motor & Sport). Drabbar 320d m.fl. Symptom: återkommande kylvätskeförlust utan synligt läckage. Åtgärd: kostnadsfritt byte av EGR-kylare (och insugsrör vid skada). Köparråd: verifiera att den SENASTE åtgärden är utförd, inte bara den första kampanjen.',
'https://www.consumerreports.org/car-recalls-defects/bmw-recalls-diesel-cars-and-suvs-for-fire-risk'),

('BMW','X3',2015,2018,'Diesel','high','recall','b47_n47_egr_cooler_fire_x3','Återkallelse: EGR-kylare brandrisk (X3 diesel)',
'X3 (xDrive20d/28d) med N47/B47-diesel omfattas av EGR-kylarens brandåterkallelse (NHTSA 18V-755, senare kraftigt expanderad) — glykolläckage kan antändas och smälta insugsröret. Kostnadsfri åtgärd. Kontrollera att den senaste kampanjen är utförd; se även upp för spruckna insugsrör.',
'https://www.consumerreports.org/car-recalls-defects/bmw-recalls-diesel-cars-and-suvs-for-fire-risk'),

('BMW','X5',2014,2018,'Diesel','high','recall','b47_n57_egr_cooler_fire_x5','Återkallelse: EGR-kylare brandrisk (X5 diesel)',
'X5 (xDrive25d/35d) med diesel (B47/N57) omfattas av EGR-kylarens brandåterkallelse. Glykol kan läcka, blandas med sot och antändas. NHTSA 18V-755, senare expanderad (21V-907) till totalt ca 800 000 fordon globalt. Kostnadsfri åtgärd hos verkstad. Verifiera att den senaste kampanjen är utförd.',
'https://www.autoevolution.com/news/bmw-egr-coolant-leak-may-cause-fire-recall-issued-for-50000-vehicles-175383.html'),

-- ============ LADDHYBRIDERNAS HÖGSPÄNNINGSBATTERI (BRANDRISK) ============

('BMW','3-serie',2020,2021,'Laddhybrid','high','recall','phev_hv_battery_debris_fire','Återkallelse: högspänningsbatteri kan kortsluta (brand)',
'Bekräftad återkallelse (NHTSA 20V-601): laddhybridernas (330e) högspänningsbatteri från Samsung kan innehålla tillverkningsskräp i cellerna som ger kortslutning och brandrisk vid laddning. 4 509 fordon i USA, 26 900 globalt. BMW kände till fyra "fältincidenter", varav den första var en 2021 X5 med en termisk händelse. Ägare uppmanades sluta ladda och undvika manuellt/sportläge tills åtgärdat. Åtgärd: kostnadsfri inspektion och byte av batterimoduler vid behov. Köparråd: bekräfta att åtgärden är utförd och läs servicehistorik.',
'https://www.greencarreports.com/news/1130003_bmw-expands-recall-to-most-2020-2021-plug-in-hybrids-over-battery-fire-issue'),

('BMW','5-serie',2020,2021,'Laddhybrid','high','recall','phev_hv_battery_debris_fire_530e','Återkallelse: högspänningsbatteri kan kortsluta (530e)',
'530e:s Samsung-batteri kan ha skräp i cellerna som orsakar kortslutning och brand. NHTSA 20V-601 (4 509 i USA / 26 900 globalt). Byggda 2020–2021. Ägare uppmanades att inte ladda tills åtgärdat. Kostnadsfri inspektion/modulbyte. Kontrollera VIN.',
'https://www.asburyauto.com/2020-bmw-5-series-battery-recall'),

('BMW','X3',2020,2021,'Laddhybrid','high','recall','phev_hv_battery_debris_fire_x3','Återkallelse: högspänningsbatteri kan kortsluta (X3 xDrive30e)',
'X3 xDrive30e byggd 3 juni 2020–22 jan 2021 omfattas av batteri-brandåterkallelsen (skräp i Samsung-celler → kortslutning). NHTSA 20V-601. Kostnadsfri inspektion/modulbyte. Verifiera åtgärd via VIN.',
'https://static.nhtsa.gov/odi/rcl/2020/RCRIT-20V601-6527.pdf'),

('BMW','X5',2020,2021,'Laddhybrid','high','recall','phev_hv_battery_debris_fire_x5','Återkallelse: högspänningsbatteri kan kortsluta (X5 xDrive45e)',
'X5 xDrive45e byggd 6 juni 2020–14 jan 2021 omfattas av batteri-brandåterkallelsen. Skräp i Samsung-celler kan ge kortslutning och termisk händelse — den första kända fältincidenten i hela kampanjen gällde just en 2021 X5. NHTSA 20V-601. Kostnadsfri inspektion/modulbyte. Kontrollera VIN.',
'https://static.nhtsa.gov/odi/rcl/2020/RCRIT-20V601-6527.pdf'),

('BMW','5-serie',2016,2020,'Laddhybrid','medium','electrical','phev_starter_relay_fire','Återkallelse: startrelä brandrisk på äldre laddhybrid',
'Separat återkallelse (juli 2026) för äldre laddhybrider där vatten kan orsaka korrosion i startreläet → kortslutning och brandrisk även vid parkerad bil. 29 119 PHEV i USA (bl.a. 530e/740Le), byggår 2016–2020. Åtgärd: kostnadsfritt byte. Kontrollera VIN.',
'https://www.foxbusiness.com/economy/bmw-recalls-nearly-30k-vehicles-over-engine-starter-defect-could-cause-fire'),

-- ============ B48-MOTORNS KYLSYSTEM OCH LADDLUFTRÖR ============

('BMW','3-serie',2018,2024,'Bensin','medium','engine','b48_coolant_plastic_leak','B48 spröda plast-kylvätskedelar spricker',
'B48 (4-cylindrig bensin) i G20 använder plastdelar i kylsystemet (ventilslang topplock→expansionskärl samt oljefilterhusets tätning) som blir spröda och spricker, med plötslig kylvätskeförlust och överhettningsrisk. Bekräftat i BMW TSB SIB 11 10 25 samt en tidigare TSB från februari 2022. Gäller även 330e (B48-bas). Reparation fördyras av delarnas placering under insuget. Köparråd: leta efter vita, intorkade kylvätskefläckar runt expansionskärlet och kontrollera servicehistorik.',
'https://static.nhtsa.gov/odi/tsbs/2026/MC-11026946-0001.pdf'),

('BMW','5-serie',2017,2024,'Bensin','medium','engine','b48_coolant_plastic_leak_5','B48 spröda plast-kylvätskedelar spricker (5-serie)',
'520i/530i (G30) med B48 (4-cylindrig bensin) får spruckna plast-kylvätskeslangar och läckande oljefilterhus — plötslig kylvätskeförlust och överhettningsrisk. Bekräftat i BMW TSB. Dyr reparation på grund av delarnas placering. Köparråd: kontrollera kylvätskenivå och tidigare byten.',
'https://www.bimmerforums.co.uk/threads/g30-b48-engine-common-problems.595420/'),

('BMW','X3',2018,2024,'Bensin','medium','engine','b48_coolant_plastic_leak_x3','B48 spröda plast-kylvätskedelar spricker (X3)',
'X3 xDrive20i/30i (G01) med B48 (4-cylindrig bensin) delar problemet med spröda plast-kylvätskedelar (ventilslang, oljefilterhus) som spricker och ger plötslig kylvätskeförlust. Bekräftat i BMW TSB. Köparråd: kontrollera för kylvätskeläckage före köp.',
'https://static.nhtsa.gov/odi/tsbs/2026/MC-11026946-0001.pdf'),

('BMW','3-serie',2018,2024,'Bensin','medium','engine','b48_charge_pipe_crack','B48 charge pipe (laddluftrör) kan spricka',
'B48 (4-cylindrig bensin) använder ett plaströr (charge pipe) mellan turbo och gasspjäll som kan spricka under boost, särskilt vid hård acceleration eller trimning. Symptom: högt POP-ljud, plötslig effektförlust och varningen "Drivetrain Malfunction". Gäller 320i/330i m.fl. Åtgärd: byte, gärna till förstärkt aluminiumrör. Inte säkerhetskritiskt men leder till strandsättning.',
'https://motronix.net/blog/bmw-charge-pipe-failure-n20-b48-n55-b58/'),

-- ============ X5 LUFTFJÄDRING ============

('BMW','X5',2019,2024,NULL,'high','other','x5_air_suspension_failure','X5 luftfjädring: bälgar och kompressor slits',
'X5 (G05) med luftfjädring får spruckna/läckande luftbälgar, sliten kompressor och spruckna plast-distributionsblock, ofta redan från ca 6 000 mil. Symptom: bilen sjunker vid parkering (särskilt bak), ojämn körhöjd och varningen "Check Air Suspension". Dyr OEM-reparation och följdskador när en komponent överbelastar nästa. Köparråd: parkera provbilen några timmar och kontrollera att den står kvar i nivå; läs av felkoder.',
'https://www.autodoc.co.uk/info/problems-with-the-bmw-x5'),

-- ============ LADDHYBRIDERNAS LADDNING/RÄCKVIDD ============

('BMW','X5',2020,2024,'Laddhybrid','high','electrical','phev_eme_charging_failure','Laddhybrid: EME/laddmodul kan sluta ladda',
'Laddhybridens EME (Electrical Machine Electronics/laddmodul) kan fela så att bilen inte går att ladda och visar "Drivetrain Malfunction" eller reducerad elektrisk effekt. Gäller X5 xDrive45e (och 330e/530e/X3 30e). Ibland löses det med mjukvara eller rengöring av jordanslutning (BMW TSB SI B12 22 19), ibland krävs dyrt EME-byte (VIN-låst, kan inte vara begagnad plug-and-play). Köparråd: provladda bilen före köp och kontrollera laddhistorik i appen.',
'https://www.go-parts.com/garage/power-converter-bmw-x5-bmw-x3-bmw-530e-2019-2025'),

('BMW','3-serie',2019,2024,'Laddhybrid','medium','electrical','phev_charging_software_range','Laddhybrid: laddfel och räckviddstapp',
'330e/530e (och X3 30e/X5 45e) rapporterar laddproblem (laddningen startar men SoC ökar inte, fel utlösta av vissa hemmaladdare) och successiv räckviddsförlust. Ofta åtgärdat med BMW-mjukvaruuppdatering, men återkommande för vissa. Köparråd: kontrollera senaste mjukvaruversion och verklig elräckvidd vid provkörning.',
'https://g20.bimmerpost.com/forums/showthread/2112803/330e-drivetrain-reduced-electric-power'),

-- ============ ZF 8HP-AUTOMATEN ============

('BMW','5-serie',2016,2024,NULL,'medium','gearbox','zf_8hp_mechatronic_leak','ZF 8HP mekatronik: hylstätning kan läcka',
'Den 8-växlade ZF-automaten (GA8HP) är robust men mekatronikens hylskontakt/tätning kan läcka ATF (ser ut som bakre packboxläckage), och missade oljebyten ger solenoid-/ventilhus-slitage. Symptom: ryck vid växling 1–2, limp mode i 3:e växeln, felkoder 4B13–4B1E. BMW anger felaktigt "livstidsolja" — ZF rekommenderar byte var 6 000–8 000 mil. Gäller alla G-modeller med 8HP. Köparråd: byt ATF vid ca 10 000 mil och känn efter ryck vid provkörning.',
'https://apextechnation.com/articles/zf-8hp-transmission'),

-- ============ ÖVRIGT ============

('BMW','3-serie',2019,2024,'Bensin','low','engine','b58_oil_consumption','B58 hög oljekonsumtion',
'B58 (6-cylindrig bensin) kan förbruka mer olja än väntat på grund av hög kompression (11,0:1) och kolvringsdesign. Avsaknad av mätsticka och ett trögt elektroniskt oljenivåsystem gör det svårt att upptäcka i tid. Inte ett haveri i sig men kräver regelbunden kontroll för att undvika oljebrist. Köparråd: kontrollera oljenivå ofta och fyll på med rätt specifikation (0W-20/LL-04 beroende på motor).',
'https://www.brrperformance.com/bmw-b58-engine-oil-pump-issues/'),

('BMW','X3',2017,2024,NULL,'low','other','x3_g01_sunroof_leak','X3 panoramatak kan läcka vatten',
'X3 (G01) med panoramatak rapporterar vatteninträngning vid kraftigt regn, med fuktfläckar i takklädseln (särskilt bakre hörn) — ofta på grund av igensatta dräneringsslangar. Köparråd: känn efter fukt/möglukt och inspektera innertaket och bagageutrymmet före köp.',
'https://club.autodoc.de/forum/topic/bmw-x3-g01-bekannte-probleme-und-kaufberatung-als-gebrauchtwagen')
;


-- ─── MERCEDES-BENZ — verifierade recalls/kända fel (Claude Deep Research +
-- manuell verifiering mot NHTSA, 2026-08-14) ──────────────────────────────────
-- Se data/mercedes_known_issues_verified.sql för fullständig verifieringslogg.

INSERT INTO known_issues
  (brand, model, year_from, year_to, fuel_type, severity, category, rule_id, title, description, source_url)
VALUES

-- ============ BENSIN: M274/M264 KAMKEDJA OCH BALANSAXEL ============

('Mercedes-Benz','C-klass', 2014, 2019, 'Bensin', 'high', 'engine', 'm274_kamkedja_slitage', 'M274-bensin: kamkedjeslitage',
'Fyrcylindriga turbobensinmotorn M274 (C160/C180/C200/C250/C300) kan få utdraget kamkedjeslitage och slitna kedjestyrningar, ofta kopplat till för långa oljebytesintervall. Symptom: rasslande ljud vid kallstart/tomgång, felkoder P0016/P0017 för kamaxel-/vevaxelkorrelation, tänd motorlampa och ojämn gång, typiskt vid 8 000–10 000 mil. I värsta fall hoppar kedjan tänder och ger ventilskador. Notera: till skillnad från äldre M272-V6:orna (grupptalan Seifi v. MBUSA, förlikning godkänd 17 aug 2015, garanti upp till 10 år/125 000 miles) har M274 kugghjulsdrivna Lanchester-balansaxlar, så det klassiska balansaxeldrevsfelet gäller INTE denna motor. Reparationskostnad för kedjebyte ca 15 000–30 000 kr. Köpråd: lyssna efter kallstartsrassel, kräv dokumenterade oljebyten var 1 500:e mil.',
'https://www.autodoc.se/info/mercedes-c-klass-w205-problem'),

('Mercedes-Benz','GLC', 2015, 2019, 'Bensin', 'high', 'engine', 'm274_kamkedja_slitage_glc', 'M274-bensin: kamkedjeslitage (GLC)',
'GLC 250/300 med M274 2.0 turbobensin (samma motor som C-klass W205) kan drabbas av kamkedjeslitage och kamaxeljusterarens magnetventil. Symptom: skrammel vid kallstart, kamaxel-/vevaxelfelkoder, tänd motorlampa. Uppträder typiskt runt 8 000–10 000 mil. Reparation ca 15 000–30 000 kr. Köpråd: provkör kall bil, kontrollera servicehistorik med täta oljebyten.',
'https://minbilkoll.se/vanliga-fel/mercedes-benz/glc/'),

('Mercedes-Benz','C-klass', 2014, 2019, 'Bensin', 'medium', 'engine', 'm274_hog_oljeforbrukning', 'M274-bensin: hög oljeförbrukning',
'M274-motorn, särskilt C200 och C250, tenderar att förbruka mer olja. Tillverkaren anger upp till 0,5 liter per 100 mil som "normalt"; högre förbrukning uppträder ofta från 4 000–6 000 mil. Orsak: slitna kolvringar eller ventilskaftstätningar. Köpråd: kontrollera oljenivån månadsvis, be säljaren om påfyllningshistorik. Höga värden kan indikera begynnande motorskada.',
'https://www.autodoc.se/info/mercedes-c-klass-w205-problem'),

('Mercedes-Benz','GLC', 2015, 2019, 'Bensin', 'medium', 'engine', 'm274_hog_oljeforbrukning_glc', 'M274-bensin: hög oljeförbrukning (GLC)',
'GLC 250/300 med M274 har samma tendens till förhöjd oljeförbrukning som C-klass. Räkna med månatlig kontroll av oljenivån. Höga värden (över 0,5 l/100 mil) kan tyda på slitna kolvringar. Köpråd: kontrollera oljesticka och avgasrök vid provkörning.',
'https://minbilkoll.se/vanliga-fel/mercedes-benz/'),

('Mercedes-Benz','C-klass', 2014, 2019, 'Bensin', 'medium', 'engine', 'm274_termostat_kylvatska', 'M274-bensin: termostathus/kylvätskeläckage',
'Vanligaste felet på M274 enligt verkstäder är haverande termostat/termostathus med kylvätskeförlust (felkoder P0128/P0597). Relativt kostsamt jämfört med andra bilar. Symptom: kylvätskevarning, långsam uppvärmning, motorlampa. Köpråd: kontrollera kylvätskenivå och spår av läckage under motorn.',
'https://en.mercedesassistance.com/m274-engine-mercedes/'),

-- ============ HYBRID: 48V MILDHYBRID (M264 EQ BOOST) ============

('Mercedes-Benz','C-klass', 2019, 2021, 'Hybrid', 'high', 'electrical', 'm264_48v_mildhybrid_fel', 'M264 48V-mildhybrid: batteri/ISG-fel',
'Bensinmotorn M264 med 48-volts EQ Boost-mildhybrid (integrerad startgenerator/ISG, 48V litiumbatteri, DC/DC-omvandlare) kan ge meddelandet "48V-batteri – se instruktionsbok", bortkopplad start/stopp och i värsta fall totalt startstopp som inte går att starthjälpa. Orsak: defekt 48V-batteri, ISG, mjukvara, vatteninträngning eller dålig jordanslutning. Reparation dyr (ofta 8 000–30 000 kr) och batteriet måste kodas. Köpråd: kontrollera att inga 48V-varningar finns och att ev. jordkabel-återkallelse är åtgärdad.',
'https://en.mercedesassistance.com/48v-battery-see-owners-manual/'),

('Mercedes-Benz','E-klass', 2019, 2023, 'Hybrid', 'high', 'electrical', 'm264_48v_mildhybrid_fel_eklass', 'M264 48V-mildhybrid: batteri/ISG-fel (E-klass)',
'E-klass W213 (facelift) med 48V EQ Boost kan drabbas av samma mildhybridsfel: "48V-batteri"-varning, bortkopplad start/stopp och sällsynt totalt startstopp. Se separat 48V-jordkabelåterkallelse för vissa E-klass. Köpråd: läs av felkoder, kontrollera återkallelsestatus innan köp.',
'https://www.go-parts.com/garage/vehicle-battery-mercedes-benz-e53-amg-mercedes-benz-amg-gt-mercedes-benz-c63-amg-s-e-performance-2018-2025'),

('Mercedes-Benz','E-klass', 2021, 2023, 'Hybrid', 'high', 'recall', 'e_48v_jordkabel_brandrisk', 'Återkallelse: 48V-jordanslutning brandrisk (E-klass)',
'Bekräftad återkallelse, ca 12 200 fordon (2021–2023 E450, CLS 450, AMG E53 m.fl.). Mercedes fick kännedom om problemet sent 2022 via fältrapporter. En otillräckligt åtdragen 48V-jordanslutning i motorrummet kan öka resistans/värme vid hög ström och orsaka brandrisk, samt trigga samma "48V Battery Malfunction"-varningar som ett batterihaveri. Åtgärd: kontroll/åtdragning av bulten gratis hos verkstad. Köpråd: kontrollera att återkallelsen är utförd.',
'https://www.carscoops.com/2024/02/mercedes-needs-to-fix-48-volt-connection-on-e-class-cls-and-amg-gt-4-door-over-fire-risk/'),

-- ============ DIESEL: OM651 ============

('Mercedes-Benz','C-klass', 2014, 2016, 'Diesel', 'high', 'engine', 'om651_insprutare_fel', 'OM651-diesel: insprutarfel',
'Kvalitetsproblem med insprutarna (spridarna) på fyrcylindriga OM651-dieseln drabbade många ägare (i Tyskland uppges var tionde ägare berörd enligt Auto Motor & Sport Sverige). När en eller flera spridare slutar fungera går motorn ojämnt och styrsystemet lägger motorn i nödprogram (max ca 70 km/h) med tänd motorlampa. Kostnad ca 4 500–8 500 kr per insprutare. Köpråd: kontrollera servicebok för insprutarbyten, provkör och känn efter ryck/effektbortfall.',
'https://www.automotorsport.se/nyheter/manga-mercedes-agare-drabbas-av-motorfel/'),

('Mercedes-Benz','GLC', 2015, 2018, 'Diesel', 'medium', 'engine', 'om651_egr_sot', 'OM651-diesel: EGR/insugssotning (GLC)',
'GLC 220d/250d med OM651 (X253 före faceliften) får kraftig sotbeläggning i insugsgrenrör och på EGR-ventilen, särskilt vid mycket kortkörning. Symptom: ojämn tomgång, minskad effekt, ökad förbrukning, EGR-/luftmassrelaterade felkoder, ibland nödprogram. Rengöring ca 1 500–2 500 kr, byte 4 000–9 000 kr. OM651 har även en simplex-kamkedja baktill som kan tänjas. Köpråd: undvik exemplar som enbart kortkörts, kräv servicehistorik.',
'https://www.carchecker.pro/reports/mercedes_glc_220d_x253.html'),

('Mercedes-Benz','C-klass', 2014, 2018, 'Diesel', 'medium', 'engine', 'om651_egr_sot_cklass', 'OM651-diesel: EGR/insugssotning (C-klass)',
'C200d/C220d med OM651 får samma sotproblem i EGR/insug vid kortkörning: ojämn tomgång, effektbortfall, felkoder. OM651:s bakre simplex-kamkedja kan tänjas vid eftersatt oljebyte (kräver byte ca 8 000–10 000 mil). Köpråd: kontrollera servicehistorik och lyssna efter kamkedjeljud.',
'https://minbilkoll.se/vanliga-fel/mercedes-benz/c-klass/'),

-- ============ DIESEL: OM654 ============

('Mercedes-Benz','E-klass', 2016, 2019, 'Diesel', 'medium', 'engine', 'om654_kamkedja_vipparm', 'OM654-diesel: kamkedjespännare/vipparmsslitage',
'Tidiga OM654 (2.0 diesel) i E220d/E200d hade kamkedjespännare som kunde haverera (i huvudsak 2016–2018, förbättrat från 2018). Även slitage på vipparmar/rullar på avgassidan förekommer, med skrammel vid kallstart och ojämn tomgång/misständningskänsla vid låg gaspådrag. Reparation: kedjesats 15 000–30 000 kr, vipparmar billigare om upptäckt tidigt. Köpråd: provkör kall bil, verifiera ev. återkallelse (RC3021, tidig kamkedja) är utförd.',
'https://www.carchecker.pro/reports/mercedes_e220d_w213.html'),

('Mercedes-Benz','C-klass', 2016, 2018, 'Diesel', 'medium', 'engine', 'om654_kamkedja_cklass', 'OM654-diesel: kamkedjespännare (C-klass)',
'C200d/C220d/C300d med OM654 (tidiga årsmodeller) kan ha kamkedjespännar- och guideskeneslitage samt vipparmsslitage. Skramlande ljud vid kallstart. Förbättrat från ca 2018. Köpråd: provkör kall, kräv servicehistorik med korrekta oljebyten.',
'https://www.linksautomotive.co.uk/2026/07/07/mercedes-timing-chain-rattle-macclesfield/'),

('Mercedes-Benz','GLC', 2019, 2022, 'Diesel', 'medium', 'engine', 'om654_kamkedja_glc', 'OM654-diesel: kamkedja/vipparm (GLC)',
'GLC 200d/220d/300d med OM654 (X253 facelift samt tidig C254) delar OM654:s kända kamkedje- och vipparmsslitage. Skrammel vid kallstart, ojämn gång. Köpråd: provkör kall bil, verifiera återkallelsestatus och servicehistorik.',
'https://www.roademaingarage.co.uk/2026/07/22/mercedes-timing-chain-rattle-northampton'),

-- ============ DIESEL: ADBLUE/SCR/NOX ============

('Mercedes-Benz','C-klass', 2015, 2022, 'Diesel', 'high', 'engine', 'adblue_scr_nox_cklass', 'Diesel: AdBlue/SCR- och NOx-givarfel',
'Dieslarna med SCR-katalysator (AdBlue) på OM651/OM654 får återkommande fel på NOx-givare (före/efter katalysator), doseringsventil och AdBlue-pump. Felen kaskaderar ofta (DPF-, EGR- och SCR-koder samtidigt) och triggar lagstadgade varningar med nedräkning mot startspärr ("start ej möjlig om X mil"). Symptom: AdBlue-varning, minskad effekt. Kostnad: NOx-givare 3 000–7 000 kr styck, doseringsventil/pump mer. Köpråd: läs av felkoder, kontrollera att inga AdBlue-nedräkningar är aktiva.',
'https://precisionremapsuk.com/blogs/car-diagnostics/mercedes-om651-om654-adblue-faults-c220d-e220d-sprinter-scr-fix'),

('Mercedes-Benz','GLC', 2015, 2022, 'Diesel', 'high', 'engine', 'adblue_scr_nox_glc', 'Diesel: AdBlue/SCR- och NOx-givarfel (GLC)',
'GLC-dieslar med SCR/AdBlue får återkommande NOx-givarfel och doseringsproblem som triggar startspärrsnedräkning. Kristalliserad AdBlue kan blockera doseringsventilen, särskilt vid kortkörning. Köpråd: verifiera att AdBlue-systemet fungerar och att inga varningar/nedräkningar finns.',
'https://minbilkoll.se/vanliga-fel/mercedes-benz/glc/'),

('Mercedes-Benz','E-klass', 2016, 2022, 'Diesel', 'high', 'engine', 'adblue_scr_nox_eklass', 'Diesel: AdBlue/SCR- och NOx-givarfel (E-klass)',
'E220d/E300d med OM654 får samma AdBlue/SCR- och NOx-givarproblem med risk för startspärr. Köpråd: läs av SCR-felkoder, kontrollera AdBlue-doseringens funktion.',
'https://en.mercedesassistance.com/adblue-system-malfunction/'),

-- ============ ÅTERKALLELSE: KYLVÄTSKEPUMP BRANDRISK (OM654/OM656) ============

('Mercedes-Benz','C-klass', 2017, 2021, 'Diesel', 'high', 'recall', 'kylvatskepump_brandrisk_cklass', 'Återkallelse: kylvätskepump brandrisk (diesel)',
'Bekräftad, stor världsomfattande återkallelse: 848 517 fordon (C-, E-, G-, S-klass samt CLS/GLC/GLE/GLS) med OM654/OM656-diesel byggda jan 2017–okt 2021. Vakuumstyrd kylvätskepump/omkopplingsventil kan läcka mellan kylvätske- och vakuumkretsen; om kylvätska når den elektriska omkopplingsventilen kan en elektrokemisk reaktion ge överhettning, med brandrisk och risk för nedsatt bromsverkan. Berör INTE den amerikanska marknaden (diesel såldes inte där). Mercedes saknade inledningsvis reservdelar och rådde ägare att köra minimalt tills åtgärd fanns. Åtgärd: mjukvaruuppdatering och byte av omkopplingsventil (ca 1 tim), kostnadsfritt. Köpråd: kontrollera hos verkstad att återkallelsen är utförd.',
'https://car-recalls.eu/recall/mercedes-benz-c-class-2017-coolant-pump-fire/'),

('Mercedes-Benz','E-klass', 2017, 2021, 'Diesel', 'high', 'recall', 'kylvatskepump_brandrisk_eklass', 'Återkallelse: kylvätskepump brandrisk (E-klass diesel)',
'E-klass W213 med OM654/OM656-diesel byggd jan 2017–okt 2021 ingår i kylvätskepumpsåterkallelsen (848 517 fordon globalt). Läckande pump/omkopplingsventil ger brandrisk. Berör inte den amerikanska marknaden. Köpråd: verifiera att åtgärden (byte av ventil + mjukvara) är utförd innan köp.',
'https://forums.mbclub.co.uk/threads/daimler-warning-to-car-owners-of-fire-risk.280219/'),

('Mercedes-Benz','GLC', 2017, 2021, 'Diesel', 'high', 'recall', 'kylvatskepump_brandrisk_glc', 'Återkallelse: kylvätskepump brandrisk (GLC diesel)',
'GLC X253 med OM654-diesel byggd jan 2017–okt 2021 omfattas av kylvätskepumpsåterkallelsen (848 517 fordon globalt). Brandrisk vid kylvätskeläckage in i vakuum-/elsystem. Köpråd: kontrollera återkallelsestatus.',
'https://www.carexpert.com.au/car-news/multiple-mercedes-benz-models-recalled'),

-- ============ ÅTERKALLELSE: DIESELUTSLÄPP MJUKVARA (KBA) ============

('Mercedes-Benz','C-klass', 2014, 2018, 'Diesel', 'medium', 'recall', 'diesel_utslapp_mjukvara_kba', 'Återkallelse: dieselutsläpp mjukvaruuppdatering (KBA)',
'Enligt tyska KBA:s förelägganden genomför Mercedes obligatoriska dieseluppdateringar sedan 2018 på grund av otillåtna urkopplingsfunktioner ("thermofönster") i motorstyrningen. 2018 års föreläggande gäller enligt Mercedes-Benz Group enbart bilar med utsläppsklass Euro 6b och berör bl.a. C-klass 1.6-liters diesel (OM626) och GLC 2.2-liters diesel; senare KBA-order (2019 m.fl.) och EU-domstolens praxis (2022) rör "thermal windows" i OM651. Mjukvara uppdateras, ibland byts NOx-givare. Köpråd: kontrollera att bilen fått uppdateringen (annars risk för avställning).',
'https://group.mercedes-benz.com/technology/diesel/recall-faq.html'),

-- ============ LADDHYBRID (PHEV): PTC-VÄRMARE/HÖGVOLT ============

('Mercedes-Benz','C-klass', 2015, 2021, 'Laddhybrid', 'high', 'electrical', 'phev_ptc_hogvolt_varning_cklass', 'Laddhybrid: PTC-värmare ger högvoltsvarning/startstopp',
'Mercedes TSB LI83.70-P-064480 (gäller modell 205 C-klass hybrid) beskriver "högvoltsbatterivarning" i instrumentklustret med möjligt startstopp och avbruten laddning. Orsak: fukt/korrosion i 12V-kontakten till högvolts-PTC-värmaren (N33/5), felkoder P0A0B00/P0A0A00/B10BE00. PTC-värmaren kan dra ner hela högvoltsnätet för att skydda batteriet. Åtgärd: byte av PTC-värmarbooster. OBS: ingen formell säkerhetsåterkallelse, hanteras via TSB. Köpråd: kontrollera "half power"/laddningsfel och att TSB-åtgärd är utförd.',
'https://static.nhtsa.gov/odi/tsbs/2019/MC-10162197-9999.pdf'),

('Mercedes-Benz','GLC', 2016, 2022, 'Laddhybrid', 'high', 'electrical', 'phev_ptc_hogvolt_varning_glc', 'Laddhybrid: PTC-värmare ger högvoltsvarning (GLC)',
'GLC350e/GLC300e (modell 253) omfattas av samma TSB (LI83.70-P-064480): högvoltsvarning i klustret, möjligt startstopp och laddningsavbrott på grund av fukt/korrosion eller isolationsfel i PTC-värmaren. Diagnos har visat PTC-värmare med isolationsfel mot jord. Köpråd: provkör, kontrollera laddning och felkoder, verifiera TSB-åtgärd.',
'https://www.mbeqclub.com/threads/c300e-2023-depleted-high-voltage-battery.3681/'),

('Mercedes-Benz','C-klass', 2015, 2018, 'Laddhybrid', 'high', 'electrical', 'phev_hogvoltsbatteri_kostnad', 'Laddhybrid: dyrt högvoltsbatteribyte (första generationen)',
'Första generationens C350e-högvoltsbatteri (W205, ca 2015–2018) har rapporterats haverera med isolationsfel; Mercedes-verkstäder har offererat 10 000–15 000 GBP (ca 14 000 EUR) för batteribyte, och batterier har varit svåra att få tag på. Amerikanska RepairPal uppskattar batteribyte för C350e Hybrid till 22 399–22 707 USD (GLC350e 20 265–20 455 USD) — siffror från en annan marknad men illustrerar kostnadsnivån. Oberoende hybridspecialister kan renovera paket billigare. Köpråd: undvik exemplar med aktiva batterivarningar; ett batterihaveri kan överstiga bilens värde.',
'https://forums.mbclub.co.uk/threads/c350e-quoted-14k-for-replacing-battery.294761/'),

('Mercedes-Benz','GLC', 2020, 2020, 'Laddhybrid', 'high', 'recall', 'glc350e_vaxelharva_recall', 'Återkallelse: växellådskablage skaver (GLC350e)',
'Bekräftad återkallelse (NHTSA 21V-197, expansion av 20V-651) för 2020 GLC350e: växellådans kablage kan vara felaktigt draget och skava mot främre drivaxeln, vilket kan orsaka effektbortfall. Åtgärd: inspektion/byte av kablage, kostnadsfritt. Köpråd: kontrollera att åtgärden är utförd på berörda 2020-exemplar.',
'https://www.cars.com/research/mercedes_benz-glc_350e/recalls/'),

-- ============ VÄXELLÅDA: 9G-TRONIC ============

('Mercedes-Benz','C-klass', 2014, 2016, NULL, 'medium', 'gearbox', '9g_tronic_mekatronik', '9G-Tronic: mekatronik-/ventilhusfel',
'Nio-stegslådan 9G-Tronic (725.0) styrs av en mekatronikenhet (kombinerad TCU och hydraulisk ventilkropp). Tidiga leveranser (2014–2015) hade mekatronikproblem; tryckgivare (felkoder P07B700, P073E00) är en känd svag punkt. Symptom: ryckiga växlingar, nödprogram/begränsad funktion, ibland endast 3:e växeln, backväxel som inte går i. Reparation ofta hela ventilkroppen; 15 000–40 000 kr. Köpråd: provkör i låg fart, känn efter ryck vid växling och backning, kontrollera oljebyte var 8 000:e mil.',
'https://www.ecutesting.com/common-faults/mercedes/9g-tronic-problems/'),

('Mercedes-Benz','E-klass', 2016, 2022, NULL, 'medium', 'gearbox', '9g_tronic_parkeringsparr', '9G-Tronic: parkeringsspärr (park pawl)',
'W213 med 9G-Tronic (725.0) har dokumenterade fel på parkeringsspärren (park pawl): felkoder P07B571 (spärrens sensor/aktuator blockerad) och P07E400 (parkering kan ej läggas i), meddelande "N permanent aktiv" och att bilen försöker lägga sig i N/P vid avstängning. Verkstäder har fått byta hela ventilkroppen. OBS: inga formella NHTSA-säkerhetsåterkallelser hittades specifikt för park pawl (en separat rollaway-återkallelse 2026, NHTSA 26V-481, rör dörrlåsmikrobrytare — inte samma fel). Köpråd: kontrollera att P kan läggas i ordentligt och att bilen står still i P i backe.',
'https://mhhauto.com/Thread-Mercedes-E200d-W213-725-0-9G-Tronic-Park-Pawl-issues'),

-- ============ LUFTFJÄDRING: AIRMATIC (GLC) ============

('Mercedes-Benz','GLC', 2015, 2022, NULL, 'medium', 'other', 'airmatic_luftfjadring_glc', 'AIRMATIC-luftfjädring: läckage/kompressorfel (GLC)',
'GLC (tillval AIRMATIC, främst GLC 300 och uppåt inkl. AMG 43) kan drabbas av luftfjädringsfel: läckande luftbälgar, defekt kompressor, ventilblock eller nivågivare. Symptom: "Suspension malfunction/Visit workshop", bilen sjunker/står ojämnt eller fastnar i höjt läge. Reparation kostsam: luftbälg 5 000–12 000 kr, kompressor 8 000–15 000 kr. Köpråd: kontrollera att bilen står jämnt efter stillastående natt och att fjädringen höjer/sänker korrekt.',
'https://mbworld.org/forums/glc-class-x253/863668-airmatic-stuck-raised-position-malfunction-help.html'),

('Mercedes-Benz','GLC', 2015, 2019, NULL, 'medium', 'electrical', 'glc_vattenintrangning_torpedvagg', 'GLC: vatteninträngning via torpedvägg',
'Vissa GLC X253-ägare rapporterar vatten som tränger in i kupén via bristfälliga svetsar i torpedväggen, typiskt på passagerarsidan, med risk för fuktskadad elektronik. Reparationskostnad 3 000–25 000 kr beroende på omfattning. Köpråd: känn efter fukt/möglukt i fotutrymmen och under mattor.',
'https://www.carchecker.pro/reports/mercedes_glc_220d_x253.html'),

-- ============ ELEKTRONIK/ÅTERKALLELSER: W206/C254 OCH SENARE ============

('Mercedes-Benz','C-klass', 2022, 2026, NULL, 'medium', 'electrical', 'w206_mbux_skarmfel', 'MBUX-skärm: svart/omstart under körning (W206)',
'W206 C-klass med MBUX kan få skärmfrysningar, svart mittdisplay och digital instrumenttavla samt USB-modulfel. Bekräftad NHTSA-återkallelse i maj 2026 (144 049 bilar; 2024–2026 AMG GT, C-klass, E-klass, SL, CLE och GLC, produktion 19 sep 2022–6 feb 2026) för infotainmentmjukvara som kan ge systemomstart där både mittskärm och förarklustret tillfälligt slocknar (förlorad hastighetsmätare/backkamera) under körning. Åtgärd: gratis mjukvaruuppdatering (OTA, inget hårdvarubyte krävs). Köpråd: kontrollera mjukvaruversion och att återkallelsen är utförd.',
'https://www.go-parts.com/garage/info-gps-tv-screen-mercedes-benz-cclass-mercedes-benz-c-class-mercedes-benz-glcclass-2022-2026'),

('Mercedes-Benz','GLC', 2023, 2026, NULL, 'medium', 'electrical', 'c254_mbux_skarmfel', 'MBUX-skärm: svart/omstart under körning (GLC C254)',
'GLC C254 med MBUX omfattas av samma bekräftade NHTSA-återkallelse i maj 2026 (144 049 bilar) för mjukvara som kan ge systemomstart och tillfälligt svart mittskärm/instrumentkluster under körning. Åtgärd: gratis mjukvaruuppdatering (OTA). Köpråd: verifiera återkallelsestatus och senaste mjukvara.',
'https://www.go-parts.com/garage/infotainment-display-mercedes-benz-glc-class-mercedes-benz-c-class-mercedes-benz-cle-class-2022-2026'),

('Mercedes-Benz','C-klass', 2021, 2023, NULL, 'high', 'recall', 'branslepump_effektbortfall_cklass', 'Återkallelse: bränslepump kan stanna (C-klass)',
'Bekräftad återkallelse (143 551 fordon i den initiala kampanjen, senare utökad) för 2021–2023 C-klass, E-klass, S-klass, CLS, SL, AMG GT, GLC, GLE, GLS och G-klass: ett internt material i bränslepumpen (impellern) kan vara felaktigt och gå sönder i förtid, vilket kan stänga av pumpen och ge effektbortfall under körning — ökad krockrisk. Innan stopp kan motorn gå ojämnt med varningslampor. Åtgärd: byte av bränslepump, kostnadsfritt. Köpråd: kontrollera att pumpen bytts på berörda exemplar.',
'https://www.cars.com/research/mercedes_benz-c_class/recalls/'),

('Mercedes-Benz','GLC', 2023, 2026, NULL, 'high', 'recall', 'glc_styrkoppling_bult_recall', 'Återkallelse: lös styrkopplingsbult (GLC C254)',
'Bekräftad återkallelse (NHTSA 25V533, rapportdatum 20 aug 2025, ägarbrev 6 okt 2025), 3 749 fordon: 2023–2026 GLC (GLC 300, GLC 300 4MATIC, AMG GLC 43, GLC 350e, AMG GLC 63 S E m.fl.) och EQE. Ett produktionsglapp gjorde att styrkopplingsbulten kan ha missats i åtdragningsprocessen, vilket kan göra att styrkopplingen lossnar från styrväxeln — risk för förlorad styrning. Åtgärd: åtdragning av bult, kostnadsfritt. Köpråd: kontrollera återkallelsestatus omgående på berörda GLC.',
'https://static.nhtsa.gov/odi/rcl/2025/RCAK-25V533-2906.pdf'),

('Mercedes-Benz','C-klass', 2022, 2023, NULL, 'high', 'recall', 'jordanslutning_kablage_overhettning', 'Återkallelse: elkablage-jord kan överhettas (W206)',
'Bekräftad återkallelse för 2022–2023 C300 och 2023 AMG C43: jordanslutningarna för elkablaget kan vara felaktigt säkrade så att kablaget överhettas — brandrisk. Åtgärd: inspektion/reparation av jordanslutningar, kostnadsfritt. Köpråd: kontrollera att åtgärden är utförd.',
'https://www.cars.com/research/mercedes_benz-c_class-2022/recalls/')
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
