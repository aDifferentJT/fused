import fused/process.{type Pid, type Selector, selector_recv}
import fused/promise.{type Promise}
import gleam/option.{type Option, None, Some}

pub fn start(
  parent parent: Pid,
  init init: fn(Pid) -> Promise(#(state, Selector(message), returning)),
  update update: fn(Pid, state, message) -> Promise(Option(state)),
) -> Promise(returning) {
  let #(return_send, return_recv) = process.new()
  {
    use self <- process.spawn(parent:)
    use #(state, selector, return) <- promise.await(init(self))
    process.send(return_send, return)
    loop(selector:, self:, state:, update:)
  }
  process.recv(return_recv)
}

fn loop(
  selector selector: Selector(message),
  self self: Pid,
  state state: state,
  update update: fn(Pid, state, message) -> Promise(Option(state)),
) -> Promise(Nil) {
  use message <- promise.await(selector_recv(self:, from: selector))
  use state <- promise.await(update(self, state, message))
  case state {
    Some(state) -> loop(selector:, self:, state:, update:)
    None -> promise.resolve(Nil)
  }
}
