import gleam/bit_array
import gleam/result
import lustre
import lustre/attribute.{placeholder}
import lustre/element/html.{h2, label, text, textarea}
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

fn view(model: Model) {
  html.main([], [
    label([], [
      h2([], [text("Encoded")]),
      textarea(
        [event.on_input(NewEncodedInput), placeholder("encoded text...")],
        model.encoded,
      ),
    ]),
    label([],[
      h2([], [text("Decoded")]),
      textarea(
      [event.on_input(NewDecodedInput), placeholder("decoded text...")],
      model.decoded,
    )
    ]),
  ])
}
