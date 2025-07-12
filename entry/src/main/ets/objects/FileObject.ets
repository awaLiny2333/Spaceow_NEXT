import { fileIo } from '@kit.CoreFileKit';
import { collections, ThreadWorkerGlobalScope } from '@kit.ArkTS';

export enum FileObjectType {
  Directory = 0,
  File = 1,
  Other = 2
}

@Sendable
export class FileObject {
  path: string;
  size: number;
  type: number;
  id: string;
  childrens: collections.Array<FileObject> = new collections.Array<FileObject>();

  constructor(path: string, size?: number) {
    this.path = path;
    this.id = path + '@' + Date.now().toString();
    this.size = size || 0;

    let stat = fileIo.statSync(path);
    let isDirectory = stat.isDirectory();
    let isFile = stat.isFile();

    if (isDirectory) {
      this.type = 0;
    } else if (isFile) {
      this.type = 1;
      this.size = stat.size;
    } else {
      this.type = 2;
    }
  }

  update(workerPort?: ThreadWorkerGlobalScope) {
    if (this.type != 0) {
      if (workerPort) {
        // console.log('[FileObject] New file: ' + this.size.toString());
        workerPort.postMessage(this.size);
      }
      return this.size;
    }

    this.size = 0;
    this.childrens = new collections.Array<FileObject>();

    let dir_list = fileIo.listFileSync(this.path);
    for (let index = 0; index < dir_list.length; index++) {
      try {
        let fo = new FileObject(this.path + '/' + dir_list[index]);
        this.size += fo.update(workerPort);
        // console.log(this.path + ' - ' + this.size.toString());
        // callback(this.size);
        this.childrens.push(fo);
      } catch (e) {
        console.error(e);
      }
    }

    return this.size;
  }

  getName() {
    let pathSplit = this.path.split('/');
    return pathSplit[pathSplit.length-1];
  }
}