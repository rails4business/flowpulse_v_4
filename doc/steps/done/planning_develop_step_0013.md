# planning_develop_step_0013.md

## Focus

Dopo lo `0012`, il passo successivo non e' aprire subito tutti i modelli di journey/eventi/servizi.

Il focus dello `0013` e' costruire la struttura minima che permette:

- orientamento dentro una `web_app`
- linee di processo dentro i `Port`
- mappa terra dei percorsi
- apertura di percorsi standard
- base per il journey reale della persona

La catena da fissare e' questa:

- `Port`
- `Line`
- `Experience`
- `Station`

Formula:

- `Port` = ingresso / porto / scelta macro
- `Line` = binario o percorso
- `Experience` = unita' base del contenuto/percorso
- `Station` = nodo del percorso che lega una `Experience` a una `Line`

## Due Livelli Di Mappa

### Mare

Dentro una `web_app` serve una mappa principale del brand che orienta la persona tra i porti.

Questa mappa:

- e' relativa a quella `web_app`
- non coincide con la carta nautica creator globale
- usa i `Port` come nodi di orientamento
- serve a capire:
  - se si e' nel porto giusto
  - se bisogna entrare in un altro porto
  - se la strada e' gia' disponibile o solo da costruire

### Terra

Quando l'utente entra in un porto, si apre la mappa terra:

- `Line`
- `Station`

Questa e' la mappa del percorso concreto.

Importante:

- `Line` e `Station` non esistono solo nella `web_app`
- possono stare anche negli altri `Port`
- nella `web_app` servono come orientamento iniziale
- negli altri `Port` possono diventare linee di processo specifiche

## Struttura Minima Da Fissare

### `Line`

`Line` e' il percorso/binaro principale.

`Line` non e' un modello esclusivo della `web_app`.

Una `Line` appartiene al `Port` in cui viene usata.

Quindi:

- una `web_app` puo' avere linee di orientamento
- un altro `Port` puo' avere linee di processo proprie
- i model restano gli stessi
- cambia solo il contesto del porto

Per ora una `Line` puo' essere:

- `book`
- `blog`
- `folder`
- `trail`

Questa tipologia non va ancora chiusa in modo definitivo, ma va prevista.

`Line` deve poter rappresentare:

- un libro
- un blog
- un raccoglitore che collega piu' elementi
- un percorso vero e proprio

Campi minimi iniziali da implementare:

- `port_id`
- `name`
- `slug`
- `line_kind`
- `position`
- `description` opzionale

Scelta iniziale pratica:

- `position` come integer semplice
- niente ordinamento complesso nel primo passaggio

Prima tipologia minima da usare:

- `book`
- `blog`
- `folder`
- `trail`

### `Experience`

`Experience` entra prima di `Station`.

Una `Experience` appartiene al `Port` in cui viene usata.

Per ora si fissa che una `Experience` potra' essere:

- lezione
- quiz
- esercizio
- pagina
- video
- scheda

E piu' avanti potra' diventare anche:

- questionario
- modulo piu' complesso
- experience annidata

Campi minimi iniziali da implementare:

- `port_id`
- `name`
- `slug`
- `experience_kind`
- `position`
- `description` opzionale

Scelta iniziale pratica:

- `position` come integer semplice
- niente nesting nel primo passaggio

### `Station`

`Station` appartiene a una `Line` e a una `Experience`.

`Station`:

- e' la tappa visibile nella mappa terra
- collega una `Experience` a una `Line`
- puo' collegarsi a un'altra station
- puo' collegarsi anche a un `Port`

Per partire si usa una forma semplice:

- `Station`
  - `belongs_to :line`
  - `belongs_to :experience`
  - `belongs_to :link_station, class_name: "Station", optional: true`
  - `belongs_to :link_port, class_name: "Port", optional: true`

Regola:

- se due linee si incrociano
- la linea secondaria puo' avere una `station` con `link_station_id`
- se una station deve rimandare a un altro porto
- usa `link_port_id`
- non si apre ancora un modello `StationLink`

Campi minimi iniziali da implementare:

- `line_id`
- `experience_id`
- `name`
- `slug`
- `station_kind`
- `position`
- `description` opzionale
- `link_station_id` opzionale
- `link_port_id` opzionale

Scelta iniziale pratica:

- anche qui `position` come integer semplice
- niente struttura grafo piu' ricca nel primo passaggio

Prima tipologia minima da usare:

- `step`
- `branch`
- `gate`
- `page`

Nel `0013` il focus resta:

- `Line`
- `Experience`
- `Station`
- mappa terra creator

## Permessi Iniziali

Nel primo assetto dei ruoli:

- `Line` puo' essere creata e modificata solo dai `creator`
- `Station` puo' essere creata e modificata solo dai `creator`
- `Experience` puo' essere gestita sia dai `creator` sia dai `professional`

Questa distinzione serve a tenere separati:

- la struttura del percorso
- i contenuti e le unita' operative del percorso

## Prima Implementazione Consigliata

L'ordine suggerito e':

1. fissare `Line`
2. fissare `Experience`
3. fissare `Station`
4. collegare `Line` a `Port`
5. collegare `Experience` a `Port`
6. collegare `Station` a `Line`
7. collegare `Station` a `Experience`
8. aggiungere `link_station_id` e `link_port_id`
9. costruire una prima pagina creator tipo `mappa_metro`
10. usare la mappa terra per visualizzare una `Line` con le sue `Station`

Scelta di implementazione:

- prima CRUD creator semplice
- poi prima visualizzazione dinamica
- solo dopo la resa grafica metro vera e propria
- la destinazione grafica da raggiungere resta una vista simile a `mappa_metro.html`

## Parte Creator Da Costruire

Per i creator serve una pagina simile a:

- [`/flowpulse_v_4/mappa_metro.html`](/Users/marcobeffa/CODE_NOW/rails4b_2025/flowpulse_v_4/public/flowpulse_v_4/mappa_metro.html)

Questa pagina non parte subito da un editor grafico complesso.

Prima deve essere:

- dinamica
- letta dai dati
- navigabile

Pero' il primissimo passaggio non sara' ancora la mappa grafica finale.

Prima serve:

- CRUD creator di `Line`
- CRUD creator di `Experience`
- CRUD creator di `Station`
- lista leggibile delle station di una line
- base dati stabile

Solo dopo questa soglia ha senso trasformare la vista in mappa metro dinamica.

Quindi:

- un `Port` viene aperto nel creator
- le sue `Line` vengono lette dal DB
- le sue `Experience` vengono lette dal DB
- le sue `Station` vengono disegnate
- ogni station e' cliccabile
- se ha `link_station_id`, mostra un aggancio a un'altra station/line
- se ha `link_port_id`, mostra un aggancio a un altro porto

## Journey

Il `Journey` non si apre ancora come primo modello operativo del `0013`.

Pero' il senso finale resta questo:

- la persona entra nella mappa mare della web app
- sceglie un porto
- entra nella mappa terra
- clicca una station
- da li' si puo' aprire o aggiornare il `Journey`

Questa e' la direzione, ma il journey reale verra' dopo la fissazione di:

- `Line`
- `Experience`
- `Station`

## Obiettivo Dello Step

Lo `0013` deve portare a questo risultato:

- una struttura chiara `Port -> Line -> Experience -> Station`
- `Line` riusabili in tutti i `Port`, non solo nella `web_app`
- una prima mappa terra creator dinamica
- base corretta per journey e percorsi standard

Non e' ancora lo step dei questionari, degli eventi completi, dei servizi avanzati o del `webapp_sea_chart`, che slitta allo `0014`.
