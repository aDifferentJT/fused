import gleam/list

pub opaque type Queue(a) {
  Queue(push: List(a), pop: List(a))
}

pub fn new() -> Queue(a) {
  Queue(push: [], pop: [])
}

pub fn push(queue: Queue(a), x: a) -> Queue(a) {
  let Queue(push:, pop:) = queue
  let push = [x, ..push]
  Queue(push:, pop:)
}

pub fn pop(queue: Queue(a)) -> Result(#(a, Queue(a)), Nil) {
  case queue {
    Queue(push: [x], pop: []) -> Ok(#(x, Queue(push: [], pop: [])))
    // For efficiency
    Queue(push:, pop: [x, ..pop]) -> Ok(#(x, Queue(push:, pop:)))
    Queue(push: [], pop: []) -> Error(Nil)
    Queue(push:, pop: []) -> Queue(push: [], pop: list.reverse(push)) |> pop
  }
}
