# Lexxy Rich Text For Profile And Content

## Direzione

Per ora il progetto usa **Markdown** come formato canonico dei contenuti editoriali.

Scelta attuale:

- `Content.description`
  - resta campo semplice
- `Content.content`
  - usa **EasyMDE**
  - salva testo Markdown
  - continua a essere renderizzato lato pubblico con il renderer markdown gia' presente

Questa scelta tiene il sistema semplice per:

- home web app
- pagine editoriali
- blog
- book
- export / archivio `.md`
- lettura AI e possibile import/export futuro

## Lexxy Dopo

Lexxy resta una direzione futura concreta, ma non il primo editor da integrare adesso.

Riferimenti:

- https://dev.37signals.com/announcing-lexxy-a-new-rich-text-editor-for-rails/
- https://github.com/basecamp/lexxy

## Strategia Futura Possibile

Se piu' avanti si installa **Lexxy**, la transizione va fatta in modo esplicito e senza mischiare i formati nello stesso campo.

Strada consigliata:

- mantenere `content` come fonte canonica Markdown per i contenuti esistenti
- aggiungere in futuro un secondo canale rich text con Action Text / Lexxy
- introdurre uno `editor_mode` solo quando Lexxy sara' davvero installato

Possibile schema futuro:

- `editor_mode`
  - `markdown`
  - `rich_text`
- `content`
  - markdown
- `rich_content`
  - action text / lexxy

## Primo Campo Pilota Futuro

Quando si aprira' davvero il passo Lexxy, il primo campo pilota sensato puo' essere:

- `Profile.bio`
  oppure
- una pagina editoriale non critica

prima di estenderlo a:

- contenuti editoriali principali
- trail
- book
- eventuali pagine custom

## Note

- non introdurre ora Trix come soluzione intermedia principale
- non mischiare ora markdown e rich text nello stesso campo
- decidere il passaggio a Lexxy solo quando sara' chiaro:
  - formato di storage
  - rendering pubblico
  - sanitizzazione
  - allegati / media
  - migrazione dei contenuti gia' scritti in Markdown
