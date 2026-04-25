# planning_target_product_route.md

## Scopo

Questo file non e' uno step tecnico.

Serve a tenere ferma la rotta di prodotto mentre gli step di sviluppo cambiano.

Qui restano:

- obiettivi prioritari
- ordine di costruzione
- dipendenze logiche
- cose secondarie da non mettere davanti al nucleo vero

## Punto Di Partenza

Le rifiniture della metro map restano utili, ma non sono il cuore del lavoro adesso.

Da tenere in secondo piano:

- intersezioni cross-line piu' chiare
- rifinitura finale dei nodi condivisi
- rifinitura visiva di `port_entry / link_port`

Queste non spariscono, ma non devono guidare la roadmap.

## Rotta Principale

La rotta vera adesso e':

1. organizzare bene `Station` ed `Experience`
2. mettere in home le prime station
3. caricare il percorso `Igiene Posturale`
4. introdurre i `Quiz`
5. introdurre la `Profilazione Paziente`
6. costruire i `Journey`
7. costruire il `Planning Settimanale`
8. gestire gli `Eventi`

## Lettura Del Prodotto

La mappa da costruire e':

- il `Port` apre da una o piu' station iniziali
- le `Line` organizzano i percorsi
- le `Station` sono i nodi del journey
- le `Experience` sono i contenuti, i moduli, i passi operativi

Questo porta a una conseguenza pratica:

- prima va chiarita la struttura `Station / Experience`
- solo dopo conviene caricare davvero contenuti, quiz, profilazioni, planning ed eventi

## Priorita' 1

### organizzare `Station` ed `Experience`

Obiettivo:

- chiarire cosa vive sulla `Station`
- chiarire cosa vive sulla `Experience`
- chiarire come le prime station arrivano in home

Da fissare:

- la station iniziale del port
- le prime station da mostrare in home
- il rapporto tra station nodo e experience contenuto
- il caso `blog / libro / quiz / program / lesson`

## Priorita' 2

### home come ingresso del sistema

Obiettivo:

- usare la home per far emergere le prime station utili
- non come pagina generica, ma come ingresso al journey

Da chiarire:

- quali station compaiono
- se compaiono solo le `port_entry`
- se compaiono anche station iniziali di line chiave

## Priorita' 3

### percorso `Igiene Posturale`

Obiettivo:

- caricare un primo percorso reale end-to-end
- usarlo come caso pilota del sistema

Questo serve per validare:

- struttura line/station
- experience tree
- home
- journey

## Priorita' 4

### quiz e profilazione paziente

Obiettivo:

- aggiungere nodi decisionali e raccolta dati reali

Da leggere come blocco unico:

- `Quiz`
- `Profilazione Paziente`

Perche':

- entrambi introducono scelte
- entrambi influenzano il journey

## Priorita' 5

### journey

Obiettivo:

- trasformare la mappa in percorso vissuto

Qui va chiarito:

- da quale station parte un journey
- come salva i passaggi
- come registra scelte, quiz, profilazione

## Priorita' 6

### planning settimanale

Obiettivo:

- portare i journey dentro una struttura temporale

Il planning settimanale non va trattato come pagina separata qualsiasi.

Va letto come:

- organizzazione nel tempo di station, experience, eventi e task

## Priorita' 7

### eventi

Obiettivo:

- gestire appuntamenti, attivazioni e momenti condivisi

Gli eventi arrivano dopo il journey e dopo il planning, non prima.

## Dipendenze Logiche

Ordine corretto:

1. `Station / Experience`
2. home con prime station
3. percorso `Igiene Posturale`
4. `Quiz`
5. `Profilazione Paziente`
6. `Journey`
7. `Planning Settimanale`
8. `Eventi`

## Regola Di Lavoro

Quando nasce un nuovo step tecnico, va letto contro questa rotta.

Domanda da fare ogni volta:

- questa cosa spinge davvero avanti la roadmap centrale
- oppure e' solo una rifinitura locale

Se e' rifinitura locale, non deve rubare il posto al nucleo vero.
