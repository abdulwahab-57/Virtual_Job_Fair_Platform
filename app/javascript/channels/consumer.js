import { createConsumer } from "@rails/actioncable"

let consumer

const createSocketConsumer = () => {
  if (!consumer) {
    consumer = createConsumer()
  }
  return consumer
}

export default createSocketConsumer()