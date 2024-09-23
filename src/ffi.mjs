export async function saveToClipboard(text) {
  await navigator.clipboard.writeText(text);
}
