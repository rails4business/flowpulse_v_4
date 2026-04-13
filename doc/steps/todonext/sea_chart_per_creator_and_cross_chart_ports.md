# Sea Chart Per Creator And Cross Chart Ports

## Punto emerso

La carta nautica attuale e' ancora troppo implicita: coordinate e rotte vivono direttamente su `Port` e `SeaRoute`, ma il modello non separa ancora in modo esplicito:

- le diverse carte dei creator
- il `Port` come nodo concettuale
- la presenza del `Port` dentro una carta
- il `BrandPort` come centro della carta

## Direzione da fissare

Introdurre in futuro un modello dedicato alla carta nautica, ad esempio:

- `SeaChart`
- `PortToSeaChart` oppure altro nome piu' chiaro

## Obiettivo

Ogni creator deve poter avere una o piu' carte nautiche distinte.

Le coordinate dei `Port` non dovrebbero vivere solo sul `Port` in astratto, ma nella relazione tra `Port` e `SeaChart`.

Quindi il modello futuro dovra' probabilmente distinguere:

- il `Port` come punto di ingresso o nodo concettuale
- la presenza del `Port` dentro una specifica `SeaChart`
- le coordinate del `Port` dentro quella specifica carta
- il `BrandPort` che caratterizza la carta e ne definisce il centro logico

## Effetto atteso

Questo permettera' di avere:

- carte nautiche separate per creator
- stessa entita' `Port` vista in carte diverse
- coordinate diverse a seconda della carta
- meno accoppiamento diretto tra `Port` e posizione grafica
- un `BrandPort` che resta riferimento della carta senza forzare coordinate globali su tutti i `Port`

## Lista personale dei port

Va anche considerata una lista "I miei Port", separata dalla sola rappresentazione grafica della carta.

Questa lista dovra' permettere di vedere:

- tutti i `Port` del creator
- il tipo di ingresso del `Port`
- le `SeaRoute` collegate
- eventuali appartenenze a brand o carte

## Rotte tra carte diverse

Le `SeaRoute` future non dovranno essere limitate ai `Port` della stessa carta.

Va tenuta aperta la possibilita' che una rotta:

- parta da un `Port` presente in una `SeaChart`
- arrivi a un `Port` presente in un'altra `SeaChart`

Quindi il modello futuro dovra' distinguere bene:

- appartenenza del `Port` a una carta
- esistenza della `SeaRoute` tra due `Port`

senza costringere le rotte a restare solo dentro una singola carta.

## Nota sul pubblico

Per la soglia minima del sistema:

- il `Port` pubblico iniziale resta il `BrandPort` o il porto di ingresso principale del mondo
- gli altri `Port` della carta non devono essere esposti subito all'esterno
- l'apertura pubblica di altri `Port` verra' affrontata dopo

## Nota di focus

Questo tema va tenuto fuori dallo step attuale.

Prima conviene chiudere:

- dominio pubblico del brand
- home standard del brand
- ordine del primo livello tramite `SeaRoute`

Solo dopo ha senso affrontare la separazione vera tra carte nautiche e rotte cross-chart.
