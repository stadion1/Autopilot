-- Verifierade known_issues-rader för BMW (2026-08-14)
-- Källa: Claude Deep Research + manuell verifiering mot NHTSA/tysk-/svensk
-- press för de tyngsta recall-raderna. Researchens råtext saknade svenska
-- diakritiska tecken (å/ä/ö) genomgående — skrivet om med korrekt svenska
-- här, samma sakinnehåll.
--
-- 6 av de tyngsta claimen stickprovsverifierade: startrelä-brandrisk
-- (>1,1 miljoner globalt, 196 355 i USA, NHTSA-bekräftad), Continental
-- integrerat bromssystem (24V-104, 79 670 i USA), B58-startmotorelektronik
-- (24V-576, >100 000 i USA), diesel-EGR-kylarens brandrisk (18V-755,
-- expanderad till ~800 000 globalt), PHEV-batteribrand (20V-601, 4 509 i
-- USA/26 900 globalt — exakt matchande researchens siffror), och B58-
-- oljepumpens avsaknad av officiell recall (bekräftat: "As of early 2026,
-- there is no official safety recall from BMW for this specific issue").
-- Alla stämde. Ingen svag källa hittad. Inga dubbletter mot de 3 redan
-- seedade BMW-raderna (N20/N52-motorernas äldre problem, G30 iDrive 6 —
-- alla utanför den här batchens ämnen/generationer) eller mot resten av
-- seed.sql.

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
