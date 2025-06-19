import { fileIo } from "@kit.CoreFileKit";

export enum FileObjectType {
  Directory,
  File,
  Other
}

export class FileObject {
  path: string;
  size: number;
  type: FileObjectType;
  childrens: FileObject[] = [];

  constructor(path: string, size?: number) {
    this.path = path;
    this.size = size || 0;

    let stat = fileIo.statSync(path);
    let isDirectory = stat.isDirectory();
    let isFile = stat.isFile();

    if (isDirectory) {
      this.type = FileObjectType.Directory;
    } else if (isFile) {
      this.type = FileObjectType.File;
      this.size = stat.size;
    } else {
      this.type = FileObjectType.Other;
    }
  }

  update() {
    if (this.type != FileObjectType.Directory) {
      return this.size;
    }

    this.size = 0;
    this.childrens = [];

    let dir_list = fileIo.listFileSync(this.path);
    for (let index = 0; index < dir_list.length; index++) {
      let fo = new FileObject(this.path + '/' + dir_list[index]);
      this.size += fo.update();
      this.childrens.push(fo);
    }

    return this.size;
  }

  getName() {
    let pathSplit = this.path.split('/');
    return pathSplit[pathSplit.length-1];
  }
}