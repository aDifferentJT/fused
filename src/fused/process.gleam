@target(erlang)
import fused/erlang/process
@target(javascript)
import fused/javascript/process
import fused/promise.{type Promise}

pub type Send(a) =
  process.Send(a)

pub type Recv(a) =
  process.Recv(a)

pub fn new() -> #(Send(a), Recv(a)) {
  process.new()
}

pub fn send(send: Send(a), x: a) -> Nil {
  process.send(send, x)
}

pub fn recv(recv: Recv(a)) -> Promise(a) {
  process.recv(recv)
}

pub type Selector(a) =
  process.Selector(a)

pub fn new_selector() -> Selector(a) {
  process.new_selector()
}

pub fn select(selector: Selector(a), for receiver: Recv(a)) -> Selector(a) {
  process.select(selector, for: receiver)
}

pub fn select_map(
  selector: Selector(a),
  for receiver: Recv(b),
  mapping transform: fn(b) -> a,
) -> Selector(a) {
  process.select_map(selector, for: receiver, mapping: transform)
}

pub fn map_selector(a: Selector(a), b: fn(a) -> b) -> Selector(b) {
  process.map_selector(a, b)
}

pub fn merge_selector(a: Selector(a), b: Selector(a)) -> Selector(a) {
  process.merge_selector(a, b)
}

pub fn selector_recv(self self: Pid, from from: Selector(a)) -> Promise(a) {
  process.selector_recv(self:, from:)
}

pub type Pid =
  process.Pid

pub type Monitor =
  process.Monitor

pub fn spawn_unlinked(a: fn(Pid) -> Promise(anything)) -> Pid {
  process.spawn_unlinked(a)
}

pub fn monitor(self self: Pid, pid pid: Pid) -> Monitor {
  process.monitor(self:, pid:)
}

pub fn select_monitors(
  selector: Selector(payload),
  mapping: fn(Pid) -> payload,
) -> Selector(payload) {
  process.select_monitors(selector, mapping)
}

pub fn select_specific_monitor(
  selector: process.Selector(payload),
  monitor: Monitor,
  mapping: fn(Pid) -> payload,
) -> process.Selector(payload) {
  process.select_specific_monitor(selector, monitor, mapping)
}
