import fused/process.{type Pid, type Selector, selector_recv}
import fused/promise.{type Promise}
import gleam/option.{type Option, None, Some}

pub fn start(
  self self: Pid,
  init init: fn(Pid) -> #(state, Selector(message), returning),
  update update: fn(Pid, state, message) -> Option(state),
) -> Promise(returning) {
  let #(return_send, return_recv) = process.new()
  {
    use self <- process.spawn(self:)
    let #(state, selector, return) = init(self)
    process.send(return_send, return)
    run(selector:, self:, state:, update:)
  }
  process.recv(return_recv)
}

fn run(
  selector selector: Selector(message),
  self self: Pid,
  state state: state,
  update update: fn(Pid, state, message) -> Option(state),
) -> Promise(Nil) {
  use message <- promise.await(selector_recv(self:, from: selector))
  case update(self, state, message) {
    Some(state) -> run(selector:, self:, state:, update:)
    None -> promise.resolve(Nil)
  }
}
