import { CapsuleText } from '../components/CapsuleText';
import { GridSpace } from '../components/GridSpace';
import { animationDefault, clickEffectDefault } from '../hosts/defaults';
import { FileObject } from '../objects/FileObject';
import { copy } from '../utils/clipboardTools';
import { addSizeUnits, selectDirectory } from '../utils/storageTools';
import { common, OpenLinkOptions } from "@kit.AbilityKit";
import { fileUri } from "@kit.CoreFileKit";

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
  @StorageLink('thisFileObject') thisFileObject: FileObject | undefined = undefined;
  @StorageLink('paths') paths: string[] = [];
  @StorageLink('sizes') sizes: number[] = [];
  @StorageLink('fileObjects') fileObjects: FileObject[] = [];
  @State baseFolderSize: string = '';
  @StorageLink('thisFolderSize') thisFolderSize: string = '';
  // This
  @StorageLink('baseFileObject') baseFileObject: FileObject | undefined = undefined;
  @State maxSideLength: number = 100;
  @State thisSideLength: number = 100;

  onWindowAreaChange() {
    this.maxSideLength = Math.min(this.windowHeight - 70, this.windowWidth);
  }

  build() {
    Column({ space: 10 }) {
      Scroll() {
        Row({ space: 10 }) {
          Button('Back ↑')
            .fontColor($r('app.color.accent'))
            .fontWeight(FontWeight.Bold)
            .backgroundColor($r('app.color.supplementary'))
            .opacity(this.thisPath == this.basePath ? 0.5 : 1)
            .animation(animationDefault())
            .onClick(() => {
              if (this.basePath != this.thisPath) {
                this.closeFolder = '';
                this.closeFolder = this.thisPath;
              }
            })
            .keyboardShortcut(FunctionKey.ESC, [])
          Button('Select  󰂺 ')
            .fontColor($r('app.color.accent'))
            .fontWeight(FontWeight.Bold)
            .backgroundColor($r('app.color.supplementary'))
            .onClick(() => {
              selectDirectory().then((fileObject) => {
                this.baseFileObject = fileObject;
                this.show();
              })
            })
          Button(this.thisPath)
            .fontColor($r('app.color.accent'))
            .fontWeight(FontWeight.Bold)
            .backgroundColor($r('app.color.supplementary'))
            .animation(animationDefault())
            .onClick(() => {
              copy(this.thisPath);
            })
          Button('Go to Directory  󰱰 ')
            .fontColor($r('app.color.accent'))
            .fontWeight(FontWeight.Bold)
            .backgroundColor($r('app.color.supplementary'))
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
          Button('Open as New  󰃍 ')
            .fontColor($r('app.color.accent'))
            .fontWeight(FontWeight.Bold)
            .backgroundColor($r('app.color.supplementary'))
            .opacity(this.thisPath == this.basePath ? 0.5 : 1)
            .animation(animationDefault())
            .onClick(() => {
              this.baseFileObject = this.thisFileObject;
              this.show();
            })
          Button(this.thisFolderSize + ' / ' + this.baseFolderSize)
            .fontColor($r('app.color.accent'))
            .fontWeight(FontWeight.Bold)
            .backgroundColor($r('app.color.supplementary'))
            .visibility(this.baseFolderSize == '' ? Visibility.None : Visibility.Visible)
            .animation(animationDefault())
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