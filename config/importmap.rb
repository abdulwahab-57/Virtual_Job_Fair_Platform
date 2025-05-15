# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "lodash", to: "lodash.min.js"
pin "react", to: "react.min.js"
pin "react-dom", to: "react-dom.min.js"
pin "redux", to: "redux.min.js"
pin "redux-thunk", to: "redux-thunk.js"
pin "zoom-meeting-embedded", to: "zoom-meeting-embedded-3.11.2.min.js"
