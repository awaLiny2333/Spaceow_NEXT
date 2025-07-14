import { animationDefault } from '../hosts/defaults';
import { DisboardLayoutObject } from '../objects/DisboardLayoutObject';
import { FileObject } from '../objects/FileObject';
import { addSizeUnits } from '../utils/storageTools';

@Component
export struct GridSpace {
  @LocalStorageLink('closeFolderRequest') @Watch('onRequestFolderClose') closeFolderRequest: string = '';
  // environment (base)
  @LocalStorageLink('basePath') basePath: string = 'Meow';
  @LocalStorageLink('baseFileObject') baseFileObject: FileObject | undefined = undefined;
  // environment (this)
  @LocalStorageLink('thisPath') thisPath: string = 'Meow';
  @LocalStorageLink('thisFolderSize') thisFolderSize: string = '';
  @LocalStorageLink('thisFileObject') thisFileObject: FileObject | undefined = undefined;
  thisFileObjectID: string = '';
  // environment (history)
  @LocalStorageLink('paths') paths: string[] = [];
  @LocalStorageLink('folderSizes') folderSizes: number[] = [];
  @LocalStorageLink('fileObjects') fileObjects: FileObject[] = [];
  // meow
  @Prop @Watch('onLayoutSizeChange') sideWidth: number = 60;
  @Prop @Watch('onLayoutSizeChange') sideHeight: number = 50;
  @Prop @Watch('onPathChange') fileObject: FileObject | undefined = undefined;
  @Prop isOpened: boolean = false;
  // UI Settings / Params
  space: number = 4;
  grids: number = 14;
  // UI Statuses
  @Prop layer: number = 0;
  unitLengthVP: number = 10;
  maxSideLength: number = 14;
  rows: number = 14;
  cols: number = 14;
  refreshLayoutTimeout: number = 0;
  // Effect
  @State squareOffsetY: number = 100;
  @State squareOpacity: number = 0;
  @State useCompactText: boolean = false;
  // data
  @State layoutObjects: DisboardLayoutObject[] = [];

  aboutToAppear(): void {
    this.thisFileObjectID = this.fileObject?.id || '';

    this.updateUseCompactText();
    this.calculateUnitLength();
    this.process();

    // Respond to layout change
    // triggered by parent GridSpace size change
    setInterval(() => {
      if (0 < this.refreshLayoutTimeout && this.refreshLayoutTimeout <= 10) {
        // Execution of re-arrangement
        this.calculateUnitLength();
        if (this.layer == 0) {
          this.process();
        } else {
          // Cause ForEach contents to refresh
          let temp = this.layoutObjects;
          this.layoutObjects = [];
          this.layoutObjects = temp;
        }
      }
      this.refreshLayoutTimeout -= 10;
      if (this.refreshLayoutTimeout < 0) {
        this.refreshLayoutTimeout = 0;
      }
    }, 10);

    // Premiere animation ;P
    setTimeout(() => {
      this.squareOffsetY = 0;
      this.squareOpacity = 1;
    }, Math.floor(Math.random() * 200));
  }

  onLayoutSizeChange() {
    if (this.layer == 0) {
      this.refreshLayoutTimeout = 200;
    } else {
      this.refreshLayoutTimeout = 50;
    }
  }

  onPathChange() {
    if (!this.fileObject) {
      return;
    }
    if (this.fileObject.id == this.thisFileObjectID) {
      // No actual changes in FileObject
      return;
    }
    this.thisFileObjectID = this.fileObject.id;
    this.refreshLayoutTimeout = 50;
  }

  onRequestFolderClose() {
    if (!this.fileObject) {
      return;
    }
    if (!this.closeFolderRequest) {
      // Empty request
      return;
    }
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
    // Operations (history)
    this.paths.splice(this.paths.length - 1, 1);
    this.folderSizes.splice(this.folderSizes.length - 1, 1);
    this.fileObjects.splice(this.fileObjects.length - 1, 1);
    // Operations (this)
    this.thisPath = this.paths[this.paths.length - 1];
    this.thisFolderSize = addSizeUnits(this.folderSizes[this.folderSizes.length - 1]);
    this.thisFileObject = this.fileObjects[this.paths.length - 1];
    // Set empty
    this.closeFolderRequest = '';
  }

  build() {
    Column() {
      if (this.isOpened && this.fileObject?.type == 0) {
        // Display folder contents
        ForEach(this.layoutObjects, (item: DisboardLayoutObject, index: number) => {
          GridSpace({
            fileObject: item.fileObject,
            sideWidth: this.unitLengthVP * this.layoutObjects[index].sideLength - this.space,
            sideHeight: this.unitLengthVP * this.layoutObjects[index].sideLength - this.space,
            layer: this.layer + 1,
          })
            .position({
              top: this.layoutObjects[index].row * this.unitLengthVP,
              left: this.layoutObjects[index].col * this.unitLengthVP
            })
            .animation(animationDefault())
        }, (item: DisboardLayoutObject) => {
          return item.fileObject.path;
        })
      } else {
        // Display file info
        Column() {
          Text(this.fileObject?.getName())
            .fontSize((this.useCompactText ? 0.12 : 0.2) * this.sideWidth)
            .fontColor($r('app.color.accent'))
            .fontWeight(FontWeight.Bold)
            .maxLines(this.useCompactText ? 5 : 3)
          // .animation(animationDefault())
          Text(addSizeUnits(this.fileObject?.size || 0))
            .fontSize((this.useCompactText ? 0.1 : 0.15) * this.sideWidth)
            .fontColor($r('app.color.accent'))
            .fontWeight(FontWeight.Medium)
            // .animation(animationDefault())
            .opacity(0.75)
        }
        .width('100%')
        .height('100%')
        .padding(this.sideWidth * 0.05)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.End)
      }
    }
    .height(this.sideHeight)
    .width(this.sideWidth)
    .backgroundColor(this.isOpened ? $r('app.color.start_window_background') : $r('app.color.supplementary'))
    .opacity(this.squareOpacity * (this.isOpened ? 1 : ((this.fileObject?.path.indexOf(this.thisPath) || 0) == 0 ? 1 : 0.5)))
    .offset({ y: this.squareOffsetY })
    .animation(animationDefault())
    .padding(this.layer == 0 ? { left: this.space, top: this.space } : {})
    .clip(true)
    .borderRadius(Math.max(0, 16 - this.layer * 1.25))
    .onClick(() => {
      if (this.fileObject) {
        // Not a folder
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
          return;
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
    this.unitLengthVP = ((Math.min(this.sideWidth, this.sideHeight) + spaceOffset) / this.grids);
    // Update rows and cols of layout
    this.rows = Math.floor((this.sideHeight + spaceOffset) / this.unitLengthVP);
    this.cols = Math.floor((this.sideWidth + spaceOffset) / this.unitLengthVP);
    // Update maxLength of squares
    this.maxSideLength = Math.min(this.rows, this.cols);
  }

  private process() {
    if (!this.fileObject) {
      return;
    }
    if (this.fileObject.type != 0) {
      return;
    }

    // Timer head
    // let timerStart = Date.now();

    // Init layoutObjects
    this.layoutObjects = [];
    let lo: DisboardLayoutObject[] = [];
    // Init disboard
    let disboard: boolean[][] = [];
    for (let i = 0; i < this.rows; i++) {
      disboard.push(new Array(this.cols).fill(false));
    }

    // Traverse all children and fill processedArrays
    for (let index = 0; index < this.fileObject.childrens.length; index++) {
      const fo = this.fileObject.childrens[index];
      // Calculate proper side length
      let squareSideLength = Math.round(Math.sqrt(fo.size / this.fileObject.size * this.rows * this.cols));
      // Too small process
      squareSideLength = Math.max(1, squareSideLength);
      // Too big process
      if (squareSideLength >= this.maxSideLength) {
        squareSideLength = this.maxSideLength;
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

    // Fill and Determine Position for each square
    let objects = 0;
    for (let index = 0; index < lo.length; index++) {
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
            if (this.canPlaceAtGrid(r, c, foSideLen, disboard)) {
              lo[index].row = r;
              lo[index].col = c;
              this.fillGrid(r, c, foSideLen, disboard);
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
      if (disboard[this.rows - 1][this.cols - 1]) {
        // Disboard full
        break;
      }
      objects++;
    }

    // Cut over length
    if (objects < lo.length) {
      // console.log('cut @ ' + (objects + 1).toString() + '/' + lo.length.toString());
      this.layoutObjects = lo.slice(0, objects + 1);
    } else {
      this.layoutObjects = lo;
    }

    // Log time
    // let timerEnd = Date.now();
    // console.log('  '.repeat(this.layer) + '[GridSpace] Rearranged [' + this.fileObject?.path + '] in ' + (timerEnd - timerStart).toString() + ' ms!');
  }

  private updateUseCompactText() {
    if (!this.fileObject) {
      this.useCompactText = false;
    } else {
      this.useCompactText = this.fileObject.getName().length > 16;
    }
  }

  private canPlaceAtGrid(ro: number, co: number, sl: number, disboard: boolean[][]) {
    if (ro + sl > this.rows || co + sl > this.cols) {
      // Index out of bounds
      return false;
    }
    for (let i = 0; i < sl; i++) {
      try {
        if (disboard[ro][co+i]) {
          return false;
        }
        if (disboard[ro+i][co]) {
          return false;
        }
      } catch (e) {
        // Index out of bounds? or other issues?
        console.error(e);
        return false;
      }
    }
    return true;
  }

  private fillGrid(ro: number, co: number, sl: number, disboard: boolean[][]) {
    for (let r = 0; r < sl; r++) {
      for (let c = 0; c < sl; c++) {
        disboard[ro+r][co+c] = true;
      }
    }
  }
}