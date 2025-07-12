import { fileIo, picker } from "@kit.CoreFileKit";

export async function selectDirectory() {
  let DocumentSelectOptions = new picker.DocumentSelectOptions();
  DocumentSelectOptions.selectMode = picker.DocumentSelectMode.FOLDER;
  let documentPicker = new picker.DocumentViewPicker();
  try {
    let uris = await documentPicker.select(DocumentSelectOptions);
    let path = fileIo.openSync(uris[0]).path;
    return path;
  } catch (e) {
    console.error(e);
    return '';
  }
}


/**
 * Adds a unit to a size in bytes.
 * @param size_in_bytes A number or bigint, the size in bytes.
 * @returns A string, the connected result of a number of size and its unit.
 * */
export function addSizeUnits(size_in_bytes: number | bigint) {
  let units = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
  let result = BigInt(size_in_bytes);
  let unit = 0;
  while (result > 1000 * 1000 && unit < units.length - 2) {
    result /= 1000n;
    unit += 1;
  }
  // To keep decimal places
  let numberResult = Number(result);
  numberResult /= 1000;
  unit += 1;
  return numberResult.toFixed(2) + " " + units[unit];
}