# Cross Profile Sea Routes

## Stato

Backlog successivo.

## Tema

Permettere a una `SeaRoute` di collegare un `Port` del creator corrente con un `Port` non appartenente allo stesso `Profile`.

## Perche' non entra ora

Questo tema allarga parecchio il perimetro:

- ownership dei nodi
- visibilita' tra profili diversi
- permessi di creazione
- validazioni cross-profile
- impatto sulla lettura della carta nautica

Non e' una semplice estensione dello step 0005, ma un cambio di regole del grafo.

## Quando ha senso affrontarlo

Dopo aver stabilizzato:

- il collegamento mare -> terra
- il ruolo dei `Port` come punti di accesso
- il confine tra rete privata del creator e rete condivisa
