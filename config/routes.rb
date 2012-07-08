RailsDiff::Application.routes.draw do
  get ':source/:target' => 'diffs#show', as: :diff, constraints: {source: /[^\/]+/, target: /[^\/]+/}
  put ':source/:target' => 'diffs#update', constraints: {source: /[^\/]+/, target: /[^\/]+/}

  get 'redirect' => 'home#redirect', as: :redirect
  root to: 'home#show'
end
