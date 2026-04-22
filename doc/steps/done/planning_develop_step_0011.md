# Planning Develop Step 0011

## Stato

Completato e applicato nel codice.

## Obiettivo

Fissare e applicare la distinzione tra:

- `flowpulse` come hub di piattaforma
- `webapp_domain` come workspace contestuale del mondo

senza chiudere ancora il dettaglio dei ruoli futuri e dei contenuti interni.

## Decisioni fissate

### 1. Contesti principali

Esistono due contesti interni:

- `flowpulse`
- `webapp_domain`

`flowpulse` resta la regia di piattaforma.

La `web app` del mondo resta il workspace del dominio attivo.

### 2. Workspace per contesto

Dentro `flowpulse` restano solo:

- `creator`
- `superadmin`

Dentro la `web app` del mondo restano:

- `creator`
- `professionista`
- `viaggiatore`

La `SeaChart` resta soprattutto uno strumento da `creator`.

### 3. Accesso anonimo nella web app

Un anonimo nella `web app` del mondo:

- vede la `home`
- vede solo gli `EarthNode` pubblici
- non entra nei `Port`
- non vede la `SeaChart`

### 4. Accesso autenticato nella web app

L'utente autenticato che entra nella `web app` del mondo parte come:

- `viaggiatore`

Quindi non esiste una vista separata "autenticato ma senza ruolo".

### 5. Membership del dominio

La membership del dominio non nasce al signup.

La regola fissata e':

- signup dal dominio
  - conserva il contesto del dominio di ingresso
- completamento profilo
  - crea la membership del dominio
  - assegna il ruolo base `viaggiatore`

### 6. Creator tra Flowpulse e mondo

Il `creator` entra da `flowpulse`.

`flowpulse` resta:

- hub creator
- punto di ingresso di piattaforma

Quando il creator seleziona il suo mondo:

- se esiste una `web app` pubblicata
  - entra nella `web app` del mondo
- se non esiste ancora
  - resta in `flowpulse`

Per ora si tiene una regola semplice:

- un `creator` gestisce un solo brand / mondo
- il multi-brand resta riservato al `superadmin`

La `carta_nautica` copre gia' la vista del mondo del creator, quindi per ora non serve uno switcher separato dei mondi nel dashboard.

### 7. Pagine comuni

Le pagine comuni tra `flowpulse` e `web app` sono:

- `aside`
- `profilo`
- `impostazioni`

Il profilo resta unico.

Quello che cambia e' il contesto di navigazione, non il profilo in se'.

Dentro la `web app` il `creator` vede anche la mappa completa del brand, non solo il `Port` `web_app`.

### 8. Development locale

In development il domain context non deve essere fisso nel config.

Su `localhost`:

- il fallback resta `flowpulse.net`
- il dominio simulato puo' essere cambiato dinamicamente
- l'override resta in sessione solo per development

Questo serve a simulare il passaggio tra `flowpulse` e `web app` diverse senza riavviare.

## Gia' applicato nel codice

- workspace disponibili in base a `flowpulse` o `webapp_domain`
- default workspace coerente col contesto
- ingresso creator da `flowpulse` alla `web app`
- ritorno creator dalla `web app` a `flowpulse`
- simulazione dominio in development via sessione
- regola iniziale: un brand per creator, multi-brand solo per superadmin

## Rimandato

- dettaglio reale del ruolo `professionista`
- dettaglio reale del ruolo `viaggiatore`
- naming futuro del ruolo oggi chiamato `professionista`
- journey del viaggiatore derivato da `EarthNode` di tipo `trail`
- cross-chart e regole avanzate di navigazione tra mappe

Questi punti restano nei `todonext`.

Riferimenti principali:

- `todonext/public_content_and_program_models.md`
- `todonext/operator_guide_teacher_professional_roles.md`
- `todonext/multi_role_sea_participation.md`
