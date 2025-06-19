import { fileIo, picker } from "@kit.CoreFileKit";
import { FileObject } from "../objects/FileObject";

export async function selectDirectory() {
  let DocumentSelectOptions = new picker.DocumentSelectOptions();
  DocumentSelectOptions.selectMode = picker.DocumentSelectMode.FOLDER;
  let documentPicker = new picker.DocumentViewPicker();
  let uris = await documentPicker.select(DocumentSelectOptions);
  let path = fileIo.openSync(uris[0]).path;
  let fileObject = new FileObject(path);
  fileObject.update();
  return fileObject;
}


/**
 * Adds a unit to a size in bytes.
 * @param size_in_bytes A number or bigint, the size in bytes.
 * @returns A string, the connected result of a number of size and its unit.
 * */
export function addSizeUnits(size_in_bytes: number | bigint) {
  let units = ['Bytes', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB']
  let result = BigInt(size_in_bytes);
  let unit = 0;
  while (result > 1024 * 1024 && unit < units.length - 2) {
    result /= 1024n;
    unit += 1;
  }
  // To keep decimal places
  let numberResult = Number(result);
  numberResult /= 1024;
  unit += 1;
  return numberResult.toFixed(2) + " " + units[unit];
}