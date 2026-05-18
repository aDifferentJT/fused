import gleam/dynamic.{type Dynamic}

@target(erlang)
import fused/sync/promise
@target(javascript)
import gleam/javascript/promise

pub type Promise(a) =
  promise.Promise(a)

pub fn await(a: Promise(a), b: fn(a) -> Promise(b)) -> Promise(b) {
  promise.await(a, b)
}

pub fn await_list(xs: List(Promise(a))) -> Promise(List(a)) {
  promise.await_list(xs)
}

pub fn map(a: Promise(a), b: fn(a) -> b) -> Promise(b) {
  promise.map(a, b)
}

pub fn map_try(
  promise: Promise(Result(a, b)),
  callback: fn(a) -> Result(c, b),
) -> Promise(Result(c, b)) {
  promise.map_try(promise, callback)
}

pub fn rescue(a: Promise(a), b: fn(Dynamic) -> a) -> Promise(a) {
  promise.rescue(a, b)
}

pub fn resolve(a: a) -> Promise(a) {
  promise.resolve(a)
}

pub fn tap(promise: Promise(a), callback: fn(a) -> b) -> Promise(a) {
  promise.tap(promise, callback)
}

pub fn try_await(
  promise: Promise(Result(a, b)),
  callback: fn(a) -> Promise(Result(c, b)),
) -> Promise(Result(c, b)) {
  promise.try_await(promise, callback)
}
