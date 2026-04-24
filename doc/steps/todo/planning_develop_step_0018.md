# planning_develop_step_0018.md

## 🎯 Obiettivo

Dopo aver tenuto lo `0012` focalizzato su:

- `Content`
- `Port`
- home standard della web app

lo `0013` deve aprire il livello vivo e organizzativo del sistema.

## Punto iniziale da fissare

Le cose piu' importanti da affrontare all'inizio dello step sono:

- trovare il giusto spazio del `Week Planner`
- chiarire gli `Eventi`
- chiarire le `Persone`
- chiarire i `Percorsi`
- tenere presenti `Blog` e `Libro` come strumenti di distribuzione dei contenuti

## 1. Week Planner

Il `Week Planner` non va pensato come pagina isolata.

Va chiarito come spazio centrale in cui si incontrano:

- eventi
- persone
- percorsi
- organizzazione operativa

Il punto da chiarire e':

- qual e' il suo ruolo vero nel sistema
- quanto sia solo agenda
- quanto sia invece il luogo in cui il lavoro prende forma

## 2. Eventi

Gli `Eventi` sono una delle unita' piu' importanti del sistema vivo.

Da qui in poi vanno pensati come:

- elementi nel tempo
- elementi organizzativi
- elementi che coinvolgono persone
- elementi che possono far parte di un percorso

## 3. Persone

Le `Persone` non vanno lette solo come utenti astratti.

Nel sistema devono contare almeno:

- chi crea
- chi organizza
- chi partecipa
- chi viene seguito
- chi porta avanti uno o piu' percorsi

## 4. Percorsi

I `Percorsi` vanno letti come:

- insieme di eventi
- strutture vive che si sviluppano nel tempo

e vanno considerati almeno in due forme:

- i miei percorsi
- i percorsi delle persone

Questa distinzione e' importante per non ridurre il sistema a un solo punto di vista.

## 5. Blog e Libro

`Blog` e `Libro` restano necessari, ma non come centro della parte viva.

Servono soprattutto per:

- distribuire contenuti
- accompagnare i percorsi
- organizzare contenuti editoriali

La direzione da tenere e':

- `Blog` come `Line`
- `Libro` come `Line`
- post, pagine o capitoli come tappe della line

## Nota di metodo

Lo `0013` non deve partire subito da uno schema rigido di modelli.

Prima deve fissare questi poli principali:

- `Week Planner`
- `Eventi`
- `Persone`
- `Percorsi`
- `Blog`
- `Libro`

e solo dopo chiarire:

- cosa va modellato prima
- cosa puo' restare ancora in mock/view
- cosa passera' poi allo step successivo

## 🎯 Obiettivo

Definire il livello vivo minimo del percorso, prima della formalizzazione in `Line`.

## Primo passo concreto

Il primo passo concreto dello `0012` non e' ancora `Journey`.

Si parte da:

- `Content`

Perche' senza `Content` restano troppo vuoti:

- `Port`
- home della web app
- materiali delle esperienze
- note e schede minime

Quindi il primo `rails g` da fare davvero e':

- `Content`

## Soglia concreta da cui partire

Prima ancora dei modelli piu' astratti, lo step `0012` deve tenere presente una soglia reale molto pratica:

- la home di una `web app`
- un brand che abbia almeno un livello vivo oltre al solo creator
- materiali minimi da cui possano nascere eventi, esperienze, lezioni, servizi e percorsi

Per iniziare davvero a costruire un brand non basta il solo `creator`.

Nel dominio servono almeno:

- un `professionista` o un `operatore`, oltre al creator
- dei `viaggiatori`
- delle `Experience`
- degli `Event`
- delle schede / materiali / contenuti

Questo perche' altrimenti il dominio non ha abbastanza sostanza per essere usato davvero.

## Direzione pratica del brand

La sequenza concreta da tenere come bussola e' questa:

- prima il `creator` copre magari tutti i ruoli
- poi il brand inizia a vivere con:
  - esperienze personalizzate
  - attivita' in autonomia
  - attivita' in singolo con il professionista
  - attivita' di gruppo
- da queste prime esperienze nascono:
  - eventi
  - schede
  - lezioni
  - servizi
- solo dopo si strutturano meglio:
  - linee
  - percorsi standard
  - blog
  - libro
  - questionari
  - schede da fare

Quindi il punto non e' partire da una struttura perfetta, ma da un brand che abbia abbastanza vita reale per poter essere usato.

## Materiale vivo da cui partire

Le prime cose concrete da poter fare dentro il brand sono:

- attivita' in autonomia
- esperienze personalizzate
- esperienze con il professionista in singolo
- esperienze con il professionista in gruppo

Una parte importante e' anche costruire qualcosa che il viaggiatore possa fare in autonomia.

Queste attivita' autonome:

- possono esistere da sole
- possono essere accompagnate dal professionista
- possono diventare parte di un percorso piu' grande

Questa soglia e' importante perche' orienta sia la home della web app sia il modo in cui andranno pensati `Experience`, `Event`, `Journey` e `Content`.

## Punto 1 fissato

La struttura minima di partenza non usa piu' `Station`.

Il nome corretto diventa:

- `Experience`

`Experience` e' la tappa sorgente con:

- contenuto
- programma
- eventuali schede e materiali collegati

Il `Journey` contiene tappe concrete chiamate:

- `Event`

Ogni `Event` collega questi livelli:

- `Experience`
- `Service`
- `Activity`

### Significato dei modelli

#### Experience

E' una tappa sorgente riusabile del percorso.

Non e' ancora:

- una data di calendario
- una partecipazione concreta
- un'erogazione economica

Non appartiene in modo forte al `Journey`.

E' l'`Event` che puo' collegarsi a una `Experience`.

#### Event

E' la tappa concreta del `Journey` nel tempo.

L'`Event` puo' collegare:

- una `Experience` come contenuto/programma
- il `Service` come forma di erogazione
- le `Activity` come partecipazioni concrete delle persone coinvolte

#### Service

Descrive l'erogazione:

- durata
- modalita'
- numero persone
- online / offline
- altri parametri operativi

#### Activity

Descrive la partecipazione concreta di un individuo all'`Event`, con il suo ruolo.

Per il professionista, il valore economico iniziale non nasce come modello separato:

- vive dentro l'`Activity` del professionista

Lì potranno stare in seguito:

- costo
- guadagno
- compenso concordato
- quota o valore netto

## Punto 2 fissato

Il primo oggetto sorgente del percorso e':

- `Journey`

La `Line` non nasce come modello iniziale obbligatorio.

La regola fissata e':

- si parte da un `Journey`
- il `Journey` puo' essere personale, di gruppo o per un cliente
- da un `Journey` stabilizzato puo' nascere una `Line`

Quindi:

- `Journey`
  - e' il livello vivo, operativo, sperimentale o guidato
- `Line`
  - e' la formalizzazione successiva di una struttura che si e' chiarita

Questo evita di imporre una `Line` standard prima che il percorso sia stato davvero provato.

Allo stesso tempo resta aperta una possibilita' futura:

- una `Line` potra' anche essere progettata direttamente

ma nello step attuale la direzione di partenza e':

- `Journey` prima
- `Line` dopo

## Punto 3 fissato

Il `Journey` non ha un solo tipo.

Va letto su due assi distinti.

### Asse 1: forma del journey

Questo asse descrive come il journey e' costruito o sostenuto:

- `personalized`
- `guided`
- `structured`

#### Personalized

Journey costruito ad hoc.

Puo' nascere:

- da un professionista
- da un lavoro esplorativo
- da un caso personale o di gruppo

Non richiede una `Line` standard a monte.

#### Guided

Journey accompagnato da una guida o da un professionista.

Puo' essere:

- in validazione
- appoggiato a una struttura ancora in evoluzione
- sostenuto da una relazione di accompagnamento

#### Structured

Journey appoggiato a un `Service` strutturato.

Qui sono gia' piu' chiari:

- modalita'
- informazioni operative
- forma di erogazione

### Asse 2: destinazione / contesto del journey

Questo asse descrive per chi o in che forma viene vissuto il journey:

- `autonomy`
- `group`
- `individual`

#### Autonomy

Journey pensato per l'autonomia personale.

#### Group

Journey pensato per un gruppo.

#### Individual

Journey pensato per una singola persona / cliente.

## Nota importante

I due assi non vanno confusi.

Per esempio, un journey puo' essere:

- `guided` + `group`
- `personalized` + `individual`
- `structured` + `autonomy`

## Punto 4 fissato

Per ora si tiene una regola semplice di ownership:

- il `Journey` viene creato dal `professionista`
- la `Line` viene creata dal `creator`

### Professionista

Il professionista lavora sul livello vivo del percorso:

- journey personali
- journey per gruppo
- journey per cliente

Quindi il professionista costruisce il percorso reale, operativo o guidato.

### Creator

Il creator lavora sul livello standard del mondo:

- formalizza una struttura
- crea la `Line`
- rende riusabile e leggibile un percorso stabilizzato

## Effetto pratico

Questa soglia serve a semplificare:

- il `Journey` non coincide con la struttura standard del mondo
- la `Line` non nasce come percorso vivo del singolo caso
- il viaggiatore non entra ancora nella creazione dei modelli sorgente

## Punto 5 fissato

Quando un `Journey` si stabilizza, la `Line` non nasce copiando gli `Event`.

La `Line` nasce invece estraendo e copiando la sequenza delle `Experience` usate negli `Event` del `Journey`.

Quindi:

- `Event`
  - resta la tappa concreta del `Journey` nel tempo
- `Experience`
  - resta una tappa sorgente riusabile
- `Line`
  - nasce come struttura standard derivata da una sequenza di `Experience`

Per fissare l'ordine delle `Experience` nella `Line`, il nome corretto della join diventa:

- `LineExperience`

Questa scelta evita di portare nella `Line` elementi che appartengono solo al livello vivo del `Journey`, come:

- data
- partecipazioni
- dettagli operativi dell'evento

## Punto 6 fissato

`LineExperience` e' una join vera di riuso.

Quindi una stessa `Experience` puo':

- stare in piu' `Line`
- comparire con ordini diversi
- essere riletta in sequenze diverse

`LineExperience` non serve solo a ordinare.

Serve anche a tenere separati:

- la `Experience` come tappa sorgente riusabile
- il modo in cui quella `Experience` entra in una specifica `Line`

Questa scelta conferma che:

- `Experience` e' un nodo standard e riusabile
- `Line` e' una sequenza che puo' riusare nodi gia' esistenti

## Punto 7 fissato

Prima di entrare davvero nei `Journey`, serve un modello trasversale di contenuto.

Il nome corretto da usare e':

- `Content`

`Content` sostituisce l'idea vecchia di `Post` come oggetto troppo legato solo alla parte editoriale.

## Uso minimo di Content

Per la soglia iniziale, `Content` deve potersi collegare almeno a:

- `Port`
- `Line`
- `Journey`
- `Experience`

## Scelta iniziale di associazione

Per partire in modo semplice, `Content` va pensato come contenuto principale dell'oggetto.

Quindi la forma iniziale corretta e':

- `Content belongs_to :contentable, polymorphic: true`

e lato modelli:

- `Port has_one :content, as: :contentable`
- `Line has_one :content, as: :contentable`
- `Journey has_one :content, as: :contentable`
- `Experience has_one :content, as: :contentable`

Questo permette un accesso semplice come:

- `port.content`
- `line.content`
- `journey.content`
- `experience.content`

Per ora non si parte con `has_many :contents`.

Se piu' avanti serviranno:

- piu' materiali
- allegati multipli
- note secondarie
- gallerie

si aprira' un secondo livello.

## Significato

`Content` serve per portare:

- testo
- foto
- note
- materiali leggeri

senza dover creare subito modelli separati per ogni tipo di contenuto.

## Effetto pratico

Questa scelta serve a chiudere prima:

- la pagina pubblica del `Port`
- la parte editoriale minima della `Line`
- le note o i materiali legati a un `Journey`
- le note o i materiali legati a una `Experience`

prima di entrare nella parte piu' operativa dei `Journey`.

## Punto di attenzione prima dell'implementazione

Anche se il documento fissa gia' i modelli minimi, il primo uso reale del sistema dovra' servire a sostenere:

- la home della web app
- un brand che abbia almeno un professionista o un operatore oltre al creator
- viaggiatori che possano iniziare a fare attivita' ed esperienze
- eventi o esperienze con schede e materiali

Questa soglia concreta viene prima della struttura completa di `Line`.

La `Line` arrivera' dopo, quando:

- le esperienze saranno state usate
- gli eventi avranno fatto emergere abbastanza materiale vivo
- le attivita' autonome, guidate o di gruppo avranno iniziato a chiarire una struttura

## Prima implementazione Rails

Per partire, conviene generare prima questo modello:

- `Content`

e solo dopo:

- `Experience`
- `Journey`
- `Line`

senza introdurre ancora:

- `Event`
- `Activity`
- `Service`
- `LineExperience`

Questi entrano dopo, quando il perimetro dello step si chiarisce davvero nel codice.

### Comandi consigliati

```bash
bin/rails g model Content profile:references contentable:references{polymorphic} title:string slug:string description:text content_md:text mermaid:text meta:jsonb visibility:integer
bin/rails g model Experience profile:references port:references title:string slug:string description:text meta:jsonb
bin/rails g model Journey profile:references port:references title:string slug:string description:text journey_mode:integer journey_target:integer visibility:integer meta:jsonb
bin/rails g model Line profile:references port:references source_journey:references title:string slug:string description:text kind:integer visibility:integer meta:jsonb
```

### Perche' cosi'

#### Content

E' il primo mattone utile davvero nel brand.

Serve subito per:

- `Port.content`
- home della web app
- testo introduttivo del brand
- materiali minimi
- schede leggere
- note di lavoro

Campi minimi consigliati:

- `profile`
- `contentable`
- `title`
- `slug`
- `description`
- `content_md`
- `mermaid`
- `meta`
- `visibility`

Qui conviene prendere spunto dalla vecchia tabella `posts`, ma in forma piu' pulita e piu' larga.

Dal vecchio schema conviene tenere l'idea di:

- `title`
- `description`
- `content_md`
- `mermaid`
- `meta`
- `slug`

Per ora eviterei invece di generare subito campi come:

- `banner_url`
- `content`
- `thumb_url`
- `url_media_content`
- `horizontal_cover_url`
- `vertical_cover_url`

Perche' questa parte va pensata meglio insieme a `Active Storage` e ai materiali privati.

`Content` va quindi impostato come modello polimorfico leggero.

#### Experience

Arriva subito dopo `Content`, ma non prima.

Serve come tappa sorgente riusabile.

Campi minimi consigliati:

- `profile`
- `port`
- `title`
- `slug`
- `description`
- `meta`

Per ora `Experience` resta neutra:

- non appartiene al `Journey`
- non appartiene alla `Line`

Sara' poi l'`Event` a collegarsi a una `Experience`, e `LineExperience` a collegare la `Line` alle `Experience`.

#### Line

Serve a rappresentare la struttura standard del mondo.

Campi minimi consigliati:

- `profile`
- `port`
- `source_journey`
- `title`
- `slug`
- `description`
- `kind`
- `visibility`
- `meta`

`source_journey` serve a tenere memoria del journey da cui la line nasce, senza imporre ancora tutta la logica finale.

#### Journey

Serve a rappresentare il percorso vivo costruito dal professionista.

Campi minimi consigliati:

- `profile`
- `port`
- `title`
- `slug`
- `description`
- `journey_mode`
- `journey_target`
- `visibility`
- `meta`

Per ora non lo leghiamo ancora direttamente a `Line`, `Service` o `Event`.

### Nota pratica

Dopo il generator conviene rifinire a mano le migration per aggiungere bene:

- default di `meta` a `{}`
- `null: false` dove serve davvero
- indici unici su `slug` quando il perimetro e' chiaro

senza forzare troppo presto vincoli che potrebbero cambiare nei passi successivi.
