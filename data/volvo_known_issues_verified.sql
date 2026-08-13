-- Verifierade known_issues-rader för Volvo (2026-08-13)
-- Källa: Claude Deep Research + manuell verifiering mot svensk press
-- (Vi Bilägare, SVT, GP, Ny Teknik, Mest Motor, Börskollen) och
-- internationella recall-register (NHTSA, tyska KBA).
--
-- Ändringar mot researchens råa output:
-- - Tog bort 'xc60_sensus_freeze' (dubblett av redan seedad 'volvo_xc60_sensus_freeze')
-- - Bytte källa på 's60_t8_hv_battery_fire'/'v60_t8_hv_battery_fire' från
--   classaction.org (svag källa) till Vi Bilägare (bekräftar samma recall)
-- - Rättade datum på 'xc60_brake_pedal_loose_bolts': kampanjen (R10289)
--   skickades ut dec 2024, inte nov 2019/2020 (defekten uppstod 2019,
--   men själva återkallelsen kom mycket senare)
-- - Lade till svensk-marknads-siffror där verifierat: T8-batteribrand
--   ~8 000 i Sverige, dieselinsugsrör ~86 000, bränsleledning ~37 000

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
