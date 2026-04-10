# EventDate, Enrollment, Commitment, Ticket

Questa nota raccoglie una distinzione futura importante del dominio, ma non fa parte del core immediato dello step attuale.

## Punto di partenza

Un `EventDate` da solo non basta a descrivere tutta la realta' operativa di un evento.

Inoltre, con la nuova visione, un `EventDate` non va letto solo come data di calendario.
Puo' anche diventare:

- un'attivita'
- una tappa concreta di un `Journey`
- un evento condiviso
- un momento di erogazione di un servizio

Per esempio, un singolo `EventDate` puo' avere:

- un insegnante
- dieci clienti
- una sala
- un tutor
- una segreteria

Questi elementi non sono tutti uguali e non vanno compressi nello stesso concetto.

## Distinzione proposta

### EventDate

- e' l'unita' concreta prevista nel tempo
- definisce tempo, durata, contenuto e struttura dell'incontro
- puo' rappresentare:
  - attivita'
  - lezione
  - trattamento
  - incontro online
  - incontro singolo
  - incontro di gruppo
- puo' stare:
  - dentro un `Journey`
  - dentro un servizio professionale
  - in un evento condiviso piu' ampio

### Enrollment

- rappresenta l'iscrizione o adesione di una persona a un evento
- ha senso soprattutto per chi partecipa come utente o cliente

### Commitment

- rappresenta l'impegno concreto assegnato dentro un evento
- puo' descrivere ruoli, responsabilita', presenze operative e risorse
- puo' anche descrivere la modalita' concreta di erogazione della singola tappa
- puo' valere per:
  - insegnante
  - cliente
  - tutor
  - segreteria
  - sala o altra risorsa

### Ticket

- in questa lettura, il `Ticket` potrebbe essere piu' vicino al `Commitment` che all'`EventDate`
- il ticket descriverebbe l'impegno concreto, il ruolo e l'eventuale valore economico legato alla partecipazione o erogazione

## Ipotesi utile

Una struttura futura plausibile e':

- `EventDate`
  - evento previsto
- `Enrollment`
  - iscrizione all'evento
- `Commitment`
  - ruolo/impegno concreto dentro l'evento
- `Ticket`
  - valore operativo o economico legato al commitment

## Nuova domanda importante

Sta emergendo un punto ulteriore:

uno stesso `Journey` puo' essere attivato con servizi diversi.

Per esempio:

- stesso journey di igiene posturale
- servizi diversi
- professionisti diversi
- ruoli diversi
- modalita' di erogazione diverse

Questo significa che non basta il solo valore astratto del journey.

Serve anche capire:

- come cambia l'erogazione da servizio a servizio
- come cambiano i ruoli
- come cambiano le specifiche di ogni tappa

## Conseguenza

Probabilmente ogni `EventDate` dovra' poter portare con se':

- una scheda della tappa
- il servizio concreto erogato
- la modalita' operativa
- i ruoli coinvolti
- un eventuale resoconto finale

Quindi `EventDate` potrebbe diventare il punto in cui si incontrano:

- struttura del journey
- valore del servizio
- valore del professionista
- erogazione concreta

## Nota

Questa parte va analizzata piu' avanti.

Non va ancora portata nel core iniziale di:

- port
- sea route
- map
- trail
- journey

ma merita di restare fissata perche' tocca il cuore dell'erogazione reale dei servizi.

---
