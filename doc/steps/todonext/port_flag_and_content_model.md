# Port Flag e Content Model

## Brand Port come bandiera

Sta emergendo una possibilita' utile:

- `brand_port_id` potrebbe funzionare come una bandiera
- non solo come parent tecnico
- ma come appartenenza simbolica o area principale

Questa idea serve quando un `Port` deve restare autonomo, ma allo stesso tempo appartenere a un mondo o brand piu' grande.

## Punto da chiarire

`brand_port_id` potrebbe voler dire:

- porto principale di appartenenza
- bandiera sotto cui il port naviga
- area madre del contenuto o del percorso

Questa scelta non va confusa con:

- parent tree
- nesting gerarchico classico

Per ora va tenuta come ipotesi aperta.

## Modello trasversale per contenuti

Serve anche una seconda riflessione:

come agganciare a `Port` e, in futuro, anche alle tappe o agli `Event` e `Activity`:

- immagini
- testo
- markdown
- allegati
- schede
- materiali

## Ipotesi

Invece di creare modelli diversi troppo presto, puo' avere senso un modello trasversale tipo:

- `Content`
- oppure `Post`
- oppure `Resource`

La direzione migliore, oggi, sembra un nome come:

- `Content`

Perche' e' piu' largo e puo' valere sia per:

- porti
- mappe
- tappe
- event
- activity

## Uso possibile

Un `Content` potrebbe essere agganciato a:

- `Port`
- in futuro `Event`
- in futuro `Activity`
- in futuro altri nodi operativi

e contenere:

- `title`
- `description`
- `content_md`
- immagini
- allegati
- meta

## Vantaggio

Questa scelta evita di dover inventare subito:

- un modello per i post
- uno per le schede
- uno per i materiali
- uno per i contenuti delle tappe

## Da chiarire dopo

- nome definitivo:
  - `Content`
  - `Post`
  - `Resource`
- se il legame deve essere polimorfico
- se i file allegati passano da `Active Storage`
- se il markdown resta nel database o come file allegato
