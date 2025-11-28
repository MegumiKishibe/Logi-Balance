# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# controllers
pin_all_from "app/javascript/controllers", under: "controllers"

# common sidebar
pin_all_from "app/javascript/common", under: "common"

# delivery_stops.js
pin "delivery_stops", to: "delivery_stops.js"
pin "chartkick" # @5.0.1

# config/importmap.rb
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
pin "@rails/ujs", to: "@rails--ujs.js" # @7.1.3
