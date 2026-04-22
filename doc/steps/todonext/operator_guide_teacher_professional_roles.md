# Operator Guide Teacher Professional Roles

## Obiettivo futuro

Chiarire il naming e la struttura dei ruoli oggi raccolti in modo provvisorio sotto `professionista`.

## Problema

Il termine `professionista` e' troppo stretto e rischia di confondere livelli diversi:

- ruolo operativo dentro il mondo
- funzione di accompagnamento
- funzione didattica
- riconoscimento professionale o istituzionale

Queste dimensioni non coincidono sempre.

## Distinzione da chiarire

Ci sono almeno quattro parole che oggi si toccano ma non sono uguali:

- `operatore`
- `guida`
- `insegnante`
- `professionista`

### Possibili letture

- `operatore`
  - chi agisce concretamente dentro un servizio, un percorso o una pratica
- `guida`
  - chi accompagna una persona o un gruppo lungo un percorso
- `insegnante`
  - chi ha soprattutto una funzione didattica o formativa
- `professionista`
  - chi puo' avere anche un riconoscimento formale, istituzionale o di mestiere

## Punto da non forzare adesso

Per ora nello step attuale si puo' lasciare `professionista` come naming provvisorio.

Pero' va chiarito piu' avanti se:

- `professionista` restera' il ruolo principale
- `operatore` diventera' il ruolo tecnico di base
- `guida` e `insegnante` saranno specializzazioni o funzioni
- il livello professionale istituzionale restera' separato

## Domande future

- il ruolo tecnico di base deve chiamarsi `operator`?
- `guida` e `insegnante` sono ruoli, etichette UI o attributi?
- il professionista istituzionale e' una sotto-categoria o un asse separato?
- una stessa persona puo' essere insieme operatore, insegnante e professionista?

## Nodo da collegare a domain membership

Va tenuto presente anche un possibile livello locale del ruolo dentro il dominio.

Possibile direzione:

- il `professionista` puo' essere riconosciuto come tale anche per un percorso istituzionale o formale
- questo riconoscimento potrebbe essere fissato su `domain_membership`
- l'`operatore` potrebbe invece essere il livello operativo locale attivato dentro il brand

Da chiarire piu' avanti:

- se su `domain_membership` servira' un indicatore semplice di riconoscimento professionale
- se il creator del brand potra' attivare localmente quel professionista nel proprio dominio
- se questo attivera' anche un livello operativo tipo `operatore`

## Punto da non aprire ancora

Non conviene ancora aprire:

- abbonamenti
- durata 6 mesi / 1 anno
- datetime di scadenza
- creator che incassa e attiva
- certificazione della transazione

Questa parte va solo tenuta come direzione futura.

Prima conviene chiarire:

- home della web app
- esperienze come eventi
- percorsi del viaggiatore
- rapporto tra professionista e operatore nel dominio

## Obiettivo di arrivo

Trovare una struttura in cui:

- il naming sia umano e leggibile
- il modello resti coerente
- il ruolo non venga confuso con il titolo o con il valore professionale
