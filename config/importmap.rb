# app entry
pin "application"

# hotwire
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# controllers / common
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/common", under: "common"

# custom js
pin "daily_course_run_stops", to: "daily_course_run_stops.js"

# chart
pin "chartkick"
pin "Chart.bundle", to: "Chart.bundle.js"
pin "chartjs-plugin-annotation"
pin "@kurkle/color", to: "@kurkle--color.js"
pin "chart.js"
pin "chart.js/helpers", to: "chart.js--helpers.js"
pin "chart.js/auto", to: "chart.js--auto.js"

# rails ujs (optional)
pin "@rails/ujs", to: "@rails--ujs.js"
