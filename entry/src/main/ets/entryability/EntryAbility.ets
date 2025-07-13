import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
// import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');

      // let windowClass = windowStage.getMainWindowSync(); // Get app main window

      // try {
        // let decorHeight = windowClass.getWindowDecorHeight() || 0;
        // let promise = windowClass.resize(this.vp2px(600), this.vp2px(650 + decorHeight));
        // promise.then(() => {
        //   console.info('Succeeded in changing the window size.');
        // }).catch((err: BusinessError) => {
        //   console.error(`Failed to change the window size. Cause code: ${err.code}, path: ${err.message}`);
        // });
      // } catch (exception) {
      //   console.error(`Failed to change the window size. Cause code: ${exception.code}, path: ${exception.message}`);
      // }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /**
   * Implements a same vp2px as this.getUIContext().vp2px in UI interfaces
   * @param vp the real pixel
   * @returns the px equivalent
   * */
  vp2px(vp: number) {
    return vp * display.getDefaultDisplaySync().densityPixels;
  }
}