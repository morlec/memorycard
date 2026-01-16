import { getAppSettings, updateAppSettings } from '../../services/appSettings'
import { APP_NAME, APP_VERSION } from '../../services/appInfo'

interface BasicSettingsCtx {
  onBack: () => void
}

type AiProvider = 'deepseek' | 'openai' | 'gemini'

@Component
export struct BasicSettingsPage {
  @Prop ctx: BasicSettingsCtx
  @State pickCount: number = 6
  @State randomMode: boolean = true
  @State aiProvider: string = 'deepseek'
  @State deepseekKey: string = ''
  @State deepseekBaseUrl: string = ''
  @State deepseekModel: string = ''
  @State openaiKey: string = ''
  @State openaiBaseUrl: string = ''
  @State openaiModel: string = ''
  @State geminiKey: string = ''
  @State geminiBaseUrl: string = ''
  @State geminiModel: string = ''
  @State showAiAdvanced: boolean = false

  aboutToAppear(): void {
    const settings = getAppSettings()
    this.pickCount = settings.matchPickCount
    this.randomMode = settings.matchRandom
    this.aiProvider = settings.aiProvider
    this.deepseekKey = settings.deepseekApiKey
    this.deepseekBaseUrl = settings.deepseekBaseUrl
    this.deepseekModel = settings.deepseekModel
    this.openaiKey = settings.openaiApiKey ?? ''
    this.openaiBaseUrl = settings.openaiBaseUrl ?? ''
    this.openaiModel = settings.openaiModel ?? ''
    this.geminiKey = settings.geminiApiKey ?? ''
    this.geminiBaseUrl = settings.geminiBaseUrl ?? ''
    this.geminiModel = settings.geminiModel ?? ''
  }

  private setPickCount(v: number): void {
    const n = Math.max(2, Math.min(20, Math.floor(v)))
    if (n === this.pickCount) {
      return
    }
    this.pickCount = n
    updateAppSettings({ matchPickCount: this.pickCount })
  }

  private toggleRandom(): void {
    this.randomMode = !this.randomMode
    updateAppSettings({ matchRandom: this.randomMode })
  }

  private getProviderLabel(provider: string): string {
    if (provider === 'openai') return 'GPT'
    if (provider === 'gemini') return 'Gemini'
    return 'DeepSeek'
  }

  private getCurrentApiKey(): string {
    if (this.aiProvider === 'openai') return this.openaiKey
    if (this.aiProvider === 'gemini') return this.geminiKey
    return this.deepseekKey
  }

  private getCurrentBaseUrl(): string {
    if (this.aiProvider === 'openai') return this.openaiBaseUrl
    if (this.aiProvider === 'gemini') return this.geminiBaseUrl
    return this.deepseekBaseUrl
  }

  private getCurrentModel(): string {
    if (this.aiProvider === 'openai') return this.openaiModel
    if (this.aiProvider === 'gemini') return this.geminiModel
    return this.deepseekModel
  }

  private getKeyPlaceholder(): string {
    if (this.aiProvider === 'gemini') return 'AIza...'
    return 'sk-...'
  }

  private setProvider(provider: AiProvider): void {
    this.aiProvider = provider
    updateAppSettings({ aiProvider: provider })
    if (provider === 'openai') {
      if (!this.openaiBaseUrl) this.openaiBaseUrl = 'https://api.openai.com/v1'
      if (!this.openaiModel) this.openaiModel = 'gpt-4o-mini'
      updateAppSettings({ openaiBaseUrl: this.openaiBaseUrl, openaiModel: this.openaiModel })
    } else if (provider === 'gemini') {
      if (!this.geminiBaseUrl) this.geminiBaseUrl = 'https://generativelanguage.googleapis.com'
      if (!this.geminiModel) this.geminiModel = 'gemini-1.5-flash'
      updateAppSettings({ geminiBaseUrl: this.geminiBaseUrl, geminiModel: this.geminiModel })
    } else {
      if (!this.deepseekBaseUrl) this.deepseekBaseUrl = 'https://api.deepseek.com'
      if (!this.deepseekModel) this.deepseekModel = 'deepseek-chat'
      updateAppSettings({ deepseekBaseUrl: this.deepseekBaseUrl, deepseekModel: this.deepseekModel })
    }
  }

  private setApiKey(v: string): void {
    if (this.aiProvider === 'openai') {
      this.openaiKey = v
      updateAppSettings({ openaiApiKey: this.openaiKey })
      return
    }
    if (this.aiProvider === 'gemini') {
      this.geminiKey = v
      updateAppSettings({ geminiApiKey: this.geminiKey })
      return
    }
    this.deepseekKey = v
    updateAppSettings({ deepseekApiKey: this.deepseekKey })
  }

  private setBaseUrl(v: string): void {
    if (this.aiProvider === 'openai') {
      this.openaiBaseUrl = v
      updateAppSettings({ openaiBaseUrl: this.openaiBaseUrl })
      return
    }
    if (this.aiProvider === 'gemini') {
      this.geminiBaseUrl = v
      updateAppSettings({ geminiBaseUrl: this.geminiBaseUrl })
      return
    }
    this.deepseekBaseUrl = v
    updateAppSettings({ deepseekBaseUrl: this.deepseekBaseUrl })
  }

  private setModel(v: string): void {
    if (this.aiProvider === 'openai') {
      this.openaiModel = v
      updateAppSettings({ openaiModel: this.openaiModel })
      return
    }
    if (this.aiProvider === 'gemini') {
      this.geminiModel = v
      updateAppSettings({ geminiModel: this.geminiModel })
      return
    }
    this.deepseekModel = v
    updateAppSettings({ deepseekModel: this.deepseekModel })
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
            .padding({
              left: 16,
              right: 16,
              top: 16,
              bottom: 12
            })

            Divider().color('#EEF2FF')

            Column() {
              Row() {
                Text('游戏卡片数量 (对)').fontSize(14).fontColor('#111827')
                Blank().layoutWeight(1)
                Text(String(this.pickCount) + ' 对')
                  .fontSize(12)
                  .fontColor('#4F46E5')
                  .padding({
                    left: 10,
                    right: 10,
                    top: 6,
                    bottom: 6
                  })
                  .backgroundColor('#EEF2FF')
                  .borderRadius(10)
              }

              Slider({
                value: this.pickCount,
                min: 2,
                max: 20,
                step: 1
              })
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
            .padding({
              left: 16,
              right: 16,
              top: 14,
              bottom: 16
            })

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
                  .shadow({
                    radius: 10,
                    color: '#1118271A',
                    offsetX: 0,
                    offsetY: 4
                  })
                  .translate({ x: this.randomMode ? 12 : -12, y: 0 })
              }
              .width(56)
              .height(32)
              .onClick(() => this.toggleRandom())
            }
            .padding({
              left: 16,
              right: 16,
              top: 14,
              bottom: 16
            })
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
            .padding({
              left: 16,
              right: 16,
              top: 16,
              bottom: 12
            })

            Divider().color('#EEF2FF')

            Column() {
              Row() {
                Text('服务商').fontSize(14).fontColor('#111827')
                Blank().layoutWeight(1)
                Row() {
                  Text('DeepSeek')
                    .fontSize(12)
                    .fontColor(this.aiProvider === 'deepseek' ? '#FFFFFF' : '#4F46E5')
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.aiProvider === 'deepseek' ? '#4F46E5' : '#EEF2FF')
                    .borderRadius(10)
                    .onClick(() => this.setProvider('deepseek'))

                  Text(' GPT')
                    .fontSize(12)
                    .fontColor(this.aiProvider === 'openai' ? '#FFFFFF' : '#4F46E5')
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.aiProvider === 'openai' ? '#4F46E5' : '#EEF2FF')
                    .borderRadius(10)
                    .margin({ left: 8 })
                    .onClick(() => this.setProvider('openai'))

                  Text(' Gemini')
                    .fontSize(12)
                    .fontColor(this.aiProvider === 'gemini' ? '#FFFFFF' : '#4F46E5')
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.aiProvider === 'gemini' ? '#4F46E5' : '#EEF2FF')
                    .borderRadius(10)
                    .margin({ left: 8 })
                    .onClick(() => this.setProvider('gemini'))
                }
              }
              Divider().color('#EEF2FF').margin({ top: 14 })

              Text('大模型 API Key').fontSize(14).fontColor('#111827')

              Row() {
                TextInput({ placeholder: this.getKeyPlaceholder(), text: this.getCurrentApiKey() })
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

              Row() {
                Text('高级设置（可选）').fontSize(12).fontColor('#6B7280')
                Blank().layoutWeight(1)
                Text(this.showAiAdvanced ? '收起' : '展开').fontSize(12).fontColor('#4F46E5')
              }
              .margin({ top: 14 })
              .onClick(() => this.showAiAdvanced = !this.showAiAdvanced)

              if (this.showAiAdvanced) {
                Column() {
                  Text('Base URL').fontSize(12).fontColor('#6B7280')
                  TextInput({ placeholder: this.aiProvider === 'openai' ? 'https://api.openai.com/v1' :
                    (this.aiProvider === 'gemini' ? 'https://generativelanguage.googleapis.com' :
                    'https://api.deepseek.com'), text: this.getCurrentBaseUrl() })
                    .height(44)
                    .backgroundColor('#FFFFFF')
                    .onChange((v: string) => this.setBaseUrl(v))
                    .margin({ top: 10 })
                    .border({ width: 1, color: '#E5E7EB' })
                    .borderRadius(14)

                  Text('Model').fontSize(12).fontColor('#6B7280').margin({ top: 12 })
                  TextInput({ placeholder: this.aiProvider === 'openai' ? 'gpt-4o-mini' :
                    (this.aiProvider === 'gemini' ? 'gemini-1.5-flash' : 'deepseek-chat'), text: this.getCurrentModel() })
                    .height(44)
                    .backgroundColor('#FFFFFF')
                    .onChange((v: string) => this.setModel(v))
                    .margin({ top: 10 })
                    .border({ width: 1, color: '#E5E7EB' })
                    .borderRadius(14)
                }
                .margin({ top: 12 })
              }
            }
            .padding({
              left: 16,
              right: 16,
              top: 14,
              bottom: 16
            })
          }
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .border({ width: 1, color: '#E5E7EB' })
          .margin({ left: 16, right: 16, top: 14 })

          Text(APP_NAME + ' ' + APP_VERSION)
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
