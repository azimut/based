import gleam/bit_array
import gleam/int
import gleam/result
import lustre
import lustre/attribute.{type Attribute, class, placeholder}
import lustre/effect.{type Effect}
import lustre/element/html.{button, div, h1, h2, header, label, text, textarea}
import lustre/event

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

type Model {
  Model(encoded: String, decoded: String)
}

fn save_to_clipboard(text: String) -> Effect(msg) {
  effect.from(fn(_) { do_save_to_clipboard(text) })
}

@external(javascript, "./ffi.mjs", "saveToClipboard")
fn do_save_to_clipboard(_text: String) -> Nil {
  Nil
}

fn init(_flags) {
  #(Model("", ""), effect.none())
}

type Msg {
  NewEncodedInput(String)
  NewDecodedInput(String)
  SaveEncodedInput
  SaveDecodedInput
}

fn update(model: Model, msg: Msg) {
  case msg {
    SaveDecodedInput -> #(model, save_to_clipboard(model.decoded))
    SaveEncodedInput -> #(model, save_to_clipboard(model.encoded))
    NewEncodedInput(new) -> {
      let decoded =
        bit_array.base64_decode(new)
        |> result.try(bit_array.to_string)
        |> result.unwrap("??")
      #(Model(encoded: new, decoded: decoded), effect.none())
    }
    NewDecodedInput(new) -> {
      let encoded =
        bit_array.from_string(new)
        |> bit_array.base64_encode(True)
      #(Model(decoded: new, encoded: encoded), effect.none())
    }
  }
}

fn tabindex(idx: Int) -> Attribute(a) {
  attribute.attribute("tabindex", int.to_string(idx))
}

fn spellcheck(toggle: Bool) -> Attribute(a) {
  case toggle {
    True -> attribute.attribute("spellcheck", "true")
    False -> attribute.attribute("spellcheck", "false")
  }
}

fn view(model: Model) {
  div([class("max-w-screen-lg my-0 mx-auto h-screen")], [
    header([class("flex flex-row justify-center")], [
      h1([class("text-4xl py-3 font-extrabold")], [text("Base64")]),
    ]),
    html.main([class("flex flex-col md:flex-row justify-center h-4/5")], [
      label([class("flex grow flex-col items-center px-2")], [
        h2([class("font-bold")], [text("Encoded")]),
        textarea(
          [
            class("border w-full grow p-1 focus:placeholder-white resize-none"),
            event.on_input(NewEncodedInput),
            spellcheck(False),
            placeholder("aGVsbG8="),
          ],
          model.encoded,
        ),
        button([event.on_click(SaveEncodedInput), tabindex(-1)], [text("Copy")]),
      ]),
      label([class("flex grow flex-col items-center px-2")], [
        h2([class("font-bold")], [text("Decoded")]),
        textarea(
          [
            class("border w-full grow p-1 focus:placeholder-white resize-none"),
            event.on_input(NewDecodedInput),
            spellcheck(False),
            placeholder("plaintext"),
          ],
          model.decoded,
        ),
        button([event.on_click(SaveDecodedInput), tabindex(-1)], [text("Copy")]),
      ]),
    ]),
  ])
}
