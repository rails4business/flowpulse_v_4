# Planning Develop Step 0010

## Stato

Da iniziare.

## Obiettivo

Riordinare il modello di:

- `Port`
- porto brand / contenitore
- `SeaChart`
- dominio della web app

in modo piu' coerente e meno ambiguo.

## Intro

Lo step 0010 nasce perche' nel modello attuale si stanno mescolando troppi livelli diversi:

- il `Port` come canale di ingresso
- il porto brand come contenitore del mondo
- la carta nautica come spazio del mare
- il dominio web come ingresso applicativo
- i contenuti della terra come `folder`, `blog`, `book` e `trail`

Il rischio e' che un solo modello provi a rappresentare contemporaneamente:

- ingresso
- contenuto
- mappa
- dominio
- contenitore

Questo step serve quindi a separare meglio i ruoli:

- `Port` come ingresso
- porto brand come radice della carta
- `SeaChart` come mare / contenitore del mondo
- `WebappDomain` come dominio della web app
- `EarthNode` come entita' futura della terra

## Punto 1 fissato

L'enum attuale del `Port` non deve piu' rappresentare contenuti editoriali come:

- `brand`
- `map_port`
- `blog`
- `book`

`Port` va trattato come punto di ingresso o canale.

Quindi `port_kind` va nella direzione di valori come:

- `web_app`
- `website`
- `youtube`
- `instagram`
- `whatsapp`
- `phone`

Inoltre serve un campo string semplice, chiamato `entry_value`, che contiene il riferimento di ingresso:

- URL per `website`
- URL per `youtube`
- URL o identificativo per `instagram`
- URL o numero per `whatsapp`
- numero per `phone`

Eccezione importante:

- se `port_kind = web_app`
  - il `Port` puo' avere anche il dominio dell'applicazione costruita da noi
  - l'attuale concetto di `BrandDomain` va riallineato verso `WebappDomain`

## Punto 2 fissato

`brand` non deve piu' stare dentro `port_kind`.

Il fatto che un `Port` generi o caratterizzi una carta nautica va trattato come funzione strutturale separata.

La direzione fissata e':

- introdurre un boolean separato, `brand_root`
- il `Port` con `brand_root = true` diventa il porto-contenitore della carta
- quel `Port` non e' definito dal tipo di canale, ma dal ruolo che ha nella `SeaChart`

## Conseguenze del punto 2

- `Port` continua a dire "che canale e'"
- `brand_root` dice "questo porto genera o caratterizza una carta nautica"
- il porto brand diventa contenitore di altri `Port`
- la vista creator della carta nautica deve partire dalla lista dei porti brand

Quindi la direzione della UI e':

- l'attuale `creator/carta_nautica` va verso una lista di carte brand
- in quella lista si vedono solo i `Port` con `brand_root = true`
- entrando in uno di questi si apre la carta nautica relativa

## Punto 3 fissato

Il `Port` con `brand_root = true` continua a esistere come record `Port`.

Pero' quando si entra nella carta di quel brand, non deve essere trattato come un porto normale interno alla mappa.

La regola fissata e':

- fuori dalla carta:
  - il `Port` brand compare nella lista delle carte brand
- dentro la sua carta:
  - il `Port` brand viene usato come titolo / identita' della `SeaChart`
  - non viene trattato come nodo normale del reticolo dei porti interni

Questo evita un doppione inutile:

- il brand non compare sia come titolo sia come porto centrale da navigare
- la carta ha un contenitore chiaro
- gli altri `Port` della carta restano i nodi navigabili interni

Conseguenza UI gia' fissata:

- cliccando un `brand_root` sulla mappa si apre la sua carta nautica
- non il suo show come porto normale
- la modifica del `brand_root` si fa dal titolo della carta, con una matita accanto al nome

## Punto 4 fissato

L'attuale concetto di `BrandDomain` va rinominato concettualmente in `WebappDomain`.

La regola fissata e':

- `WebappDomain` esiste solo per i `Port` con `port_kind = web_app`
- gli altri tipi di ingresso non usano un modello dominio dedicato
- gli altri tipi di ingresso usano il campo `entry_value` del `Port`

Quindi:

- `web_app`
  - puo' avere uno o piu' `WebappDomain`
- `website`
  - usa `entry_value`
- `youtube`
  - usa `entry_value`
- `instagram`
  - usa `entry_value`
- `whatsapp`
  - usa `entry_value`
- `phone`
  - usa `entry_value`

Il nome fissato per il campo string semplice del `Port` e':

- `entry_value`

Questo nome e' abbastanza neutro da contenere:

- un URL
- un numero di telefono
- un handle
- un identificativo di canale

## Punto 5 fissato

Per ora le coordinate restano su `Port`, ma con una regola precisa di interpretazione:

- se `brand_root = true`
  - le coordinate del `Port` sono riferite alla propria mappa brand generale
- se `brand_root = false`
  - le coordinate del `Port` sono riferite alla mappa del `BrandPort` a cui appartiene

Questa e' una scelta semplice e temporanea, valida finche' ogni `Port` normale appartiene a una sola mappa brand.

Inoltre la navigazione viene distinta cosi':

- aprendo un `Port` brand
  - si apre il mare
  - con i `Port` relativi di quella carta
- aprendo un `Port` non brand
  - si apre la terra / isola
  - con le entita' interne della mappa terrestre

Il nome generale fissato per l'entita' interna della terra e':

- `EarthNode`

`EarthNode` puo' avere tipi come:

- `folder`
- `blog`
- `book`
- `trail`

## Punto 6 fissato

L'appartenenza dei `Port` a una carta resta determinata in modo semplice da `brand_port_id`.

La regola fissata e':

- un `BrandPort`
  - si crea nella carta nautica brands
- un `Port` normale
  - si crea nella carta nautica del proprio `BrandPort`
- i `Port` della carta brand sono quindi individuati da `brand_port_id`

Questa e' la soglia semplice da usare adesso, senza introdurre ancora una relazione piu' pesante tra `Port` e `SeaChart`.

Le `SeaRoute` non vengono ridefinite come appartenenza alla carta:

- restano collegamenti tra `Port`
- continuano a funzionare come adesso
- sono un livello logico separato rispetto alla `SeaChart`
- la carta nautica mostra solo la porzione visibile del grafo

Questo significa che:

- nella carta nautica brands si vedono i `brand_root`
- nella carta nautica del singolo brand si vedono i `Port` di quel brand
- in entrambi i casi le `SeaRoute` restano relazioni globali tra `Port`

Se una `SeaRoute` collega un `Port` visibile a un `Port` fuori dalla carta corrente:

- il modello la ammette
- la rappresentazione grafica del collegamento fuori carta verra' decisa piu' avanti

## Punti finali fissati

### Naming del boolean strutturale

Il naming consigliato per sostituire il vecchio boolean strutturale e':

- `brand_root`

La ragione e' che il `Port` non rappresenta solo un brand generico, ma la radice / contenitore del mondo e della carta.

### Dominio della web app

`BrandDomain` va riallineato concettualmente a:

- `WebappDomain`

Questo naming e' ormai quello reale del modello applicativo.

### Modello futuro della terra

Il nome fissato per il modello futuro della terra e':

- `EarthNode`

`EarthNode` resta il contenitore generale dei tipi:

- `folder`
- `blog`
- `book`
- `trail`

### Regola del Port pubblico

Un `Port` diventa pubblico come ingresso applicativo solo se valgono tutte queste condizioni:

- `visibility = published`
- `port_kind = web_app`
- ha almeno un `WebappDomain` con `published = true`

Questa regola vale per il `Port` pubblico come web app.

Gli altri `Port` non `web_app`, per ora:

- non diventano entry point pubblici autonomi
- restano canali interni o riferimenti del mondo

## Checklist tecnica di attuazione

1. Riallineare `Port`

- aggiornare `port_kind` al nuovo significato di canale di ingresso
- introdurre `entry_value`
- introdurre `brand_root:boolean`
- smettere di usare `brand` come tipo di `port_kind`

2. Riallineare il dominio della web app

- mantenere per ora il codice esistente dove serve
- ma fissare che il modello dominio si applichi solo ai `Port` con `port_kind = web_app`
- preparare il terreno al riallineamento concettuale da `BrandDomain` a `WebappDomain`

3. Riallineare la carta nautica creator

- la vista iniziale della carta nautica deve mostrare i `Port` con `brand_root = true`
- la vista iniziale della carta nautica deve mostrare anche le `SeaRoute` tra i `brand_root` visibili
- entrando in uno di questi si apre la carta del brand
- dentro la carta del brand si vedono i `Port` con `brand_port_id` riferito a quel brand root
- dentro la carta del brand si vedono le `SeaRoute` tra i `Port` visibili in quella carta

4. Lasciare invariato per ora

- `SeaRoute` restano collegamenti globali tra `Port`
- le coordinate restano sui `Port` con la regola gia' fissata
- `EarthNode` non viene ancora implementato in questo step

## Regola di vista della carta nautica

Per questo step la `carta_nautica` creator ha solo due viste:

- vista generale brands
  - mostra tutti i `Port` con `brand_root = true`
  - mostra le `SeaRoute` tra i `brand_root` visibili

- vista del singolo brand
  - mostra il `brand_root` scelto e i `Port` con `brand_port_id` riferito a quel brand
  - mostra le `SeaRoute` tra i `Port` visibili in quella carta

## Punti successivi da chiarire

1. eventuali rifiniture residue della UI creator dopo il passaggio a `brand_root`
