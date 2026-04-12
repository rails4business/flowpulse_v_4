# Planning Develop Step 0006

## Stato

Completato.

## Obiettivo chiuso

Dopo aver chiuso nello step 0005 la rete minima del mare tra `Port`, lo step 0006 ha introdotto la direzione delle `SeaRoute` e la relativa UX di modifica direttamente sulla carta nautica.

L'obiettivo era rendere la rotta non solo esistente, ma anche semanticamente leggibile:

- rotta neutra
- rotta orientata in un verso
- rotta orientata nel verso opposto

## Decisione di modello fissata

La direzione della `SeaRoute` non e' stata rappresentata con un boolean, ma con tre stati espliciti:

- `bidirectional`
- `source_to_target`
- `target_to_source`

Per supportare questo passaggio e' stata aggiunta una migration dedicata su `sea_routes`.

## UX chiusa nello step 0006

Con `Modifica` attivo sulla carta nautica:

- una `SeaRoute` puo' essere selezionata direttamente dalla mappa
- compare una toolbar compatta dedicata alla rotta
- il primo bottone mostra lo stato attuale della direzione
- cliccando il bottone della direzione, la rotta cicla tra i tre stati
- e' possibile aprire un pannello informativo leggero sulla rotta
- e' possibile eliminare la rotta con conferma

Il ciclo effettivo della direzione e':

- `bidirectional -> source_to_target`
- `source_to_target -> target_to_source`
- `target_to_source -> bidirectional`

## Resa sulla mappa

La carta nautica ora riflette la direzione della rotta:

- se la rotta e' neutra, resta visibile come linea
- se la rotta e' orientata, compaiono indicatori direzionali lungo la tratta
- il bottone della direzione e la resa grafica della tratta restano sincronizzati
- la zona cliccabile della rotta e' piu' larga della linea visibile, per rendere la modifica usabile

## Rifiniture chiuse nello stesso passo

Durante la chiusura dello step sono state fissate anche alcune regole collegate alla mappa:

- la bandiera del `brand_port` mostra il nome del brand al passaggio del mouse
- quando un nuovo `Port` nasce dal mare tramite una rotta:
  - se il porto sorgente e' un `brand`, il nuovo porto eredita quel brand
  - se il porto sorgente ha gia' un `brand_port`, il nuovo porto eredita quel riferimento
- il form del colore del porto e' stato corretto per salvare davvero il `color_key` scelto
- l'isola in carta nautica usa il colore salvato del porto

## Outcome raggiunto

Alla fine dello step 0006 esistono:

- persistenza della direzione della `SeaRoute`
- modifica della direzione direttamente dalla carta nautica
- rappresentazione grafica coerente tra rotta neutra e rotta orientata
- eliminazione della rotta dalla mappa con conferma
- continuita' di appartenenza al brand nella creazione di nuovi porti dal mare

## File principali coinvolti

- `db/migrate/20260411090000_add_direction_mode_to_sea_routes.rb`
- `app/models/sea_route.rb`
- `app/models/port.rb`
- `app/controllers/creator/ports_controller.rb`
- `app/controllers/creator/sea_routes_controller.rb`
- `app/views/creator/carta_nautica.html.erb`
- `app/views/creator/ports/_form.html.erb`
- `app/javascript/controllers/sea_chart_controller.js`
- `app/javascript/controllers/port_form_controller.js`
- `test/models/sea_route_test.rb`
- `test/models/port_test.rb`

## Punto aperto lasciato al passo successivo

Con lo step 0006 chiudiamo la direzione delle rotte nautiche.

Il passo successivo puo' spostarsi oltre la sola rotta del mare, ad esempio verso:

- identita' piu' ricca del brand sulla mappa
- collegamenti tra livello nautico e livello terrestre
- nuovi modelli di continuita' tra `Port`, `Trail` e `Service`
