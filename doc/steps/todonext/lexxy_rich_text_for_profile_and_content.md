# Lexxy Rich Text For Profile And Content

## Idea

Integrare **Lexxy** come editor rich text futuro nel progetto, invece di usare Trix / ActionText come soluzione principale.

Riferimento:

- https://dev.37signals.com/announcing-lexxy-a-new-rich-text-editor-for-rails/

## Primo campo pilota

- `Profile.bio`

Per ora `bio` e' ancora un semplice campo `text` con `textarea`.

## Obiettivi futuri

- integrare Lexxy in Rails in modo coerente con il progetto
- usarlo prima su `Profile.bio`
- valutare poi estensione a:
  - `EarthNode`
  - contenuti editoriali
  - trail
  - book
  - eventuali pagine custom

## Note

- non introdurre ora Trix per `bio`
- decidere bene:
  - formato di storage
  - rendering pubblico
  - sanitizzazione
  - eventuale supporto allegati / media
