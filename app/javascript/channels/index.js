// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus"
import ChatController from "./chat_controller"
import MediaController from "./media_controller"
import MessageController from "./message_controller"

const application = Application.start()

application.register("chat", ChatController)
application.register("media", MediaController)
application.register("message", MessageController)
