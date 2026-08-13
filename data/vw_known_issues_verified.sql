-- Verifierade known_issues-rader för Volkswagen (2026-08-13)
-- Källa: Claude Deep Research + manuell verifiering mot NHTSA, KBA/DVSA-
-- refererande press för de tyngsta recall-raderna.
--
-- Ändringar mot researchens råa output:
-- - Normaliserade fuel_type till samma versalkonvention som resten av
--   databasen: 'bensin'->'Bensin', 'el'->'El', 'laddhybrid'->'Laddhybrid'
--   (funktionellt ofarligt — getLiveKnownIssues() matchar med ilike, dvs.
--   case-insensitive — men inkonsekvent med alla andra rader annars).
-- - 10 recall-rader stickprovsverifierade (samtliga high-severity:
--   ID.4-batteribrand 26V030, ID.3-batteribrand UK, Golf/Tiguan bakre
--   spiralfjäder 42J5, Golf/Tiguan/T-Roc bromspedal-svetsfog, ID.4
--   dörrhandtag 24V651, Passat GTE HV-säkring 93N4). Alla stämde exakt
--   mot NHTSA/KBA-originalkällor. Ingen dubblett hittad mot de 4 redan
--   seedade VW-raderna (DQ200-ryck Golf 2013-2016, Golf 8-infotainment
--   2019-2022, EA288 EGR Passat 2014-2018, ID.3-lanseringsbuggar
--   2020-2021) eller mot resten av seed.sql.

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
