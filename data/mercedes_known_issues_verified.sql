-- Verifierade known_issues-rader för Mercedes-Benz (2026-08-14)
-- Källa: Claude Deep Research + manuell verifiering mot NHTSA för de
-- tyngsta recall-raderna. Denna gång korrekta svenska diakritiska tecken
-- genomgående i råtexten (efter explicit instruktion i prompten efter
-- BMW-passets encoding-miss).
--
-- 6 av 9 recall-rader stickprovsverifierade: kylvätskepumpens brandrisk
-- (848 517 fordon — exakt matchande researchens siffra, bekräftat ej
-- sålt i Nordamerika), MBUX-skärmåterkallelse (144 049, maj 2026),
-- 48V-jordanslutning brandrisk (~12 200, nära researchens 12 176),
-- GLC styrkopplingsbult (25V533, exakt 3 749), bränslepumpsåterkallelse
-- (143 551 initialt), GLC350e-kablageskavning (21V-197). Alla stämde.
-- Bra disciplin: researchen letade INTE upp en påhittad
-- högvoltsbatteri-recall för PHEV-modellerna (bekräftade att ingen
-- sådan finns för C/E/GLC, bara för de rena elbilarna EQE/EQS).
--
-- En ändring: rule_id 'glc_vatteninträngning_kaross' bytt till ASCII
-- 'glc_vattenintrangning_torpedvagg' (innehöll ett icke-ASCII-tecken,
-- inkonsekvent med alla andra rule_id i databasen). Ingen dubblett mot
-- de 2 redan seedade Mercedes-raderna (W205 rost 2014–2018, W213 Magic
-- Body Control 2016–2019 — researchen instruerades uttryckligen att
-- hoppa över dessa och gjorde det) eller mot resten av seed.sql.

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
