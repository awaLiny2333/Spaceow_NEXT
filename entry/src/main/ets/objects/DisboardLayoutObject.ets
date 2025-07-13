import { FileObject } from './FileObject';

export class DisboardLayoutObject {
  fileObject: FileObject;
  sideLength: number;
  row: number;
  col: number;

  constructor(fo: FileObject, sideLength: number, row?: number, col?: number) {
    this.fileObject = fo;
    this.sideLength = sideLength;
    this.row = row || 0;
    this.col = col || 0;
  }
}