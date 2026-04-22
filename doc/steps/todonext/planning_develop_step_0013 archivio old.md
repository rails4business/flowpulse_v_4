# planning_develop_step_0013.md

## 🎯 Obiettivo

Journey -> event -> activity

exploration potrebbe essere di tre tipi:

- personalizzato al posto di exploration
- validazione
- strutturato

poi rivolto a:

- persaonale autonomia per se (professionista) dove puoi mettere stazioni nuove (il viaggiatore può farlo ma non creare line può creare solo un suo percorso), il journey può essere per se.. cioè un professionista fa da tester su di se oppure lo fa su un gruppo o per una persona...
- gruppo
- per un cliente

Posso da un journey personale creare una line per poterlo poi usare come template

- dalla linea posso poi creare journey guida da validare (guida + cliente/i)

- poi se alla linea aggiungo i servizi dalla linea posso creare journey strutturato

considera che una tappa del journey (tanti event)
nell'evento

- (contenuto programma schede dell evento) che è quello che sta nelle line station
- servizio (definizione durata persone prezzo online offline ecc ) che viene impostato nel servizio (il servizio potrebbe anche essere costruito sapendo prezzo della sala prezzo di....)
- valore professionista che devo capire come chiamare è sempre servizio_presenza_professionista_valore ma è tipo consulenza valore netto esempio seduta di fisioterapia senza il programma e il

EarthNode diventa -> Line bisogna portare questa modifica

- Line → sequenza / percorso materiale (Blog, Libro, corso, guida, percorso con più linee)
- Station → punto della mappa
- LineStation → relazione tra linee e stazioni

### Line

Una sequenza di stazioni.

Può rappresentare:

- un trail (percorso)
- un blog (sequenza articoli)
- un book (capitoli)
- un corso
- una guida

👉 È il modello più flessibile.

---

### Station

Un punto della mappa.

Può essere:

- una tappa
- un contenuto
- un nodo condiviso tra più linee

👉 È riutilizzabile.

---

### LineStation

Join tra Line e Station.

Serve per:

- ordinare le stazioni
- gestire le sequenze
- permettere che una station stia in più linee

---

- poi in realtà quello che era albero delle mappe è stato ampliato in seachart ma si dovrebbe creare una pagina in dashboard creator una pagina albero dei port.brand oltre a seachart per il creator poi in genera impresa http://localhost:3000/flowpulse_v_4/

- 2_generaimpresa_mappa.html c'era il concetto di line station e linestation in rails4business un solo viaggio che in realtà potrebbe selezionare anche le stazioni di più linee basta che siano in fila, e che potrebbe poi effettivamente essere la selezione della creazione del journey dove si considerano tutti i ruoli (professionista clienti) - mentre 1impegno è il viaggio journey solo di un ruolo qui ci sono tutti i biglietti http://localhost:3000/flowpulse_v_4/4_1impegno.html
- infine http://localhost:3000/flowpulse_v_4/5_calendario_ticket.html hai il tuo calendario con quando devi fare le tue tappe...
