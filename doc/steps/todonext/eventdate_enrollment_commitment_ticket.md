# EventDate, Enrollment, Commitment, Ticket

Questa nota raccoglie una distinzione futura importante del dominio, ma non fa parte del core immediato dello step attuale.

## Punto di partenza

Un `EventDate` da solo non basta a descrivere tutta la realta' operativa di un evento.

Per esempio, un singolo `EventDate` puo' avere:

- un insegnante
- dieci clienti
- una sala
- un tutor
- una segreteria

Questi elementi non sono tutti uguali e non vanno compressi nello stesso concetto.

## Distinzione proposta

### EventDate

- e' l'evento previsto
- definisce tempo, durata, contenuto e struttura dell'incontro

### Enrollment

- rappresenta l'iscrizione o adesione di una persona a un evento
- ha senso soprattutto per chi partecipa come utente o cliente

### Commitment

- rappresenta l'impegno concreto assegnato dentro un evento
- puo' descrivere ruoli, responsabilita', presenze operative e risorse
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

## Nota

Questa parte va analizzata piu' avanti.

Non va ancora portata nel core iniziale di:

- branch
- map
- trail
- journey

ma merita di restare fissata perche' tocca il cuore dell'erogazione reale dei servizi.
