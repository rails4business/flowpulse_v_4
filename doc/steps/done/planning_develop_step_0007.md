# Planning Develop Step 0007

## Stato

Completato e archiviato in `done`.

## Obiettivo

Dopo aver chiuso nello step 0006 la direzione delle `SeaRoute`, lo step 0007 deve rendere il `BrandPort` raggiungibile dall'esterno tramite domini pubblici.

L'obiettivo non e' ancora costruire il livello terra, ma dare a un brand una vera porta di ingresso pubblica.

## Decisione principale

Un `BrandPort` puo' avere piu' domini.

Ogni dominio punta a un solo `BrandPort`.

Ogni dominio ha una lingua associata.

Questa e' la forma piu' semplice e utile per partire, perche':

- il `Port` resta il nodo centrale
- il brand diventa il nodo di ingresso pubblico
- il dominio diventa l'accesso pubblico del brand
- la lingua viene gestita come proprieta' del dominio
- si puo' pubblicare lo stesso brand su piu' ingressi linguistici

## Modello minimo da introdurre

Serve un modello dedicato, `BrandDomain`, con un perimetro minimo di questo tipo:

- `brand_port_id`
- `host`
- `locale`
- `primary`
- `published`

Scelta tecnica fissata:

- `BrandDomain` appartiene a `brand_port`
- `brand_port` e' un `Port`
- il `Port` referenziato deve essere di tipo `brand`

## Estensione utile da fissare subito

Prendendo come riferimento utile il vecchio modello `domains` presente in `public/flowpulse_v_4/schema_vecchio.rb`, questo step non dovrebbe fermarsi al solo collegamento host -> port.

Ha senso fissare da subito anche il ruolo editoriale e pubblico del dominio.

Per questo il modello puo' nascere con un primo gruppo di campi piu' ricco:

- `brand_port_id`
- `host`
- `locale`
- `primary`
- `published`
- `title`
- `seo_title`
- `seo_description`
- `description`
- `favicon_url`
- `square_logo_url`
- `horizontal_logo_url`
- `header_bg_color`
- `header_text_color`
- `accent_color`
- `background_color`
- `custom_css`

## SEO e identita' del dominio

Il dominio non e' solo un alias tecnico del brand.

Deve poter contenere anche le informazioni di presentazione pubblica:

- titolo SEO
- descrizione SEO
- favicon
- eventuali loghi dedicati
- colori strutturati del tema
- eventuale CSS custom per il dominio

Questo permette di trattare il dominio come vero entry point pubblico del brand, non come semplice redirect.

## Home del dominio

Qui conviene fissare una distinzione chiara.

Un dominio puo' usare:

- direttamente il `BrandPort` come home pubblica
- oppure una home dedicata del dominio, separata dal `BrandPort`, ma gestita dall'app

La distinzione non va modellata con un campo `home_mode`, perche' e' derivabile.

La regola semplice e':

- `home_page_key` assente -> home standard del `BrandPort` renderizzata direttamente sulla root del dominio
- `home_page_key` presente -> home dedicata del dominio

Conviene invece salvare una chiave controllata, ad esempio:

- `home_page_key`

Questa chiave punta a una homepage pubblica reale dell'app, gestita da controller, action e view dedicati.

Scelta tecnica fissata:

- niente `controller` e `action` liberi nel database
- niente `home_mode` ridondante
- niente `home_html` come soluzione principale
- `home_page_key` e' una chiave controllata dal codice applicativo
- ogni `home_page_key` valida mappa a una action pubblica dedicata di `BrandHomesController`
- il controller resta fisso: `BrandHomesController`
- `home_page_key` rappresenta quindi solo il nome dell'action ammessa

Questa scelta e' preferibile a `home_html`, perche':

- evita HTML libero nel database
- mantiene il versionamento nel codice
- consente SEO, partial e logica Rails vera
- permette di avere home dedicate di brand senza costruire subito un CMS complesso

## Navigazione pubblica

Anche la navigazione del dominio va fissata subito in forma minima.

La scelta consigliata e':

- non duplicare la navigazione per ogni dominio
- lasciare che i `Port`, i `Trail` e gli altri contenuti restino condivisi
- usare il dominio per personalizzare la home e l'identita', non l'intera struttura informativa

## Scelta consigliata per non complicare troppo lo step

Per evitare che lo step 0007 esploda troppo presto, la forma migliore secondo me e':

- associare domini a un `BrandPort`
- associare una lingua a ogni dominio
- aggiungere fin da subito i campi SEO e identita' base
- permettere una home custom del dominio tramite pagina dedicata dell'app
- mantenere condivise le altre pagine del brand e della sua rete

Non conviene invece in questo stesso passo:

- costruire un page builder vero
- salvare HTML libero come soluzione principale della home
- introdurre multi-lingua sullo stesso dominio
- legare subito la lingua al `Profile`
- costruire un sistema avanzato di menu annidati
- duplicare nav e struttura contenutistica per ogni dominio

## Regole del passo

Per ora valgono queste regole:

- un `BrandPort` puo' avere molti domini
- uno dei domini puo' essere principale
- ogni dominio rappresenta una sola lingua
- il dominio e' il punto di accesso pubblico al `BrandPort`
- il dominio puo' avere metadati SEO propri
- il dominio puo' avere identita' visuale propria
- il dominio puo' usare la home del `BrandPort` oppure una home custom gestita dall'app tramite `home_page_key`
- gli altri `Port`, le `SeaRoute`, i `Trail` e la struttura contenutistica restano navigabili dal brand
- i domini non appartengono a porti generici, ma solo a `Port` di tipo `brand`

## Perimetro del dominio

Prima di allargare davvero la navigazione pubblica, va fissata una regola strutturale semplice:

- il perimetro del dominio e' definito dal `brand_port_id`

Questo significa:

- un `BrandDomain` appartiene a un solo `BrandPort`
- il `BrandPort` proprietario definisce lo spazio pubblico iniziale del dominio
- tutti i `Port` che appartengono a quel brand tramite `brand_port_id` rientrano nello stesso spazio logico del dominio
- i `Port` che non appartengono a quel `brand_port_id` restano fuori dal perimetro del dominio

Questa regola viene prima della definizione dettagliata delle pagine pubbliche, perche' stabilisce quali nodi fanno parte dello stesso mondo pubblico.

## Cosa e' pubblico dentro il perimetro

Una volta fissato il perimetro tramite `brand_port_id`, la regola minima del pubblico e':

- il dominio deve essere `published` per essere risolto pubblicamente
- dentro quel dominio sono pubblici solo i `Port` con `visibility = published`
- il `BrandPort` proprietario del dominio resta il punto di ingresso pubblico del perimetro
- gli altri `Port` dello stesso perimetro possono comparire pubblicamente solo se pubblicati

Questa e' la soglia minima giusta per lo step 0007, perche' evita che la rete pubblica del brand esponga nodi draft o domini non ancora pronti.

## Perche' questo step viene prima di Trail

In questa fase la priorita' non e' far crescere il grafo interno, ma permettere alle persone di entrare davvero in un brand.

Quindi:

- prima l'accesso pubblico
- poi l'eventuale continuita' verso `Trail` e `Service`

## Outcome atteso

Alla chiusura dello step 0007 deve essere possibile:

- associare uno o piu' domini a un `BrandPort`
- indicare la lingua di ciascun dominio
- fissare un dominio principale
- salvare dati SEO e identita' base del dominio
- scegliere se la home pubblica e' il `BrandPort` oppure una home custom del dominio tramite pagina dedicata
- mantenere condivise le altre pagine pubbliche della rete del brand
- preparare il brand come entry point pubblico reale della mappa

## Checklist dei 7 punti

1. `BrandDomain` associato a `BrandPort`
Stato: base tecnica fatta, CRUD creator base fatto.

2. Lingua per dominio
Stato: campo `locale` presente e lasciato come stringa libera. Da verificare solo l'uso pubblico reale.

3. Dominio principale
Stato: base fatta. Esiste `primary` e il modello forza un solo dominio principale per brand.

Nota host fissata:

- `www.posturacorretta.org` e `posturacorretta.org` valgono come stesso host logico
- subdomain reali come `old.posturacorretta.org` restano distinti
- nel form creator va salvato sempre il dominio canonico senza `www`
- in production una richiesta su `www.` viene riportata al dominio canonico senza `www`

4. SEO dominio
Stato: base fatta. Il layout pubblico usa titolo, description, favicon, canonical e meta Open Graph in funzione del dominio attivo.

5. Tema dominio
Stato: base fatta. Colori, loghi e custom CSS vengono applicati alle pagine pubbliche del dominio e alla public show del brand port.

6. Home dedicata tramite `home_page_key`
Stato: base tecnica fatta. Se `home_page_key` e' presente il dominio passa a una action pubblica dedicata di `BrandHomesController`, altrimenti rende la home standard del `BrandPort` direttamente sulla root del dominio. E' stata introdotta una prima chiave reale: `posturacorretta_home`.

7. Rete condivisa del brand
Stato: base tecnica fatta. La root pubblica ora puo' aprire una home brand in base al dominio risolto. Da estendere poi alla navigazione completa della rete del brand.

Appunti da tenere per la chiusura finale del punto 7:

- prima chiarire il perimetro tramite `brand_port_id`
- poi definire cosa e' pubblico dentro quel perimetro
- per lo step 0007 la regola minima scelta e': dominio `published` + `Port` pubblicati nello stesso `brand_port_id`
- la resa pubblica dipendera' anche dal ruolo:
  - viaggiatore
  - professionista
  - creator
- la resa pubblica dipendera' anche dal tipo di nodo:
  - `brand`
  - `map`
  - `blog`
  - `book`
  - futuri `trail` e `service`

## Risoluzione del dominio

Nell'app corrente non esiste ancora una logica attiva che risolva il dominio pubblico in base a `request.host`.

Riferimento utile trovato:

- nel legacy esisteva una risoluzione centralizzata del dominio in `doc/legacy_flowpulse_v3/controllers/concerns/current_domain_context.rb`

Per l'app attuale conviene fissare questa regola:

- in production, se `request.host` e' `flowpulse.net`, si usa la home FlowPulse gia' esistente
- in production, se `request.host` corrisponde a un `BrandDomain`, si apre il brand secondo la configurazione del dominio
- in development, serve una simulazione esplicita del dominio mantenendo `localhost`

Logica ora creata:

- la risoluzione dell'host avviene centralmente in `ApplicationController`
- l'host risolto viene salvato in `Current.resolved_domain_host`
- il `BrandDomain` corrente viene salvato in `Current.brand_domain`
- in production, se l'host richiesto inizia con `www.`, l'app fa redirect 301 verso il dominio canonico senza `www`
- se l'host risolto e' `flowpulse.net`, l'app usa la home FlowPulse normale
- se l'host risolto corrisponde a un `BrandDomain`, `PagesController#home` passa alla home del brand
- se `home_page_key` e' presente, reindirizza verso una action pubblica dedicata del `BrandHomesController`
- se `home_page_key` e' assente o non risolvibile, il dominio rende la home standard del `BrandPort` sulla root
- se in production l'host non e' `flowpulse.net` e non corrisponde a nessun `BrandDomain`, l'app risponde con una pagina `domain_not_configured`
- le `home_page_key` ammesse vengono mantenute in una lista esplicita del modello `BrandDomain`

## Simulazione dominio in development

Per development conviene usare una configurazione esplicita di ambiente, non query param o sessione.

La regola fissata ora e':

- se l'app gira su `localhost`, usa un dominio simulato definito in `config/environments/development.rb`
- se il dominio simulato non e' impostato, fallback a `flowpulse.net`

Logica ora creata in development:

- `config.x.simulated_domain_host` definisce il dominio simulato locale
- se `request.host` e' `localhost`, l'app usa quel valore come host risolto
- per cambiare simulazione basta modificare la config development, senza toccare la URL
- la home pubblica mostra un indicatore visivo quando e' attiva una simulazione dominio locale
