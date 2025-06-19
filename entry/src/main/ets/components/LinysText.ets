@Component
export struct LinysText {
  @Prop text: string = '';
  build() {
    Text(this.text)
      .fontColor($r('app.color.accent'))
      .fontWeight(FontWeight.Normal)
  }
}