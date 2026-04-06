rails g authentication
rails g scaffold Lead user:references name:string email:string message:text
rails g scaffold Profile user:references lead:references name:string email:string
rails g scaffold datacontact name:string email:string message:text
bin/rails g scaffold Branch [folder brand]
bin/rails g scaffold Domain branch:references name:string language:string
bin/rails g scaffold Map branch:references name:string description:text
bin/rails g scaffold Journey map:references name:string description:text status:string type_journey:[esplorazione, validazione, attivo] (devo mettere original journey in teoria perchè poi quando è fisso il journey esplorazione puoi passare a guida ma bisognerebbe mettere il journey di riferimento... che è quello stabile perchè se si fanno tentativi... poi si sceglie l'ultima versione stabile )
bin/rails g scaffold Service journey:references name:string description:text price:decimal
bin/rails g scaffold Journeytemplate services:journey journey:references name:string description:text status:string [esplorazione, validazione, attivo]
bin/rails g scaffold EventDate user:references name:string description:text date:datetime x:integer y:integer x:integer y:integer
bin/rails g scaffold Post event_date:references user:references title:string content:text [quiz o post ]
bin/rails g scaffold Step journey:references name:string description:text date:datetime event_date:references

bin/rails g scaffold Role Service:references name:string
bin/rails g scaffold Ticket journey:references step:references event_date:references user:references role:references status:string
