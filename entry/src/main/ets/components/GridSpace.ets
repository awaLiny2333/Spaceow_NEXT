import { animationDefault } from "../hosts/defaults";
import { FileObject } from "../objects/FileObject";
import { sortParallelArraysInPlace } from "../utils/arrayTools";
import { addSizeUnits } from "../utils/storageTools";

@Component
export struct GridSpace {
  // environment
  @StorageProp('grids') @Watch('onGridsChange') grids: number = 10;
  @StorageLink('closeFolder') @Watch('onFolderClose') closeFolder: string = '';
  @StorageLink('basePath') basePath: string = 'Meow';
  @StorageLink('thisPath') thisPath: string = 'Meow';
  @StorageLink('thisFolderSize') thisFolderSize: string = '';
  @StorageLink('thisFileObject') thisFileObject: FileObject | undefined = undefined;
  @StorageLink('baseFileObject') baseFileObject: FileObject | undefined = undefined;
  @StorageLink('paths') paths: string[] = [];
  @StorageLink('sizes') sizes: number[] = [];
  @StorageLink('fileObjects') fileObjects: FileObject[] = [];
  // meow
  @Prop @Watch('onGridsChange') sideWidth: number = 60;
  @Prop @Watch('onGridsChange') sideHeight: number = 50;
  @Prop @Watch('onPathChange') fileObject: FileObject | undefined = undefined;
  @Prop isOpened: boolean = false;
  // UI
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
  @State processedObjects: FileObject[] = [];
  @State processedParams: Array<number>[] = [];
  @State disboard: boolean[][] = [];

  onGridsChange() {
    // this.calculateUnitLength();
    // this.process();
    this.refreshTimeout = 200;
  }

  onPathChange() {
    // this.calculateUnitLength();
    // this.process();
    this.refreshTimeout = 200;
  }

  onFolderClose() {
    if (this.fileObject) {
      if (this.closeFolder == this.basePath) {
        return;
      }
      if (this.closeFolder != this.fileObject.path) {
        return;
      }
      this.isOpened = false;
      this.paths.splice(this.paths.length - 1, 1);
      this.thisPath = this.paths[this.paths.length - 1];
      this.sizes.splice(this.sizes.length - 1, 1);
      this.thisFolderSize = addSizeUnits(this.sizes[this.sizes.length - 1]);
      this.fileObjects.splice(this.fileObjects.length - 1, 1);
      this.thisFileObject = this.fileObjects[this.paths.length - 1];
    }
  }

  aboutToAppear(): void {
    this.calculateUnitLength();
    this.process();
    if (this.fileObject) {
      this.isOpened = (this.thisPath.indexOf(this.fileObject.path)) == 0;
    }

    // Respond to layout change
    setInterval(() => {
      if (0 < this.refreshTimeout && this.refreshTimeout <= 100) {
        this.calculateUnitLength();
        this.process();
      }
      this.refreshTimeout -= 100;
      if (this.refreshTimeout < 0) {
        this.refreshTimeout = 0;
      }
    }, 100)

    setTimeout(() => {
      this.offY = 0;
      this.opac = 1;
    }, Math.floor(Math.random() * 200))
  }

  build() {
    Column() {
      if (this.isOpened && this.fileObject?.type == 0) {
        // Display folder contents
        ForEach(this.processedObjects, (item: FileObject, index: number) => {
          GridSpace({
            fileObject: item,
            sideWidth: this.unitLength * this.processedParams[index][0] - this.space,
            sideHeight: this.unitLength * this.processedParams[index][0] - this.space,
            layer: this.layer + 1,
          })
            .position({
              top: this.processedParams[index][1] * this.unitLength,
              left: this.processedParams[index][2] * this.unitLength
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
    .padding({ left: this.space, top: this.space })
    .clip(true)
    .backgroundColor(this.isOpened ? $r('app.color.start_window_background') : $r('app.color.supplementary'))
    .opacity(this.opac * (this.isOpened ? 1 : ((this.fileObject?.path.indexOf(this.thisPath) || 0) == 0 ? 1 : 0.5)))
    // .borderWidth(this.isOpened ? 1 : 0)
    // .borderColor($r('app.color.accent'))
    .onMouse((me) => {
      if (me.button == MouseButton.Right) {
        // TODO: Options
      }
    })
    .height(this.sideHeight)
    .width(this.sideWidth)
    .offset({ y: this.offY })
    .animation(animationDefault())
    .borderRadius(16)
    // .clickEffect(clickEffectDefault())
    .onClick(() => {
      if (this.fileObject) {
        if (this.fileObject.type != 0) {
          return;
        }
        // Close
        if (this.isOpened) {
          this.closeFolder = '';
          this.closeFolder = this.thisPath;
          return;
        }
        // Open
        if (this.fileObject.path.indexOf(this.thisPath) == 0) {
          this.isOpened = true;
          this.thisPath = this.fileObject.path;
          this.thisFileObject = this.fileObject;
          this.thisFolderSize = addSizeUnits(this.fileObject.size);
          this.paths.push(this.fileObject.path);
          this.sizes.push(this.fileObject.size);
          this.fileObjects.push(this.fileObject);
        }
      }
    })
  }

  private calculateUnitLength() {
    this.unitLength = ((Math.min(this.sideWidth, this.sideHeight) - this.space) / this.grids);
    // console.log(this.unitLength.toString());
    this.rows = Math.floor((this.sideHeight - this.space) / this.unitLength);
    this.cols = Math.floor((this.sideWidth - this.space) / this.unitLength);
    this.maxLength = Math.max(this.rows, this.cols);
  }

  private process() {
    if (this.fileObject) {
      this.processedObjects = [];
      this.processedParams = [];
      let thisSize = this.fileObject.size;

      for (let index = 0; index < this.fileObject.childrens.length; index++) {
        const element = this.fileObject.childrens[index];
        // Calculate proper side length
        let elementSideLength = Math.round(Math.sqrt((element.size / thisSize) * this.rows * this.cols));
        if (elementSideLength < 1) {
          elementSideLength = 1;
        }
        if (elementSideLength >= this.maxLength) {
          elementSideLength = this.maxLength;
          if (this.rows == this.cols && this.fileObject.childrens.length > 1) {
            // Leave some space for other blocks
            elementSideLength -= 1;
          }
        }
        // Push to processed list
        this.processedObjects.push(element);
        this.processedParams.push([elementSideLength]);
      }

      // Sort and cut
      // this.processedObjects.sort((a, b) => (b[1] as number) - (a[1] as number));
      sortParallelArraysInPlace(this.processedObjects, this.processedParams);
      if (this.processedObjects.length > this.rows * this.cols) {
        this.processedObjects = this.processedObjects.slice(0, this.rows * this.cols);
      }

      // Init disboard
      this.disboard = [];
      for (let i = 0; i < this.rows; i++) {
        this.disboard.push(new Array(this.cols).fill(false));
      }

      // Fill and Determine Position
      for (let index = 0; index < this.processedObjects.length; index++) {
        let placed = false;
        while (!placed && (this.processedParams[index][0] as number) > 0) {
          const side = (this.processedParams[index][0] as number);
          let r = 0;
          let c = 0;
          // Traverse rows
          for (r = 0; r < this.rows - side + 1; r++) {
            // Traverse cols
            for (c = 0; c < this.cols - side + 1; c++) {
              if (this.canPlaceAtGrid(r, c, side)) {
                this.processedParams[index].push(r);
                this.processedParams[index].push(c);
                this.fillGrid(r, c, side);
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
            this.processedParams[index][0] = side - 1;
          }
        }
      }
      this.refreshStamp = Date.now().toString();
    }
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