# Planning Develop Step 0009

## Stato

Completato e archiviato in `done`.

## Obiettivo

Separare in modo esplicito:

- il livello pubblico
- il livello interno / workspace

senza trattare `flowpulse.net` come un falso `BrandDomain` nel database.

## Decisione fissata

Il sistema deve ragionare per `domain context` attivo:

- `flowpulse`
- `brand_domain`

Questi due contesti condividono la stessa logica di layout, ma non coincidono con lo stesso modello dati.

`flowpulse.net`:

- non e' un record `BrandDomain`
- e' un `domain context` di piattaforma

I domini reali del mondo restano invece modelli persistiti.

## Separazione dei livelli

### Fuori

- layout pubblico unico
- top nav orizzontale
- stesso impianto per `flowpulse.net` e per i domini del mondo
- differenze solo su tema, logo, contenuti e home custom

### Dentro

- layout workspace unico
- sidebar a sinistra
- menu variabile in base a dominio attivo e ruolo
- struttura pensata per strumenti e pagine operative

## Regola minima pubblico / interno

Per partire semplici:

- il pubblico ospita pagine di ingresso, home, blog e contenuti pubblici
- il workspace ospita creator, professional, admin, profilo e strumenti interni

Questa soglia minima vale anche per i modelli futuri:

- un oggetto puo' avere parte pubblica
- e parte interna di gestione

## Outcome

Alla chiusura dello step 0009 e' fissato che:

- il pubblico usa un layout unico orizzontale
- il workspace usa una sidebar unica
- `flowpulse.net` e i domini del mondo condividono la stessa logica pubblica
- `flowpulse.net` viene trattato come `domain context` di piattaforma, non come `BrandDomain` in DB
- dominio e ruolo influenzano il menu interno, non il fatto di avere o no la sidebar
