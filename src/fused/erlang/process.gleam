@target(erlang)
import fused/sync/promise.{type Promise}
@target(erlang)
import gleam/erlang/process

@target(erlang)
pub fn is_available() -> Bool {
  True
}

@target(javascript)
pub fn is_available() -> Bool {
  False
}

@target(erlang)
pub type Send(a) =
  process.Subject(a)

@target(erlang)
pub type Recv(a) =
  process.Subject(a)

@target(erlang)
pub fn new() -> #(Send(a), Recv(a)) {
  let subject = process.new_subject()
  #(subject, subject)
}

@target(erlang)
pub fn send(send: Send(a), x: a) -> Nil {
  process.send(send, x)
}

@target(erlang)
pub fn recv(recv: Recv(a)) -> Promise(a) {
  process.receive_forever(from: recv)
}

@target(erlang)
pub type Selector(a) =
  process.Selector(a)

@target(erlang)
pub fn new_selector() -> Selector(a) {
  process.new_selector()
}

@target(erlang)
pub fn select(selector: Selector(a), for receiver: Recv(a)) -> Selector(a) {
  process.select(selector, for: receiver)
}

@target(erlang)
pub fn select_map(
  selector: Selector(a),
  for receiver: Recv(b),
  mapping transform: fn(b) -> a,
) -> Selector(a) {
  process.select_map(selector, for: receiver, mapping: transform)
}

@target(erlang)
pub fn map_selector(a: Selector(a), b: fn(a) -> b) -> Selector(b) {
  process.map_selector(a, b)
}

@target(erlang)
pub fn merge_selector(a: Selector(a), b: Selector(a)) -> Selector(a) {
  process.merge_selector(a, b)
}

@target(erlang)
pub fn selector_recv(self self: Pid, from from: Selector(a)) -> a {
  assert self == process.self()
  process.selector_receive_forever(from:)
}

@target(erlang)
pub type Pid =
  process.Pid

@target(erlang)
pub type Monitor =
  process.Monitor

@target(erlang)
pub fn spawn(parent _: Pid, f f: fn(Pid) -> anything) -> Pid {
  use <- process.spawn
  f(process.self())
}

@target(erlang)
pub fn spawn_unlinked(f: fn(Pid) -> anything) -> Pid {
  use <- process.spawn_unlinked
  f(process.self())
}

@target(erlang)
pub fn link(self self: Pid, pid pid: Pid) -> Nil {
  assert self == process.self()
  process.link(pid)
  Nil
}

@target(erlang)
pub fn monitor(self self: Pid, pid pid: Pid) -> Monitor {
  assert self == process.self()
  process.monitor(pid)
}

@target(erlang)
pub fn select_monitors(
  selector: Selector(payload),
  mapping: fn(Pid) -> payload,
) -> Selector(payload) {
  process.select_monitors(selector, fn(down) {
    let assert process.ProcessDown(pid:, ..) = down
    mapping(pid)
  })
}

@target(erlang)
pub fn select_specific_monitor(
  selector: Selector(payload),
  monitor: Monitor,
  mapping: fn(Pid) -> payload,
) -> Selector(payload) {
  process.select_specific_monitor(selector, monitor, fn(down) {
    let assert process.ProcessDown(pid:, ..) = down
    mapping(pid)
  })
}
