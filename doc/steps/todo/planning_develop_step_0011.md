# Planning Develop Step 0011

## Stato

Da iniziare.

## Obiettivo

Chiarire la matrice delle viste interne ed esterne tra:

- `flowpulse`
- web app dei mondi / brand

e preparare poi il flusso di iscrizione e appartenenza al dominio di ingresso.

## Punto centrale

Esiste `flowpulse`, con:

- parte pubblica
- parte interna

Dentro `flowpulse` esistono almeno queste viste / workspace:

- `creator`
- `professionista`
- `viaggiatore`
- `superadmin`

Le web app dei mondi devono usare una logica simile, ma senza il livello `superadmin`.

## Decisione da fissare

### Flowpulse

`flowpulse` ha:

- una parte pubblica
- una parte interna

La parte interna di `flowpulse` prevede queste viste:

- `creator`
- `professionista`
- `viaggiatore`
- `superadmin`

### Web app del mondo

I `Port` di tipo `web_app` con `WebappDomain` pubblicato hanno:

- una parte pubblica
- una parte interna

La parte interna della web app usa lo stesso impianto generale di Flowpulse, ma senza `superadmin`.

Quindi il set minimo e':

- `creator`
- `professionista`
- `viaggiatore`

## Punto 1 fissato

La distinzione minima tra `flowpulse` e web app del mondo e':

- `flowpulse`
  - privilegia il livello piattaforma
  - qui hanno senso soprattutto `creator` e `superadmin`
- web app del mondo
  - privilegia l'esperienza del mondo
  - qui hanno senso `creator`, `professionista` e `viaggiatore`

La `SeaChart` resta soprattutto uno strumento da creator.

La web app del mondo espone soprattutto gli `EarthNode`, non i `Port`.

## Punto 2 fissato

Per la web app del mondo, un utente anonimo:

- vede la `home`
- non entra nei `Port`
- non vede la `SeaChart` del brand
- vede solo gli `EarthNode` pubblici

## Punto 3 rimandato

Il punto sull'utente autenticato ma non ancora membro viene affrontato piu' avanti, perche' dipende da come verranno strutturati permessi e apertura degli `EarthNode`.

## Punto 4 fissato

Per ora:

- `viaggiatore`
  - vede gli `EarthNode` pubblici e quelli aperti al suo ruolo
- `professionista`
  - vede gli `EarthNode` pubblici e quelli aperti al suo ruolo

La distinzione piu' fine tra cosa vedono esattamente verra' affrontata dopo.

## Nota importante sul creator dentro la web app

Il `creator` dentro la web app del mondo non e' un creator generico di piattaforma.

Deve vedere a monte:

- la mappa del brand
- il funzionamento del mondo
- la struttura del brand a cui appartiene

Quindi la vista creator della web app resta collegata al mondo specifico.

## Punto 5 fissato

Il `creator` in `flowpulse` vede:

- la carta nautica di tutti i suoi brand
- da li' puo' entrare nella carta nautica di uno specifico brand
- poi, in futuro, nella mappa di terra del porto

## Punto 6 fissato

Per il creator:

- il `BrandPort` resta il riferimento della carta nautica
- la `home` pubblica del mondo invece appartiene al `Port` di tipo `web_app`

## Punto 7 fissato

La `home` del mondo e' la `home` del `Port` di tipo `web_app`.

La sua struttura dettagliata verra' costruita in futuro attraverso gli `EarthNode`.

## Punto 8 fissato

Il pubblico minimo degli `EarthNode` parte da questi tipi:

- `folder`
- `blog`
- `book`
- `trail`

## Nota futura fissata

Gli `EarthNode` potranno avere anche un `link_port_id`.

Questo servira' per:

- creare collegamenti extra verso un `Port`
- aprire uscite o ponti verso altri ingressi / altre mappe

Il `link_port_id`:

- non sostituisce la struttura principale della terra
- aggiunge solo un collegamento laterale o secondario

## Limite provvisorio della carta creator

Per ora, nella UI creator, una `SeaRoute` si crea solo tra `Port` visibili nella carta corrente.

Quindi:

- nella carta nautica brands:
  - tra `brand_root` visibili in quella carta
- nella carta nautica del brand:
  - tra `Port` visibili in quella carta

I collegamenti tra carte diverse:

- restano un concetto possibile
- ma la loro gestione e rappresentazione vengono rimandate

## Flusso iscrizione da affrontare dopo

- signup da `flowpulse.net`
  - iscrizione generale senza membership di dominio
- signup da dominio di ingresso
  - creazione automatica della membership del dominio
  - ruolo iniziale semplice, ad esempio `member`

## Da fissare

- quali pagine interne sono davvero comuni tra `flowpulse` e web app
- quali pagine interne restano specifiche del mondo
- come distinguere utente anonimo, autenticato e gia' membro del dominio
- come modellare la membership minima nel nuovo schema rispetto al legacy
- se la membership vada creata subito alla registrazione o al primo completamento profilo
