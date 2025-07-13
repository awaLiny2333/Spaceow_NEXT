import { animationDefault } from '../hosts/defaults';
import { DisboardLayoutObject } from '../objects/DisboardLayoutObject';
import { FileObject } from '../objects/FileObject';
import { addSizeUnits } from '../utils/storageTools';

@Component
export struct GridSpace {
  @LocalStorageLink('windowId') windowId: number = Date.now();
  @LocalStorageLink('closeFolderRequest') @Watch('onRequestFolderClose') closeFolderRequest: string = '';
  // environment (base)
  @LocalStorageLink('basePath') basePath: string = 'Meow';
  @LocalStorageLink('baseFileObject') baseFileObject: FileObject | undefined = undefined;
  // environment (this)
  @LocalStorageLink('thisPath') thisPath: string = 'Meow';
  @LocalStorageLink('thisFolderSize') thisFolderSize: string = '';
  @LocalStorageLink('thisFileObject') thisFileObject: FileObject | undefined = undefined;
  // environment (history)
  @LocalStorageLink('paths') paths: string[] = [];
  @LocalStorageLink('folderSizes') folderSizes: number[] = [];
  @LocalStorageLink('fileObjects') fileObjects: FileObject[] = [];
  // meow
  @Prop @Watch('onGridsChange') sideWidth: number = 60;
  @Prop @Watch('onGridsChange') sideHeight: number = 50;
  @Prop @Watch('onPathChange') fileObject: FileObject | undefined = undefined;
  @Prop isOpened: boolean = false;
  // UI
  @State lastFileObjectID: string = '';
  @StorageProp('grids') @Watch('onGridsChange') grids: number = 10;
  @Prop layer: number = 0;
  @State unitLength: number = 10;
  @State space: number = 4;
  @State rows: number = 14;
  @State cols: number = 14;
  @State maxLength: number = 14;
  @State refreshStamp: string = '';
  @State refreshTimeout: number = 0;
  // Effect
  @State offY: number = 100;
  @State opac: number = 0;
  // data
  @State layoutObjects: DisboardLayoutObject[] = [];
  // @State processedObjects: FileObject[] = [];
  // @State processedParams: Array<number>[] = [];
  @State disboard: boolean[][] = [];

  aboutToAppear(): void {
    this.calculateUnitLength();
    this.process();
    if (this.fileObject) {
      this.isOpened = (this.thisPath.indexOf(this.fileObject.path)) == 0;
      this.lastFileObjectID = this.fileObject.id;
      // console.log('[GridSpace] Render square ' + this.fileObject.path);
    }

    // Respond to layout change
    setInterval(() => {
      if (0 < this.refreshTimeout && this.refreshTimeout <= 10) {
        this.calculateUnitLength();
        this.process();
      }
      this.refreshTimeout -= 10;
      if (this.refreshTimeout < 0) {
        this.refreshTimeout = 0;
      }
    }, 10)

    setTimeout(() => {
      this.offY = 0;
      this.opac = 1;
    }, Math.floor(Math.random() * 200))
  }

  onGridsChange() {
    console.log('onGridsChange! window: ' + this.windowId.toString() + ' new: ' + this.grids.toString());
    this.refreshTimeout = 200;
  }

  onPathChange() {
    if (!this.fileObject) {
      // console.log('onPathChange ignored due to undefined fileObject.');
      return;
    }
    if (this.fileObject.id == this.lastFileObjectID) {
      // console.log('onPathChange ignored due to no change in this.fileObject.id.');
      return;
    }
    this.lastFileObjectID = this.fileObject.id;
    console.log('onPathChange!  window: ' + this.windowId.toString() + ' new: ' + this.fileObject.path);
    this.refreshTimeout = 200;
  }

  onRequestFolderClose() {
    if (this.fileObject && this.closeFolderRequest) {
      if (this.closeFolderRequest == this.basePath) {
        // Impossible to close base file :O
        return;
      }
      if (this.closeFolderRequest != this.fileObject.path) {
        // If not closing me
        return;
      }
      // If is closing me (?!
      this.isOpened = false;
      this.paths.splice(this.paths.length - 1, 1);
      this.thisPath = this.paths[this.paths.length - 1];
      this.folderSizes.splice(this.folderSizes.length - 1, 1);
      this.thisFolderSize = addSizeUnits(this.folderSizes[this.folderSizes.length - 1]);
      this.fileObjects.splice(this.fileObjects.length - 1, 1);
      this.thisFileObject = this.fileObjects[this.paths.length - 1];
    }
    this.closeFolderRequest = '';
  }

  build() {
    Column() {
      if (this.isOpened && this.fileObject?.type == 0) {
        // Display folder contents
        ForEach(this.layoutObjects, (item: DisboardLayoutObject, index: number) => {
          GridSpace({
            fileObject: item.fileObject,
            sideWidth: this.unitLength * this.layoutObjects[index].sideLength - this.space,
            sideHeight: this.unitLength * this.layoutObjects[index].sideLength - this.space,
            layer: this.layer + 1,
          })
            .position({
              top: this.layoutObjects[index].row * this.unitLength,
              left: this.layoutObjects[index].col * this.unitLength
            })
        }, (item: FileObject) => {
          return item.path + this.refreshStamp;
        })
      } else {
        // Display file info
        Column() {
          if ((this.fileObject?.getName().length || 1) < 16) {
            Text(this.fileObject?.getName())
              .fontColor($r('app.color.accent'))
              .fontSize(this.sideWidth * 0.2)
              .fontWeight(FontWeight.Bold)
              .maxLines(3)
            Text(addSizeUnits(this.fileObject?.size || 0))
              .fontSize(this.sideWidth * 0.15)
              .fontColor($r('app.color.accent'))
              .fontWeight(FontWeight.Medium)
              .opacity(0.75)
          } else {
            Text(this.fileObject?.getName())
              .fontColor($r('app.color.accent'))
              .fontSize(this.sideWidth * 0.12)
              .fontWeight(FontWeight.Bold)
              .maxLines(5)
            Text(addSizeUnits(this.fileObject?.size || 0))
              .fontSize(this.sideWidth * 0.1)
              .fontColor($r('app.color.accent'))
              .fontWeight(FontWeight.Medium)
              .opacity(0.75)
          }
        }
        .width('100%')
        .height('100%')
        .padding(this.sideWidth * 0.05)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.End)
      }
    }
    .padding(this.layer == 0 ? { left: this.space, top: this.space } : {})
    .clip(true)
    .backgroundColor(this.isOpened ? $r('app.color.start_window_background') : $r('app.color.supplementary'))
    .opacity(this.opac * (this.isOpened ? 1 : ((this.fileObject?.path.indexOf(this.thisPath) || 0) == 0 ? 1 : 0.5)))
    .height(this.sideHeight)
    .width(this.sideWidth)
    .offset({ y: this.offY })
    .animation(animationDefault())
    .borderRadius(Math.max(0, 16 - this.layer * 1.25))
    .onClick(() => {
      if (this.fileObject) {
        if (this.fileObject.type != 0) {
          return;
        }
        // Close
        if (this.isOpened) {
          this.closeFolderRequest = '';
          this.closeFolderRequest = this.thisPath;
          return;
        }
        // Open
        if (this.fileObject.path.indexOf(this.thisPath) == 0) {
          this.isOpened = true;
          this.thisPath = this.fileObject.path;
          this.thisFileObject = this.fileObject;
          this.thisFolderSize = addSizeUnits(this.fileObject.size);
          this.paths.push(this.fileObject.path);
          this.folderSizes.push(this.fileObject.size);
          this.fileObjects.push(this.fileObject);
        }
      }
    })
    .onMouse((me) => {
      if (me.button == MouseButton.Right && me.action == MouseAction.Press) {
        // TODO: Options
      }
    })
  }

  /**
   * Calculates and refreshes the unitLength
   * */
  private calculateUnitLength() {
    // leave more space if is the base layer
    let spaceOffset = (this.layer == 0 ? -1 : 1) * this.space;
    // Calculates default unitLength
    this.unitLength = ((Math.min(this.sideWidth, this.sideHeight) + spaceOffset) / this.grids);
    // Update rows and cols of layout
    this.rows = Math.floor((this.sideHeight + spaceOffset) / this.unitLength);
    this.cols = Math.floor((this.sideWidth + spaceOffset) / this.unitLength);
    // Update maxLength of squares
    this.maxLength = Math.min(this.rows, this.cols);
  }

  private process() {
    if (!this.fileObject) {
      return;
    }

    // Init layoutObjects
    let lo: DisboardLayoutObject[] = [];
    // Init disboard
    this.disboard = [];
    for (let i = 0; i < this.rows; i++) {
      this.disboard.push(new Array(this.cols).fill(false));
    }

    // Traverse all children and fill processedArrays
    for (let index = 0; index < this.fileObject.childrens.length; index++) {
      const fo = this.fileObject.childrens[index];
      // Calculate proper side length
      let squareSideLength = Math.round(Math.sqrt(fo.size / this.fileObject.size * this.rows * this.cols));
      // Too small process
      squareSideLength = Math.min(1, squareSideLength);
      // Too big process
      if (squareSideLength >= this.maxLength) {
        squareSideLength = this.maxLength;
        if (this.rows == this.cols && this.fileObject.childrens.length > 1) {
          // Leave some space for other blocks
          squareSideLength -= 1;
        }
      }
      // Push to processed list
      lo.push(new DisboardLayoutObject(fo, squareSideLength));
    }

    // Sort
    lo.sort((a, b) => b.sideLength - a.sideLength);

    // Fill and Determine Position
    let index = 0;
    for (index = 0; index < lo.length; index++) {
      let fo = lo[index];
      let placed = false;
      // Continuously try to put
      while (!placed && fo.sideLength > 0) {
        let foSideLen = fo.sideLength;
        let r = 0;
        let c = 0;
        // Traverse rows
        for (r = 0; r < this.rows - foSideLen + 1; r++) {
          // Traverse cols
          for (c = 0; c < this.cols - foSideLen + 1; c++) {
            if (this.canPlaceAtGrid(r, c, foSideLen)) {
              lo[index].row = r;
              lo[index].col = c;
              this.fillGrid(r, c, foSideLen);
              placed = true;
              break;
            }
          }
          // Check if placed on this row
          if (placed) {
            break;
          }
        }
        // try to fit in by shrink size ?!
        if (!placed) {
          fo.sideLength = foSideLen - 1;
        }
      }
      // Stop putting if full
      if (!this.canPlaceAtGrid(this.rows - 1, this.cols - 1, 1)) {
        // Disboard full
        console.log('meow')
        break;
      }
    }

    // Cut over length
    if (index != lo.length) {
      console.log('cut')
      this.layoutObjects = lo.slice(0, index + 1);
    } else {
      this.layoutObjects = lo;
    }
    // After put notify ForEach refresh
    this.refreshStamp = Date.now().toString();
  }

  private canPlaceAtGrid(ro: number, co: number, sl: number) {
    if (ro + sl > this.rows || co + sl > this.cols) {
      // Index out of bounds
      return false;
    }
    for (let index = 0; index < sl; index++) {
      if (this.disboard[ro][co+index]) {
        return false;
      }
      if (this.disboard[ro+index][co]) {
        return false;
      }
    }
    return true;
  }

  private fillGrid(ro: number, co: number, sl: number) {
    for (let r = 0; r < sl; r++) {
      for (let c = 0; c < sl; c++) {
        this.disboard[ro+r][co+c] = true;
      }
    }
  }
}