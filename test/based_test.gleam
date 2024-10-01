import gleeunit
import gleeunit/should
import turing/base64

pub fn main() {
  gleeunit.main()
}

pub fn hello_world_test() {
  base64.encoder("asdasda")
  |> should.equal("what")
}
