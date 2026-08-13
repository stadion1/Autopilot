-- Verifierade known_issues-rader för Toyota (2026-08-13)
-- Källa: Claude Deep Research + manuell verifiering mot NHTSA och
-- svensk press (Vi Bilägare, GP) för de tyngsta recall-raderna.
--
-- Ändringar mot researchens råa output:
-- - Lade till en rad researchen missade helt: 'yaris_epb_ecu_software'
--   (elektronisk parkeringsbroms, Yaris Hybrid juli 2020-april 2021),
--   en verklig europeisk återkallelse bekräftad av Vi Bilägare med
--   ~4 000 berörda svenska ägare — hittades under verifieringspasset,
--   inte i researchens ursprungliga 31 rader.
-- - Övriga 31 rader stickprovsverifierade (8 av 17 recall-rader,
--   inklusive de mest allvarliga: Denso-bränslepump, RAV4 Prime
--   DC/DC-brandrisk, Corolla styraxel-spricka, C-HR parkeringsbroms,
--   Land Cruiser krockkudde-bältesgivare, RAV4 motorblocksporositet,
--   RAV4 framre lankarm). Alla stämde exakt mot NHTSA-originalkällor.
--   Ingen svag källa (typ classaction.org) hittades i detta batch.

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
'Europeisk återkallelse (tillverkningsperiod juli 2020–april 2021), bekräftad av Vi Bilägare: ca 140 000 bilar i Europa, varav ca 4 000 i Sverige. Felaktig mjukvara i motorstyrenheten (ECU) på Yaris Hybrid kan göra att den elektroniska parkeringsbromsen inte går att lägga i eller inte går att lossa. Varningslampor tänds på instrumentpanelen. Den vanliga färdbromsen påverkas inte. Åtgärd: mjukvaruuppdatering hos auktoriserad verkstad, gratis. Kontrollera att åtgärden är utförd. (Denna rad hittades vid verifiering av researchen — saknades i ursprungsdatan.)',
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
