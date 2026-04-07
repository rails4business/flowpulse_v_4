# Planning Develop Step 0003

## Stato attuale

- esiste gia' una base pubblica e autenticata
- la distinzione `creator / professionista / persona` sta emergendo in modo piu' chiaro
- il prossimo nodo da chiarire prima del database riguarda solo `Branch`

## Step attuale

Lo step attuale riguarda solo `Branch`.

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
  - raccolta lineare di contenuti, articoli, book o anche di un solo trail

- `map`
  - territorio con trail e percorsi collegati

## Domain

- un `Branch` potra' avere uno o piu' `Domain`
- un `Domain` potra' puntare direttamente al branch
- in questo step il `Domain` va chiarito solo come relazione minima col branch

## Da fare ora

- campi minimi del branch
- differenza reale tra `list` e `map`
- ownership del branch su `Profile`
- capire se serve subito `parent_branch_id`
- chiarire la relazione minima con `Domain`

## Fuori da questo step

- relazione completa tra `branch`, `journey`, `mappe personali` e `servizi`
- uso del branch come albero completo dei mondi creator
- modo in cui il branch organizza mappe creator, mappe personali e servizi

Questi punti vanno tenuti in `next`, non dentro lo step operativo attuale.
