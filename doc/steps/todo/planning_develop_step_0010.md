# Planning Develop Step 0010

## Stato

Da iniziare.

## Obiettivo

Definire il flusso di iscrizione e appartenenza al dominio brand.

## Punto centrale

Se un utente si registra partendo da un `BrandDomain`, il sistema deve conservare quel contesto e creare automaticamente l'appartenenza iniziale al dominio.

## Decisione da attuare

- signup da `flowpulse.net`
  - iscrizione generale senza membership di dominio
- signup da `BrandDomain`
  - creazione automatica della membership del dominio
  - ruolo iniziale semplice, ad esempio `member`

## Da fissare

- dove mostrare la CTA `Iscriviti` nel dominio brand
- come distinguere utente anonimo, utente autenticato e gia' membro del dominio
- come modellare la membership minima nel nuovo schema rispetto al legacy
- se la membership vada creata subito alla registrazione o al primo completamento profilo
