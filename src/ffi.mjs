import { Ok, Error } from "./gleam.mjs";

export async function saveToClipboard(text) {
  await navigator.clipboard.writeText(text);
}
