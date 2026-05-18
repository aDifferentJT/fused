@target(javascript)
import gleam/javascript/promise.{type Promise}
@target(javascript)
import gleam/list
@target(javascript)
import interior/cell.{type Cell}

@target(javascript)
pub fn is_available() -> Bool {
  True
}

@target(erlang)
pub fn is_available() -> Bool {
  False
}

@target(javascript)
type SendImpl(a) =
  fn(#(a, RecvImpl(a))) -> Nil

@target(javascript)
pub opaque type RecvImpl(a) {
  RecvImpl(Promise(#(a, RecvImpl(a))))
}

@target(javascript)
fn new_impl() -> #(SendImpl(a), RecvImpl(a)) {
  let #(recv, send) = promise.start()
  let send = send
  let recv = RecvImpl(recv)
  #(send, recv)
}

@target(javascript)
fn send_impl(send: SendImpl(a), x: a) -> SendImpl(a) {
  let old_send = send
  let #(new_send, recv) = new_impl()
  old_send(#(x, recv))
  new_send
}

@target(javascript)
fn recv_impl(recv: RecvImpl(a)) -> Promise(#(a, RecvImpl(a))) {
  let RecvImpl(recv) = recv
  recv
}

@target(javascript)
pub opaque type Send(a) {
  Send(Cell(SendImpl(a)))
}

@target(javascript)
pub opaque type Recv(a) {
  Recv(Cell(RecvImpl(a)))
}

@target(javascript)
pub fn new() -> #(Send(a), Recv(a)) {
  let #(send, recv) = new_impl()
  let send = Send(cell.new(send))
  let recv = Recv(cell.new(recv))
  #(send, recv)
}

@target(javascript)
pub fn send(send: Send(a), x: a) -> Nil {
  let Send(send) = send
  let send2 = cell.get(send)
  let send2 = send_impl(send2, x)
  cell.set(send, send2)
}

@target(javascript)
fn recv_peek(recv: Recv(a)) -> Promise(#(a, fn() -> Nil)) {
  let Recv(recv) = recv
  use #(x, impl) <- promise.map(
    recv
    |> cell.get
    |> recv_impl,
  )
  #(x, fn() { cell.set(recv, impl) })
}

@target(javascript)
pub fn recv(recv: Recv(a)) -> Promise(a) {
  use #(x, commit) <- promise.map(recv_peek(recv))
  commit()
  x
}

@target(javascript)
pub type Selector(a) {
  Selector(
    recvs: List(Promise(#(a, fn() -> Nil))),
    monitors: List(fn(Pid) -> a),
  )
}

@target(javascript)
pub fn new_selector() -> Selector(a) {
  Selector(recvs: [], monitors: [])
}

@target(javascript)
pub fn select(selector: Selector(a), for receiver: Recv(a)) -> Selector(a) {
  let Selector(recvs:, ..) = selector
  let recvs = [recv_peek(receiver), ..recvs]
  Selector(..selector, recvs:)
}

@target(javascript)
pub fn select_map(
  selector: Selector(a),
  for receiver: Recv(b),
  mapping transform: fn(b) -> a,
) -> Selector(a) {
  let Selector(recvs:, ..) = selector
  let recvs = [
    recv_peek(receiver)
      |> promise.map(fn(x) {
        let #(x, commit) = x
        let x = transform(x)
        #(x, commit)
      }),
    ..recvs
  ]
  Selector(..selector, recvs:)
}

@target(javascript)
pub fn select_monitors(
  selector: Selector(payload),
  mapping: fn(Pid) -> payload,
) -> Selector(payload) {
  Selector(..selector, monitors: [mapping, ..selector.monitors])
}

@target(javascript)
pub fn select_specific_monitor(
  selector: Selector(payload),
  monitor: Monitor,
  mapping: fn(Pid) -> payload,
) -> Selector(payload) {
  select_map(selector, for: monitor, mapping:)
}

@target(javascript)
pub fn map_selector(a: Selector(a), b: fn(a) -> b) -> Selector(b) {
  let Selector(recvs:, monitors:) = a
  let recvs = {
    use recv <- list.map(recvs)
    use x <- promise.map(recv)
    let #(x, commit) = x
    let x = b(x)
    #(x, commit)
  }
  let monitors = {
    use monitor <- list.map(monitors)
    fn(x) { x |> monitor |> b }
  }
  Selector(recvs:, monitors:)
}

@target(javascript)
pub fn merge_selector(a: Selector(a), b: Selector(a)) -> Selector(a) {
  let recvs = list.append(a.recvs, b.recvs)
  let monitors = list.append(a.monitors, b.monitors)
  Selector(recvs:, monitors:)
}

@target(javascript)
pub fn selector_recv(self self: Pid, from from: Selector(a)) -> Promise(a) {
  let Selector(recvs:, monitors:) = from
  let recvs =
    list.append(
      {
        use f <- list.flat_map(monitors)
        use monitor <- list.map(cell.get(self.impl).im_monitoring)
        recv_peek(monitor)
        |> promise.map(fn(x) {
          let #(x, commit) = x
          let x = f(x)
          #(x, commit)
        })
      },
      recvs,
    )
  use #(x, commit) <- promise.map(promise.race_list(recvs))
  commit()
  x
}

@target(javascript)
pub opaque type Pid {
  Pid(impl: Cell(PidImpl))
}

@target(javascript)
type PidImpl {
  PidImpl(monitoring_me: List(Send(Pid)), im_monitoring: List(Recv(Pid)))
}

@target(javascript)
pub type Monitor =
  Recv(Pid)

@target(javascript)
pub fn spawn_unlinked(a: fn(Pid) -> Promise(anything)) -> Pid {
  let pid = PidImpl(monitoring_me: [], im_monitoring: [])
  let pid = cell.new(pid)
  let pid = Pid(pid)
  a(pid)
  |> promise.map(fn(_) -> Nil { Nil })
  |> promise.rescue(fn(_) -> Nil {
    let PidImpl(monitoring_me:, ..) = {
      let Pid(pid) = pid
      cell.get(pid)
    }
    {
      use monitor <- list.each(monitoring_me)
      send(monitor, pid)
    }
  })
  pid
}

@target(javascript)
pub fn monitor(self self: Pid, pid pid: Pid) -> Monitor {
  let #(send, recv) = new()
  {
    let Pid(self) = self
    let Pid(pid) = pid
    {
      use PidImpl(im_monitoring:, ..) as self <- cell.update(self)
      let im_monitoring = [recv, ..im_monitoring]
      PidImpl(..self, im_monitoring:)
    }
    {
      use PidImpl(monitoring_me:, ..) as pid <- cell.update(pid)
      let monitoring_me = [send, ..monitoring_me]
      PidImpl(..pid, monitoring_me:)
    }
  }
  recv
}
