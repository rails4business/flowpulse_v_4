# Domain Language Strategy

## Stato

Backlog successivo.

## Tema

Dopo il primo modello semplice `un dominio = una lingua`, resta aperta una decisione piu' ampia sulla lingua.

Le domande da tenere appuntate sono:

- in futuro un singolo dominio puo' ospitare piu' lingue?
- la lingua va associata al dominio, al `Port`, al `Profile`, oppure a una combinazione di questi livelli?
- i contenuti del `Port` cambiano davvero per lingua oppure cambia solo la lingua di visualizzazione?
- la home custom del dominio deve diventare una vera pagina strutturata e non solo HTML o testo?
- il nav del dominio deve restare JSON semplice oppure diventare un modello dedicato?

## Perche' non entra ora

Questo tema allarga il perimetro in modo importante:

- routing pubblico
- localizzazione dei contenuti
- strategia SEO
- fallback della lingua
- relazione tra identita' del profilo e pubblicazione del `Port`

Per partire in modo pulito, lo step 0007 resta piu' semplice:

- un `Port` puo' avere piu' domini
- ogni dominio ha una sola lingua

## Quando affrontarlo

Dopo aver stabilizzato:

- il legame tra `Port` e dominio
- il flusso di pubblicazione minima
- la semantica del dominio principale
