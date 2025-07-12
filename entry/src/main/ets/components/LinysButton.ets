import { animationDefault } from '../hosts/defaults';

@Component
export default struct LinysButton {
  @Prop text: ResourceStr = '';

  build() {
    Button(this.text)
      .fontColor($r('app.color.accent'))
      .fontWeight(FontWeight.Bold)
      .backgroundColor($r('app.color.supplementary'))
      .animation(animationDefault())
  }
}