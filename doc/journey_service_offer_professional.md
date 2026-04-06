# Journey, Service, Offer, Professional

## Obiettivo

Fissare una struttura di dominio che distingua chiaramente:

- valore del percorso
- valore del servizio
- valore del professionista
- valore finale dell'offerta

## 1. Journey

Il `Journey` resta il percorso.

Ha gia' queste caratteristiche:

- `phase`
  - `exploration`
  - `validation`
  - `service`

- `journey_kind`
  - `standard`
  - `personalized`

Il `Journey` porta con se' il valore intrinseco del percorso:

- contenuto
- struttura
- tappe
- esplorazione
- validazione
- efficacia del journey

Questo puo' essere pensato come `journey_value`.

## 2. Service

Il `Service` raccoglie il modo di erogazione del journey.

Va associato a un `Journey` e tiene dentro:

- `delivery_mode`
- ruoli
- ricompense
- impostazione del servizio
- logica di erogazione
- valore base del servizio

Nomi possibili per il valore del servizio:

- `service_value`
- `service_base_value`
- `base_price`

Per ora i nomi piu' coerenti restano:

- `delivery_mode`
- `service_value`

## 3. Professional

Il `Professional` non coincide con il solo ruolo.

Tiene dentro:

- professione
- titoli
- gallery dei diplomi ufficiali
- formazione istituzionale
- formazione interna o privata
- qualificazione professionale

Qui esiste un valore professionale potenziale, pensabile come:

- `professional_value`

Questo valore non deve essere per forza sempre applicato.
Il professionista puo' decidere se applicarlo oppure no quando eroga un percorso o un servizio.

## 4. Offer

Il quarto oggetto non va pensato solo come collegamento tecnico tra servizio e professionista.

Deve rappresentare una proposta concreta:

- apribile
- quotabile
- preventivabile
- eventualmente prenotabile

Per questo il nome migliore, per ora, e':

- `ServiceOffer`

`ServiceOffer` rappresenta il punto in cui:

- un `Journey` entra nella logica di servizio
- un `Service` definisce la modalita' di erogazione
- un `Professional` puo' aggiungere il proprio valore
- il tutto diventa proposta concreta

Campi concettuali possibili:

- `service_id`
- `professional_id`
- `professional_value`
- `offer_value`
- `status`
- `bookable`
- `visible`

## Formula di valore

La lettura concettuale corretta e':

- `journey_value`
  valore del contenuto e dell'efficacia del percorso

- `service_value`
  valore della struttura di erogazione

- `professional_value`
  valore aggiunto del professionista che eroga

- `offer_value`
  valore finale della proposta concreta

Quindi:

- `offer_value = journey_value + service_value + professional_value`

oppure, in alcuni casi:

- il `journey_value` resta implicito nel servizio
- il prezzo finale viene letto soprattutto come `service_value + professional_value`

## Distinzione importante

Il `Role` non basta.

Serve distinguere:

- `role`
  funzione nel servizio

- `profession`
  identita' professionale riconosciuta

- `qualification`
  livello reale di competenza, formazione, metodiche, esperienza

## Pagine future di riferimento

### Lato Creator

Serve una pagina che riassuma:

- `Journey`
- `Service`
- `ServiceOffer`
- differenza tra `standard` e `personalized`
- differenza tra valore del percorso e valore del professionista

### Lato Professionisti

Serve una pagina che riassuma:

- professione
- titoli
- formazione istituzionale
- formazione interna
- `professional_value`
- differenza tra ruolo e identita' professionale

## Nota di progetto

Per ora questa struttura va fissata.

Non va ancora implementata come:

- listino completo
- preventivatore
- booking engine
- pricing engine definitivo
