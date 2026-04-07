class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[home about]

  def home
    @pillars = [
      {
        title: "Creator",
        description: "Il creator costruisce un proprio mondo fatto di branch, mappe comuni, trail template e servizi."
      },
      {
        title: "Professionista",
        description: "Il professionista porta competenze, formazione, servizi e valore professionale dentro mappe, percorsi e servizi."
      },
      {
        title: "Persona",
        description: "La persona entra per un bisogno, un miglioramento o una ricerca di conoscenza e costruisce nel tempo le proprie mappe del mondo."
      }
    ]

    @journeys = [
      "Malattia / bisogno",
      "Benessere / miglioramento",
      "Conoscenza"
    ]
  end

  def about
  end
end
