import gleam/dynamic.{type Dynamic}
import gleam/result

pub type Promise(a) =
  a

pub fn await(a: Promise(a), b: fn(a) -> Promise(b)) -> Promise(b) {
  b(a)
}

pub fn await_list(xs: List(Promise(a))) -> Promise(List(a)) {
  xs
}

pub fn map(a: Promise(a), b: fn(a) -> b) -> Promise(b) {
  b(a)
}

pub fn map_try(
  promise: Promise(Result(a, b)),
  callback: fn(a) -> Result(c, b),
) -> Promise(Result(c, b)) {
  result.try(promise, callback)
}

pub fn rescue(a: Promise(a), _: fn(Dynamic) -> a) -> Promise(a) {
  a
}

pub fn resolve(a: a) -> Promise(a) {
  a
}

pub fn tap(promise: Promise(a), callback: fn(a) -> b) -> Promise(a) {
  callback(promise)
  promise
}

pub fn try_await(
  promise: Promise(Result(a, b)),
  callback: fn(a) -> Promise(Result(c, b)),
) -> Promise(Result(c, b)) {
  result.try(promise, callback)
}
