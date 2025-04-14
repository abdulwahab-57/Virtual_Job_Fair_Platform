// Load all Stimulus controllers automatically
import { application } from "./application"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

// Load all controllers in the controllers directory and subdirectories
const context = require.context(".", true, /_controller\.js$/)
application.load(definitionsFromContext(context))

// Register any custom controllers that aren't auto-loaded
import ChatController from "./chat_controller"
import ChatMediaController from "./chat_media_controller"
import ChatVoiceController from "./chat_voice_controller"
import ChatUiController from "./chat_ui_controller"

application.register("chat", ChatController)
application.register("chat-media", ChatMediaController)
application.register("chat-voice", ChatVoiceController)
application.register("chat-ui", ChatUiController)