Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  get "/graphiql", to: "graphiql#show"
  root to: redirect("/graphiql")
end
