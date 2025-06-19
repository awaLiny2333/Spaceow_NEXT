import { clickEffectDefault } from "../hosts/defaults";

@Component
export struct CapsuleText {
  @Prop text: string = '';
  build() {
    Text(this.text)
      .fontColor($r('app.color.accent'))
      .fontWeight(FontWeight.Bold)
      .backgroundColor($r('app.color.supplementary'))
      .borderRadius(20)
      .padding({
        left: 15,
        right: 15,
        top: 10,
        bottom: 10
      })
      .clickEffect(clickEffectDefault())
  }
}