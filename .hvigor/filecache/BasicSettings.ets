import { getAppSettings, updateAppSettings } from '../../services/appSettings'

interface BasicSettingsCtx {
  onBack: () => void
}

@Component
export struct BasicSettingsPage {
  @Prop ctx: BasicSettingsCtx
  @State pickCount: number = 6
  @State randomMode: boolean = true
  @State deepseekKey: string = ''

  aboutToAppear(): void {
    const { matchPickCount, matchRandom, deepseekApiKey } = getAppSettings()
    this.pickCount = matchPickCount
    this.randomMode = matchRandom
    this.deepseekKey = deepseekApiKey
  }

  private setPickCount(v: number): void {
    const n = Math.max(2, Math.min(20, Math.floor(v)))
    if (n === this.pickCount) return
    this.pickCount = n
    updateAppSettings({ matchPickCount: this.pickCount })
  }

  private toggleRandom(): void {
    this.randomMode = !this.randomMode
    updateAppSettings({ matchRandom: this.randomMode })
  }

  private setApiKey(v: string): void {
    this.deepseekKey = v
    updateAppSettings({ deepseekApiKey: this.deepseekKey })
  }

  build(): void {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.fa_arrow_left')).width(16).height(16)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => this.ctx.onBack())

        Blank().layoutWeight(1)

        Text('应用设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')

        Blank().layoutWeight(1)

        Row().width(44).height(44)
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 12, right: 12, top: 6 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          Column() {
            Row() {
              Image($r('app.media.fa_gamepad')).width(18).height(18)
              Text(' 配对游戏设置').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#111827')
              Blank().layoutWeight(1)
            }
            .padding({ left: 16, right: 16, top: 16, bottom: 12 })

            Divider().color('#EEF2FF')

            Column() {
              Row() {
                Text('游戏卡片数量 (对)').fontSize(14).fontColor('#111827')
                Blank().layoutWeight(1)
                Text(String(this.pickCount) + ' 对')
                  .fontSize(12)
                  .fontColor('#4F46E5')
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor('#EEF2FF')
                  .borderRadius(10)
              }

              Slider({ value: this.pickCount, min: 2, max: 20, step: 1 })
                .blockColor('#4F46E5')
                .trackColor('#E5E7EB')
                .selectedColor('#4F46E5')
                .showTips(false)
                .onChange((v: number) => this.setPickCount(v))
                .margin({ top: 10 })

              Text('每次游戏中出现的单词对数。建议 6-8 对，过多屏幕会很挤。')
                .fontSize(11)
                .fontColor('#6B7280')
                .margin({ top: 10 })
            }
            .padding({ left: 16, right: 16, top: 14, bottom: 16 })

            Divider().color('#EEF2FF')

            Row() {
              Column() {
                Text('随机抽取卡片').fontSize(14).fontColor('#111827')
                Text('开启后从卡组中随机选择，关闭则按顺序选择（适合按顺序学习）。')
                  .fontSize(11)
                  .fontColor('#6B7280')
                  .margin({ top: 6 })
              }.layoutWeight(1)

              Stack({ alignContent: Alignment.Center }) {
                Row()
                  .width(56)
                  .height(32)
                  .backgroundColor(this.randomMode ? '#4F46E5' : '#E5E7EB')
                  .borderRadius(16)

                Row()
                  .width(28)
                  .height(28)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(14)
                  .shadow({ radius: 10, color: '#1118271A', offsetX: 0, offsetY: 4 })
                  .translate({ x: this.randomMode ? 12 : -12, y: 0 })
              }
              .width(56)
              .height(32)
              .onClick(() => this.toggleRandom())
            }
            .padding({ left: 16, right: 16, top: 14, bottom: 16 })
          }
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .border({ width: 1, color: '#E5E7EB' })
          .margin({ left: 16, right: 16, top: 16 })

          Column() {
            Row() {
              Image($r('app.media.fa_wand')).width(18).height(18)
              Text(' AI 辅助功能设置').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#111827')
              Blank().layoutWeight(1)
            }
            .padding({ left: 16, right: 16, top: 16, bottom: 12 })

            Divider().color('#EEF2FF')

            Column() {
              Text('大模型 API Key').fontSize(14).fontColor('#111827')

              Row() {
                TextInput({ placeholder: 'sk-...', text: this.deepseekKey })
                  .layoutWeight(1)
                  .height(44)
                  .backgroundColor('#FFFFFF')
                  .onChange((v: string) => this.setApiKey(v))

                Row() {
                  Image($r('app.media.fa_key')).width(18).height(18)
                }
                .width(44)
                .height(44)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
              }
              .padding({ left: 12, right: 6 })
              .height(48)
              .border({ width: 1, color: '#E5E7EB' })
              .borderRadius(14)
              .margin({ top: 10 })

              Text('您的 API Key 仅保存在本地设备中，用于后续的 AI 辅助功能（如自动生成卡片）。我们不会上传您的 Key。')
                .fontSize(11)
                .fontColor('#6B7280')
                .margin({ top: 10 })
            }
            .padding({ left: 16, right: 16, top: 14, bottom: 16 })
          }
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .border({ width: 1, color: '#E5E7EB' })
          .margin({ left: 16, right: 16, top: 14 })

          Text('记忆大师 v1.2.0')
            .fontSize(12)
            .fontColor('#9CA3AF')
            .textAlign(TextAlign.Center)
            .margin({ top: 22, bottom: 22 })
            .width('100%')
        }.width('100%')
      }
      .layoutWeight(1)
      .width('100%')
    }
    .backgroundColor('#F7F7F9')
    .height('100%')
    .width('100%')
  }
}
