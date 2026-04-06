# DB nuovo command

Questo file descrive una proposta dati aggiornata per Flowpulse v4.
Non e' uno script definitivo da lanciare tutto insieme.

## Idea attuale

- `User` gestisce autenticazione e sessione
- `Profile` rappresenta l'identita' della persona dentro Flowpulse
- `ProfileData` contiene i dati protetti del profilo
- un `Profile` puo' creare `Lead` e avere `Contact`
- la mappa contiene `JourneyTemplate`
- i `JourneyTemplate` hanno una fase del ciclo di vita
- in fase `validation` possono generare `JourneyInstance`
- le `JourneyInstance` rappresentano le percorrenze reali
- in fase `service` il template puo' avere un `Service` con configurazione operativa
- i ticket appartengono all'esecuzione reale, non al template astratto

## 1. Core iniziale consigliato

```bash
rails g authentication

bin/rails g scaffold Profile user:references display_name:string slug:string bio:text visibility:string
bin/rails g scaffold ProfileData profile:references first_name:string last_name:string email:string phone:string date_of_birth:date place_of_birth:string tax_code:string vat_number:string address:text city:string zip:string country:string share_level:string
bin/rails g scaffold Lead profile:references name:string email:string phone:string note:text status:string
bin/rails g scaffold Contact profile:references lead:references target_profile_id:bigint label:string status:string note:text

bin/rails g scaffold Branch profile:references name:string slug:string kind:string visibility:string description:text
bin/rails g scaffold Domain branch:references host:string name:string language:string visibility:string
bin/rails g scaffold Map branch:references name:string slug:string description:text visibility:string

bin/rails g scaffold JourneyTemplate map:references name:string slug:string description:text phase:string visibility:string start_x:integer start_y:integer end_x:integer end_y:integer

bin/rails g scaffold EventDate user:references journey_template:references name:string description:text event_type:string date_start:datetime date_end:datetime duration_minutes:integer position:integer x:integer y:integer

bin/rails g scaffold JourneyLink from_journey_template:references to_journey_template:references link_kind:string label:string

bin/rails g scaffold Resource journey_template:references event_date:references title:string description:text resource_type:string content:text url:string position:integer
```

## 2. Secondo blocco: esecuzione reale del journey

```bash
bin/rails g scaffold JourneyInstance journey_template:references user:references mode:string status:string started_at:datetime ended_at:datetime notes:text
bin/rails g scaffold InstanceEvent journey_instance:references event_date:references title:string description:text date_start:datetime date_end:datetime duration_minutes:integer status:string
```

## 3. Terzo blocco: servizio operativo

```bash
bin/rails g scaffold Service journey_template:references name:string description:text delivery_mode:string status:string price:decimal
bin/rails g scaffold Role service:references name:string kind:string
bin/rails g scaffold Ticket journey_instance:references instance_event:references user:references role:references status:string price:decimal
```

## 4. Significato dei modelli

### Branch

- appartiene a un profilo
- puo' rappresentare un brand
- puo' rappresentare una cartella di brand
- puo' essere pubblico o privato

### Domain

- collega un dominio a un branch
- in futuro serve per capire quale home mostrare

### Map

- e' una mappa appartenente a un branch
- contiene i journey template

### JourneyTemplate

- e' il journey presente sulla mappa
- e' la struttura principale del percorso
- ha coordinate di inizio e di fine
- puo' avere eventi collegati direttamente
- puo' avere link verso altri journey template

Campo importante:

- `phase`
  - `exploration`
  - `validation`
  - `service`

### EventDate

- e' l'unita' operativa reale prevista dentro un journey template
- in fase di esplorazione puo' essere collegato direttamente al template
- puo' rappresentare una lezione, un quiz, una consulenza, una prova o un altro evento

Campi utili:

- `event_type`
- `position`
- opzionalmente `x`, `y` se un giorno si decide di mappare anche i singoli eventi

### JourneyLink

- collega la fine di un journey template con l'inizio di un altro
- serve per costruire il grafo dei percorsi

### Resource

- contiene il materiale collegato a un evento o a un journey template
- sostituisce il vecchio nome `Post`

Puo' rappresentare:

- testo
- quiz
- video
- materiale lezione
- traccia consulenza

### JourneyInstance

- rappresenta una percorrenza reale di un journey template
- serve soprattutto quando il template e' in fase `validation`

Campo importante:

- `mode`
  - `autonomy`
  - `guided`

### InstanceEvent

- rappresenta l'evento reale generato durante una journey instance
- permette di non sporcare il template con i dati di esecuzione

### Service

- entra quando un journey template e' in fase `service`
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

- il journey e' ancora in costruzione
- si possono aggiungere direttamente `EventDate` al `JourneyTemplate`
- non serve ancora una struttura pesante di esecuzione

### Fase validation

- il journey e' abbastanza stabile da essere percorso
- qui si possono creare `JourneyInstance`
- le `JourneyInstance` possono essere:
  - `autonomy`
  - `guided`

### Fase service

- il journey diventa servizio operativo
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
9. journey_template
10. event_date
11. journey_link
12. resource
13. journey_instance
14. instance_event
15. service
16. role
17. ticket
