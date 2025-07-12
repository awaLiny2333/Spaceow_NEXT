import { GridSpace } from '../components/GridSpace';
import { FileObject } from '../objects/FileObject';
import { copy } from '../utils/clipboardTools';
import { addSizeUnits, selectDirectory } from '../utils/storageTools';
import { common, OpenLinkOptions } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { MessageEvents, worker } from '@kit.ArkTS';
import LinysButton from '../components/LinysButton';

@Entry
@Component
struct Index {
  // environment
  @StorageLink('windowHeight') @Watch('onWindowAreaChange') windowHeight: number = 100;
  @StorageLink('windowWidth') @Watch('onWindowAreaChange') windowWidth: number = 100;
  @StorageLink('grids') grids: number = 14;
  @StorageLink('closeFolder') closeFolder: string = '';
  // meow
  @StorageLink('basePath') basePath: string = 'Meow';
  @StorageLink('thisPath') thisPath: string = 'Meow';
  @StorageLink('baseFileObject') baseFileObject: FileObject | undefined = undefined;
  @StorageLink('thisFileObject') thisFileObject: FileObject | undefined = undefined;
  @StorageLink('paths') paths: string[] = [];
  @StorageLink('sizes') sizes: number[] = [];
  @StorageLink('fileObjects') fileObjects: FileObject[] = [];
  @StorageLink('baseFolderSize') baseFolderSize: string = 'Total';
  @StorageLink('thisFolderSize') thisFolderSize: string = 'Folder';
  @StorageLink('scanFolderSize') scanFolderSize: string = 'Scanned';
  // Load
  @State isLoading: boolean = false;
  // This
  @State maxSideLength: number = 100;

  onWindowAreaChange() {
    this.maxSideLength = Math.min(this.windowHeight - 70, this.windowWidth);
  }

  build() {
    Column({ space: 10 }) {
      Scroll() {
        Row({ space: 10 }) {
          LinysButton({ text: 'Back ↑' })
            .opacity(this.thisPath == this.basePath ? 0.5 : 1)
            .onClick(() => {
              if (this.basePath != this.thisPath) {
                this.closeFolder = '';
                this.closeFolder = this.thisPath;
              }
            })
            .keyboardShortcut(FunctionKey.ESC, [])
          LinysButton({ text: 'Select  󰂺 ' })
            .enabled(!this.isLoading)
            .onClick(() => {
              this.isLoading = true;
              selectDirectory().then((path) => {
                if (path == '') {
                  this.isLoading = false;
                  return;
                }
                // this.baseFileObject.update();
                let workerInstance = new worker.ThreadWorker("entry/ets/workers/Scanner.ets");
                let scannedSize: number = 0;
                workerInstance.postMessage(path);
                workerInstance.onmessage = (e: MessageEvents): void => {
                  if (typeof e.data == 'number') {
                    // Returned a new file's size
                    scannedSize += e.data;
                    // console.log(scannedSize.toString());
                    this.scanFolderSize = addSizeUnits(scannedSize);
                  } else {
                    // Returned the FileObject
                    this.baseFileObject = e.data as FileObject;
                    workerInstance.terminate();
                    this.show();
                    this.isLoading = false;
                  }
                }
              })
            })
          LinysButton({ text: this.thisPath })
            .onClick(() => {
              copy(this.thisPath);
            })
          LinysButton({ text: 'Go to Directory  󰱰 ' })
            .onClick(() => {
              // Open folder
              let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
              let link: string = 'filemanager://openDirectory';
              let openLinkOptions: OpenLinkOptions = {
                parameters: {
                  'fileUri': fileUri.getUriFromPath(this.thisPath)
                }
              };
              try {
                context.openLink(link, openLinkOptions)
              } catch (e) {
                console.error(e);
              }
            })
          LinysButton({ text: 'Open as New  󰃍 ' })
            .opacity(this.thisPath == this.basePath ? 0.5 : 1)
            .onClick(() => {
              this.baseFileObject = this.thisFileObject;
              this.show();
            })
          LinysButton({ text: this.thisFolderSize + ' / ' + this.baseFolderSize + '  󰄝 ' })
          LinysButton({ text: this.scanFolderSize + '  󰀩 ' })
        }
      } // Title
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .edgeEffect(EdgeEffect.Spring)

      GridSpace({
        sideWidth: this.windowWidth - 20,
        sideHeight: this.windowHeight - 70,
        fileObject: this.baseFileObject,
        isOpened: true
      })
    }
    .onAreaChange((_o, n) => {
      this.windowWidth = n.width as number;
      this.windowHeight = n.height as number;
    })
    .padding(10)
    .height('100%')
    .width('100%')
  }

  show() {
    if (!this.baseFileObject) {
      return;
    }
    this.basePath = this.baseFileObject.path;
    this.thisPath = this.basePath;
    this.thisFileObject = this.baseFileObject;
    this.paths = [this.basePath];
    this.sizes = [this.baseFileObject.size];
    this.fileObjects = [this.baseFileObject];
    this.baseFolderSize = addSizeUnits(this.baseFileObject.size);
  }
}
