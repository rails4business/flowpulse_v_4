# Planning Develop Step 0002

## Stato attuale

- Esiste gia' una home pubblica iniziale di Flowpulse.
- Il dominio dati sta prendendo forma in `public/flowpulse_v_4/db_nuovo_command.md`.
- La distinzione corretta ora e':
  - `User` per autenticazione
  - `Profile` per identita' applicativa
  - `ProfileData` per dati protetti
  - `JourneyTemplate` per i percorsi sulla mappa
  - `JourneyInstance` per le percorrenze reali

## Step 2

### Obiettivo

Costruire la base di accesso e identita' della piattaforma prima di entrare nel dominio delle mappe.

Questo step serve a fissare:

- autenticazione
- profilo applicativo
- dati protetti del profilo
- primo ingresso autenticato
- distinzione tra home pubblica e area autenticata

### Stack confermato

- Rails server-first
- Hotwire
- Stimulus
- importmap-rails per JavaScript
- tailwindcss-rails per CSS

Linea guida:

- usare server rendering come base
- usare Stimulus solo per comportamento mirato
- evitare complessita' frontend premature

## Cosa dobbiamo fare

### 1. Autenticazione

- generare l'autenticazione base Rails
- attivare login, logout e sessione
- definire il redirect dopo login
- definire se la registrazione pubblica e' gia' attiva o no

Comando base:

```bash
rails g authentication
```

### 2. Profilo applicativo

- creare il modello `Profile`
- collegarlo a `User`
- decidere se il `Profile` nasce automaticamente alla creazione utente
- definire i campi minimi iniziali

Campi minimi proposti:

- `display_name`
- `slug`
- `bio`
- `visibility`

Comando base:

```bash
bin/rails g scaffold Profile user:references display_name:string slug:string bio:text visibility:string
```

### 3. Dati protetti del profilo

- creare il modello `ProfileData`
- collegarlo a `Profile`
- chiarire quali dati sono protetti
- predisporre la futura condivisione con autorizzazione

Campi iniziali possibili:

- `first_name`
- `last_name`
- `email`
- `phone`
- `date_of_birth`
- `address`
- `city`
- `zip`
- `country`
- `share_level`

Comando base:

```bash
bin/rails g scaffold ProfileData profile:references first_name:string last_name:string email:string phone:string date_of_birth:date address:text city:string zip:string country:string share_level:string
```

### 4. Flusso di ingresso

- lasciare la home pubblica come ingresso visitatore
- creare una prima area autenticata minima
- decidere dove atterra il superadmin

Prima proposta:

- visitatore: home pubblica
- utente autenticato: dashboard personale iniziale
- superadmin: dashboard personale oppure admin generale da confermare

### 5. Prima dashboard autenticata

Creare una dashboard minima che serva solo a confermare:

- utente autenticato
- profilo attivo
- spazio personale esistente

Contenuto minimo:

- nome profilo
- stato account
- accesso futuro ai branch
- accesso admin se superadmin

### 6. Ownership iniziale

- confermare che `Profile` e' il proprietario iniziale dei `Branch`
- mantenere `User` come livello tecnico
- mantenere `Profile` come livello dominio

### 7. Uso di Hotwire e Stimulus

Usarli in questo step solo dove portano valore chiaro:

- eventuali feedback del login
- piccoli componenti interattivi in dashboard
- modal, reveal, micro-comportamenti

Non usarli ancora per:

- logiche dati complesse lato client
- gestione stato distribuita nel browser
- UI applicative pesanti

## Deliverable attesi

Alla fine dello step 2 dovremmo avere:

- autenticazione funzionante
- `User` e `Profile` collegati
- `ProfileData` impostato come struttura iniziale
- home pubblica separata dall'area autenticata
- prima dashboard autenticata minima
- comportamento iniziale chiaro per il superadmin

## Tema da fissare: journey standard e journey professional-supported

Non tutti i journey attivi saranno dello stesso tipo.

Va distinta almeno questa doppia natura:

- `Journey standard`
  - nasce da esplorazione, test e validazione
  - puo' diventare un percorso efficace replicabile
  - il valore principale sta nella struttura del journey, nelle tappe e nei contenuti

- `Journey professional-supported`
  - e' un journey attivo sostenuto anche da uno o piu' professionisti
  - il valore non dipende solo dal contenuto del percorso
  - il valore dipende anche dall'esperienza, competenza o ruolo del professionista che eroga il servizio

Questo punto e' fondamentale perche':

- alcuni journey risolvono un problema grazie alla struttura del percorso
- altri journey funzionano grazie alla struttura piu' il supporto professionale
- nel tempo il sistema dovra' permettere di osservare i journey piu' efficaci
- dovremo capire quali passaggi funzionano davvero
- dovremo distinguere cio' che genera valore come contenuto da cio' che genera valore come esperienza professionale

Prima decisione da tenere aperta:

- non introdurre subito un modello `Professional`
- fissare pero' questo asse come parte futura del dominio

## Tema da fissare: asse professionale

Oltre ai livelli gia' chiari:

- viaggiatore
- creator
- superadmin

esiste anche un asse professionale che andra' modellato in futuro.

Le famiglie da considerare sono almeno queste:

- `professionisti con formazione esterna validata`
  - esempio: fisioterapia, medicina, consulenze riconosciute
  - hanno bisogno anche di una bacheca o area dedicata alla loro formazione e identita' professionale

- `professionisti interni`
  - esempio: tutor, insegnanti, segreteria, guide, figure formate dentro un brand o metodo
  - il loro valore dipende dalla formazione ricevuta all'interno del sistema o del branch

- `professionisti tecnici`
  - figure specialistiche o operative che supportano l'erogazione del servizio
  - non coincidono sempre con il contenuto del journey, ma possono essere essenziali per farlo funzionare

Questo significa che in futuro la sidebar e l'architettura dei ruoli non potranno fermarsi a:

- viaggiatore
- creator
- superadmin

ma dovranno probabilmente considerare anche una sezione o una logica professionale dedicata.

## Tema da fissare: ambiti e percorsi

Per non irrigidire troppo presto i ruoli professionali, la struttura futura dovrebbe essere pensata prima per ambiti o percorsi, e solo dopo per tipi di professionista.

Gli ambiti da fissare ora come riferimento sono:

- `salute`
- `business`
- `formazione`

Questa impostazione e' utile perche':

- il tipo di professionista puo' cambiare in base all'ambito
- i servizi e i pacchetti potrebbero avere logiche diverse in ambiti diversi
- la stessa figura puo' avere un senso differente in salute, business o formazione
- la futura UX puo' organizzarsi meglio per area di contesto invece che per elenco rigido di ruoli

Questa parte dovra' influenzare in futuro:

- ruoli
- servizi o pacchetti
- bacheche professionali
- dashboard dedicate
- lettura dei risultati dei journey

## Conseguenza strategica

Flowpulse non dovra' solo gestire:

- mappe
- journey
- viaggiatori
- creator

ma anche il rapporto tra:

- contenuti efficaci
- supporto professionale
- ambiti applicativi
- ruoli interni ed esterni

## Cose da non fare ancora

- costruire subito tutto il sistema `Lead`
- costruire subito tutto il sistema `Contact`
- partire subito con `JourneyTemplate`
- implementare subito `Service`
- implementare subito `Ticket`
- implementare subito `Professional`
- implementare subito gerarchie professionali complete
- implementare subito dashboard dedicate per ambiti `salute`, `business`, `formazione`

## Decisioni da chiudere prima di implementare

- il profilo si crea automaticamente oppure con onboarding?
- il superadmin atterra nella dashboard utente o direttamente nell'admin?
- la registrazione pubblica va attivata subito?
- `ProfileData` parte gia' completo o minimale?
- quando introdurre il primo asse professionale reale
- se i servizi futuri andranno chiamati `servizi` o `pacchetti`
- quando far emergere gli ambiti `salute`, `business`, `formazione` nella UX
