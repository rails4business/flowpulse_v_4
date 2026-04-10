# DB nuovo command

Questo file descrive una proposta dati aggiornata per Flowpulse v4.
Non e' uno script definitivo da lanciare tutto insieme.

## Idea attuale

- `User` gestisce autenticazione e sessione
- `Profile` rappresenta l'identita' della persona dentro Flowpulse
- `ProfileData` contiene i dati protetti del profilo
- un `Profile` puo' creare `Lead` e avere `Contact`
- la mappa contiene `Trail`
- i `Trail` hanno una fase del ciclo di vita
- quando un trail viene fissato come modello, riceve `template_published_at`
- in fase `validation` possono generare `Journey`
- i `Journey` rappresentano i viaggi reali della persona
- in fase `active` il trail puo' avere un `Service` con configurazione operativa
- i ticket appartengono all'esecuzione reale, non al template astratto

## 1. Core iniziale consigliato

```bash
rails g authentication

bin/rails g scaffold Profile user:references display_name:string slug:string bio:text visibility:string
bin/rails g scaffold ProfileData profile:references first_name:string last_name:string email:string phone:string date_of_birth:date place_of_birth:string tax_code:string vat_number:string address:text city:string zip:string country:string share_level:string
bin/rails g scaffold Lead profile:references name:string email:string phone:string note:text status:string
bin/rails g scaffold Contact profile:references lead:references target_profile_id:bigint label:string status:string note:text

bin/rails g scaffold Port profile:references name:string slug:string port_kind:integer visibility:integer description:text x:integer y:integer meta:jsonb published_at:datetime
bin/rails g scaffold SeaRoute profile:references from_port:references to_port:references name:string slug:string visibility:integer description:text meta:jsonb published_at:datetime
bin/rails g scaffold Domain port:references host:string name:string language:string visibility:string
bin/rails g scaffold Map port:references name:string slug:string description:text visibility:string

bin/rails g scaffold Trail map:references template_trail:references name:string slug:string description:text phase:string trail_kind:string visibility:string template_published_at:datetime start_x:integer start_y:integer end_x:integer end_y:integer

bin/rails g scaffold Event trail:references name:string description:text event_type:string date_start:datetime date_end:datetime duration_minutes:integer position:integer x:integer y:integer
bin/rails g scaffold Activity user:references event:references ticket:references title:string description:text role_name:string status:string notes:text happened_at:datetime

bin/rails g scaffold TrailLink from_trail:references to_trail:references link_kind:string label:string

bin/rails g scaffold Resource trail:references event_date:references title:string description:text resource_type:string content:text url:string position:integer
```

## 1.b Primo step reale su SeaRoute

Prima del core completo, il primo modello reale puo' essere `Searoute`.

Comando minimo proposto:

```bash
bin/rails generate model Searoute \
  profile:references \
  link_child_searoute:references \
  name:string \
  slug:string \
  searoute_kind:integer \
  position:integer \
  visibility:integer \
  description:text \
  meta:jsonb \
  published_at:datetime \
  ancestry:string
```

Distinzione gia' fissata in `searoute_kind`:

- `brand`
- `folder`
- `list`
- `map`

`searoute_kind` va salvato come `integer` nel database e letto come `enum` nel model.

Enum iniziale proposto:

```ruby
enum :searoute_kind, {
  brand: 0,
  folder: 1,
  list: 2,
  map: 3
}
```

Significato iniziale:

- `brand`
  - identita' o mondo principale

- `folder`
  - contenitore organizzativo

- `list`
  - raccolta lineare, tipo blog, articoli, book o un solo trail

- `map`
  - territorio con trail collegati

Per questo primo step:

- si implementa solo l'albero delle sea routes
- `ancestry` abilita il nested tree
- `link_child_searoute_id` permette a una sea route di funzionare anche come ponte verso un figlio collegato
- la pagina di riferimento e':
  - `public/flowpulse_v_4/1_flowpulse_albero_indice_mappe.html`
- `Domain`, `Trail`, `Journey`, `Event`, `Activity` e servizi restano fuori da questo primo rilascio

Nota di dominio:

- `ancestry`
  - definisce la gerarchia principale

- `link_child_searoute_id`
  - definisce un collegamento secondario verso un figlio
  - serve quando una sea route non e' solo contenitore ma anche nodo ponte tra un punto dell'albero e un altro tratto del territorio

## 2. Secondo blocco: viaggio reale della persona

```bash
bin/rails g scaffold Journey trail:references user:references mode:string status:string started_at:datetime ended_at:datetime notes:text
bin/rails g scaffold JourneyEvent journey:references event:references title:string description:text date_start:datetime date_end:datetime duration_minutes:integer status:string
```

## 3. Terzo blocco: servizio operativo

```bash
bin/rails g scaffold Service trail:references name:string description:text delivery_mode:string status:string price:decimal
bin/rails g scaffold Role service:references name:string kind:string
bin/rails g scaffold Ticket journey:references journey_event:references user:references role:references status:string price:decimal
```

## 4. Significato dei modelli

### Searoute

- appartiene a un profilo
- puo' rappresentare un brand
- puo' rappresentare una cartella di brand
- puo' rappresentare una list o una map
- puo' essere pubblico o privato
- organizza la struttura navigabile del creator

### Domain

- collega un dominio a una searoute
- in futuro serve per capire quale home mostrare

### Map

- e' una mappa appartenente a una searoute
- contiene i trail

### Trail

- e' il trail presente sulla mappa
- e' la struttura principale del percorso
- ha coordinate di inizio e di fine
- puo' avere eventi collegati direttamente
- puo' avere link verso altri trail

Campo importante:

- `phase`
  - `exploration`
  - `validation`
  - `active`

- `trail_kind`
  - `standard`
  - `personalized`

- `template_published_at`
  - se presente, il trail e' stato fissato come template
  - questa data e' piu' utile di un semplice boolean per capire qual e' la versione stabile

- `template_trail_id`
  - se presente, il trail deriva da un altro trail template
  - in questo caso il trail e' una derivazione o istanza del modello di partenza

### Event

- e' il contenitore condiviso previsto dentro un trail o journey
- puo' rappresentare una lezione, un quiz, una consulenza, una prova o un altro evento comune
- puo' avere ruoli, commitments e servizi collegati

Campi utili:

- `event_type`
- `position`
- opzionalmente `x`, `y`

### Activity

- e' la partecipazione concreta e personale di una persona a un `Event`
- puo' contenere ruolo, note, resoconto e stato individuale
- serve quando il diario personale non coincide con l'evento condiviso

### TrailLink

- collega la fine di un trail con l'inizio di un altro
- serve per costruire il grafo dei percorsi

### Resource

- contiene il materiale collegato a un evento o a un trail
- sostituisce il vecchio nome `Post`

Puo' rappresentare:

- testo
- quiz
- video
- materiale lezione
- traccia consulenza

### Journey

- rappresenta il viaggio reale della persona
- puo' attraversare uno o piu' trail
- serve soprattutto quando un trail e' in fase `validation`

Campo importante:

- `mode`
  - `autonomy`
  - `guided`

### JourneyEvent

- rappresenta l'evento reale generato durante un journey
- permette di non sporcare il template con i dati di esecuzione

### Service

- entra quando un trail e' in fase `active`
- contiene la configurazione operativa del percorso

Contiene o prepara:

- modalita' di erogazione
- prezzi
- ruoli
- ticket
- impostazioni del servizio

### Role

- ruolo disponibile dentro un service

### Ticket

- appartiene all'esecuzione reale
- non va collegato al template puro

## 5. Blocco utenti, profili, lead e contatti

### User

- gestisce autenticazione
- gestisce sessione e accesso tecnico

### Profile

- rappresenta l'identita' applicativa della persona dentro Flowpulse
- e' il proprietario iniziale del branch e del resto della struttura personale

### ProfileData

- contiene i dati protetti del profilo
- non tutti questi dati devono essere sempre visibili
- in futuro alcuni dati potranno essere condivisi solo con autorizzazione

Esempi:

- email
- telefono
- dati anagrafici
- indirizzo
- dati fiscali

### Lead

- e' una persona invitata, segnalata o ancora in ingresso
- non e' ancora necessariamente un profilo pieno del sistema

### Contact

- e' una relazione gestita da un profilo
- puo' riferirsi a un `Lead`
- in futuro puo' riferirsi anche a un altro `Profile`

Logica attuale:

- un `Profile` puo' invitare un `Lead`
- lo stesso `Profile` puo' avere un `Contact`
- un `Lead` puo' in futuro evolvere verso un profilo reale
- un `Contact` puo' essere il legame stabile nel grafo delle relazioni

## 5. Logica del flusso

### Fase exploration

- il trail e' ancora in costruzione
- si possono aggiungere direttamente `EventDate` al `Trail`
- non serve ancora una struttura pesante di esecuzione

### Fase validation

- il trail e' abbastanza stabile da essere testato
- qui si possono creare `Journey`
- i `Journey` possono essere:
  - `autonomy`
  - `guided`
- qui si puo' anche fissare una versione con `template_published_at`

### Fase service

- il trail diventa servizio operativo
- qui entra il modello `Service`
- ruoli, prezzi, ticket e logiche di erogazione si spostano sul servizio

## 6. Punti ancora da chiarire

Prima di generare davvero questi modelli va comunque chiarito meglio:

- se `Contact` deve puntare a `lead_id`, `target_profile_id`, o a entrambi
- se `Lead` e' solo commerciale o anche relazionale
- se `ProfileData` va spezzato in dati pubblici e dati privati
- quali campi devono essere davvero condivisibili con autorizzazione

## 7. Ordine suggerito

1. autenticazione
2. profile
3. profile_data
4. lead
5. contact
6. branch
7. domain
8. map
9. trail
10. event_date
11. trail_link
12. resource
13. journey
14. journey_event
15. service
16. role
17. ticket
