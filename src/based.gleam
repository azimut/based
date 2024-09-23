import gleam/bit_array
import gleam/result
import lustre
import lustre/attribute.{type Attribute, placeholder}
import lustre/element/html.{button, h1, h2, label, text, textarea}
import lustre/event

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

type Model {
  Model(encoded: String, decoded: String)
}

fn init(_flags) {
  Model("", "")
}

type Msg {
  NewEncodedInput(String)
  NewDecodedInput(String)
}

fn update(_model, msg) {
  case msg {
    NewEncodedInput(new) -> {
      let decoded =
        bit_array.base64_decode(new)
        |> result.try(bit_array.to_string)
        |> result.unwrap("??")
      Model(encoded: new, decoded: decoded)
    }
    NewDecodedInput(new) -> {
      let encoded =
        bit_array.from_string(new)
        |> bit_array.base64_encode(True)
      Model(decoded: new, encoded: encoded)
    }
  }
}

fn spellcheck(toggle: Bool) -> Attribute(a) {
  case toggle {
    True -> attribute.attribute("spellcheck", "true")
    False -> attribute.attribute("spellcheck", "false")
  }
}

fn view(model: Model) {
  html.main([], [
    h1([], [text("Base64")]),
    label([], [
      h2([], [text("Encoded")]),
      textarea(
        [event.on_input(NewEncodedInput), spellcheck(False), placeholder("aGVsbG8=")],
        model.encoded,
      ),
      button([], [text("Copy")]),
    ]),
    label([], [
      h2([], [text("Decoded")]),
      textarea(
        [event.on_input(NewDecodedInput), spellcheck(False), placeholder("plaintext")],
        model.decoded,
      ),
      button([], [text("Copy")]),
    ]),
  ])
}
