# Planning Develop Step 0009

## Stato

Da iniziare.

## Obiettivo

Separare in modo esplicito il livello pubblico dal livello interno/workspace.

## Decisione fissata

Il sistema deve usare due layout diversi in base al fatto che l'utente sia fuori o dentro lo spazio operativo.

Inoltre, `flowpulse.net` non va pensato come un `BrandDomain` salvato nel database.

Va pensato come un `domain context` di piattaforma:

- esterno al modello `BrandDomain`
- ma equivalente ai `BrandDomain` sul piano di layout, menu e routing

Quindi il sistema non deve ragionare solo in termini di `BrandDomain presente / assente`.

Deve ragionare in termini di `domain context` attivo:

- `flowpulse`
- `brand_domain`

### Fuori

- layout pubblico unico
- top nav orizzontale
- stesso impianto per `flowpulse.net` e per i `BrandDomain`
- differenze solo su tema, logo, contenuti e home custom

### Dentro

- layout workspace unico
- sidebar a sinistra
- menu variabile in base a dominio attivo e ruolo
- struttura pensata per strumenti e pagine operative, non per l'ingresso pubblico

## Perche'

La home pubblica non deve sembrare un backoffice.

La sidebar laterale ha senso negli spazi interni, dove l'utente lavora davvero nel sistema.

Il top nav ha senso nelle pagine pubbliche, dove l'utente entra, si orienta e capisce il dominio in cui si trova.

L'idea di `domain context` riduce la complessita':

- `Flowpulse` segue la stessa logica dei domini senza diventare un falso record in DB
- i `BrandDomain` restano domini reali persistiti
- layout e menu possono essere decisi in modo uniforme

## Matrice minima da usare

- `flowpulse` fuori
  - layout pubblico
- `flowpulse` dentro
  - layout workspace
- `brand_domain` fuori
  - layout pubblico
- `brand_domain` dentro
  - layout workspace

Quello che cambia non e' il fatto di avere o no un layout pubblico o una sidebar.

Cambia il `domain context`, che poi influenza:

- tema
- logo
- contenuti
- home
- voci menu disponibili

## Soglia minima da attuare adesso

Per partire semplici, la distinzione non va ancora costruita su tutti i ruoli e su tutte le future iscrizioni ai percorsi.

Va fissata una soglia minima:

- pubblico
  - pagine di ingresso
  - home
  - blog
  - `Port` pubblici
  - in futuro `Trail`, `Book`, `EventDate` e altri contenuti pubblici
- workspace
  - pagine operative interne
  - creator
  - professional
  - admin
  - profilo e strumenti interni

## Regola semplice per ora

- se una risorsa e' marcata come pubblica, puo' vivere nel layout pubblico
- se una risorsa e' operativa o di gestione, vive nel workspace
- ruoli, iscrizioni ai percorsi e permessi piu' fini arriveranno dopo

Questo vale anche per i contenuti che verranno:

- un `Port` puo' avere una parte pubblica e una parte interna
- un `Trail` potra' avere show/index pubblici ma gestione interna
- `EventDate`, step, libri e servizi seguiranno la stessa distinzione

## Focus minimo del sistema

Prima di complicare permessi e ruoli, il sistema deve riuscire ad uscire con alcuni primi oggetti reali:

- un libro
- il primo trail `Igiene Posturale`
- la cartella / mondo `Postura e fisiologia`
- almeno un servizio online pronto

Tutto il resto va trattato come estensione successiva, non come blocco iniziale.

## Outcome atteso

Alla chiusura dello step 0009 deve essere chiaro che:

- il pubblico usa un layout orizzontale unico
- il workspace usa una sidebar unica
- Flowpulse e i domini brand non divergono nella grafica pubblica
- `flowpulse.net` viene trattato come `domain context` di piattaforma, non come `BrandDomain` in DB
- dominio e ruolo influenzano il menu interno, non il fatto di avere o no la sidebar
- esiste una soglia minima chiara tra contenuto pubblico e gestione interna
