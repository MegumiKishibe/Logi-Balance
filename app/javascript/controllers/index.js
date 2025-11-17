// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// もし個別のコントローラを読み込むならここでimport
// import HelloController from "./hello_controller"
// application.register("hello", HelloController)

export { application }
