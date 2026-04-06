# Planning Develop Step 0003

## Stato attuale

- esiste gia' una base pubblica e autenticata
- la distinzione `creator / professionista / persona` sta emergendo in modo piu' chiaro
- il prossimo nodo da chiarire prima del database riguarda `Branch`

## Step attuale

Il prossimo step da fissare prima di implementare riguarda `Branch`.

`Branch` non va letto come semplice brand.
Va letto come categoria organizzativa del sistema.

## Ipotesi di base

Un `Branch` potra' essere di tipo:

- `brand`
- `folder`
- `list`
- `map`

## Prime note di significato

- `brand`
  - identita' forte, pubblica o riconoscibile

- `folder`
  - contenitore organizzativo

- `list`
  - raccolta lineare di contenuti, articoli, book o anche di un solo journey

- `map`
  - territorio con journey e percorsi collegati

## Domain

- un `Branch` potra' avere uno o piu' `Domain`
- un `Domain` potra' puntare direttamente al branch
- i branch fungeranno da categorie o nodi di organizzazione del sistema

## Da chiarire prima di implementare

- campi minimi del branch
- differenza reale tra `list` e `map`
- relazione tra `branch`, `domain`, `journey` e `map`
- modo in cui i branch organizzano mappe creator, mappe personali e servizi

## Nota

Per ora questo tema va documentato e tenuto fermo.
Non va ancora implementato.
