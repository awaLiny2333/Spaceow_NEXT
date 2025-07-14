import { GridSpace } from '../components/GridSpace';
import { FileObject } from '../objects/FileObject';
import { copy } from '../utils/clipboardTools';
import { addSizeUnits, selectDirectory } from '../utils/storageTools';
import { common, OpenLinkOptions, Want } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { MessageEvents, worker } from '@kit.ArkTS';
import LinysButton from '../components/LinysButton';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  // GLOBAL
  @StorageLink('newFileObject') newFileObject: FileObject | undefined = undefined;
  // Operations
  @LocalStorageLink('closeFolderRequest') closeFolderRequest: string = '';
  @LocalStorageLink('scanFolderSize') scanFolderSize: string = 'Scanned';
  // Environment (base)
  @LocalStorageLink('basePath') basePath: string = 'Meow';
  @LocalStorageLink('baseFolderSize') baseFolderSize: string = 'Total';
  @LocalStorageLink('baseFileObject') baseFileObject: FileObject | undefined = undefined;
  // Environment (this)
  @LocalStorageLink('thisPath') thisPath: string = 'Meow';
  @LocalStorageLink('thisFolderSize') thisFolderSize: string = 'Folder';
  @LocalStorageLink('thisFileObject') thisFileObject: FileObject | undefined = undefined;
  // Environment (history)
  @LocalStorageLink('paths') paths: string[] = [];
  @LocalStorageLink('folderSizes') folderSizes: number[] = [];
  @LocalStorageLink('fileObjects') fileObjects: FileObject[] = [];
  // UI
  @LocalStorageLink('windowId') windowId: number = Date.now();
  @LocalStorageLink('windowHeight') @Watch('onWindowAreaChange') windowHeight: number = 100;
  @LocalStorageLink('windowWidth') @Watch('onWindowAreaChange') windowWidth: number = 100;
  // Load
  @State isLoading: boolean = false;
  // This
  @State maxSideLength: number = 100;

  aboutToAppear(): void {
    this.baseFileObject = this.newFileObject;
    this.newFileObject = undefined;
    this.rebaseAndDisplay();
  }

  onBackPress(): boolean | void {
    if (this.basePath != this.thisPath) {
      // If can go back
      this.closeFolderRequest = '';
      this.closeFolderRequest = this.thisPath;
      return true;
    }
    return false;
  }

  onWindowAreaChange() {
    this.maxSideLength = Math.min(this.windowHeight - 70, this.windowWidth);
  }

  build() {
    Column({ space: 10 }) {
      Scroll() {
        Row({ space: 10 }) {
          LinysButton({ text: $r('app.string.main_back') }) // Back
            .opacity(this.thisPath == this.basePath ? 0.5 : 1)
            .onClick(() => {
              if (this.basePath != this.thisPath) {
                this.closeFolderRequest = '';
                this.closeFolderRequest = this.thisPath;
              }
            })
            .keyboardShortcut(FunctionKey.ESC, [])
          LinysButton({ text: $r('app.string.main_select') }) // Select
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
                    console.log('[Scanner] Result received. Worker terminated. ')
                    this.rebaseAndDisplay();
                    this.isLoading = false;
                  }
                }
              })
            })
          LinysButton({ text: $r('app.string.main_go_to_directory') }) // Go to dir
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
                context.openLink(link, openLinkOptions);
              } catch (e) {
                console.error(e);
              }
            })
          LinysButton({ text: $r('app.string.main_open_as_new') }) // Open as new
            .opacity(!this.thisFileObject ? 0.5 : 1)
            .onClick(() => {
              // Open as new
              this.openAsNew(this.thisFileObject);
            })
          LinysButton({ text: this.thisFolderSize + ' / ' + this.baseFolderSize + '  󰄝' }) // Size Proportion
          LinysButton({ text: this.thisPath }) // thisPath
            .onClick(() => {
              copy(this.thisPath);
            })
          LinysButton({ text: this.scanFolderSize + '  󰀩' }) // Scan indicator
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

  rebaseAndDisplay() {
    if (!this.baseFileObject) {
      return;
    }
    this.basePath = this.baseFileObject.path;
    this.thisPath = this.basePath;
    this.thisFileObject = this.baseFileObject;
    this.paths = [this.basePath];
    this.folderSizes = [this.baseFileObject.size];
    this.fileObjects = [this.baseFileObject];
    this.baseFolderSize = addSizeUnits(this.baseFileObject.size);
    this.thisFolderSize = this.baseFolderSize;
  }

  openAsNew(fileObj: FileObject | undefined) {
    if (!fileObj) {
      return;
    }
    // Open new window
    this.newFileObject = fileObj;
    let wantInfo: Want = {
      deviceId: '', // This device
      bundleName: 'com.next.liny.spaceow',
      moduleName: 'entry',
      abilityName: 'EntryAbility',
    };
    let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    context.startAbility(wantInfo).then(() => {
      console.log('startAbility success.');
    }).catch((error: BusinessError) => {
      console.log('startAbility failed: ' + error);
    });
  }
}
