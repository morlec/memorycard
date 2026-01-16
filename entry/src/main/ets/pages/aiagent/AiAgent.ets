import type { Deck } from '../../model/types'
import { addDeck, getDecks, importCSVToDeck } from '../../services/storage'
import { getAppSettings } from '../../services/appSettings'
import { aiGenerateCSV, getAiApiKey, getAiProviderLabel } from '../../services/aiGenerate'
import promptAction from '@ohos.promptAction'

interface AiAgentCtx {
  onBack: () => void
}

@Component
export struct AiAgentPage {
  @Prop ctx?: AiAgentCtx
  @State topic: string = ''
  @State countText: string = '12'
  @State deckName: string = ''
  @State selectedDeckId: number = -1
  @State isGenerating: boolean = false

  private toast(message: string): void {
    try {
      promptAction.showToast({ message })
    } catch (_) {
    }
  }

  aboutToAppear(): void {
    const decks = getDecks()
    if (decks.length > 0 && this.selectedDeckId === -1) {
      this.selectedDeckId = decks[0].id
    }
  }

  private parseCount(): number {
    const n = Math.floor(Number(this.countText))
    if (!Number.isFinite(n)) return 12
    if (n < 2) return 2
    if (n > 50) return 50
    return n
  }

  private getTargetDeckId(): number {
    const name = this.deckName.trim()
    if (name) {
      const id = Date.now()
      addDeck({ id, title: name, description: 'AI 生成', cards: [] })
      this.deckName = ''
      this.selectedDeckId = id
      return id
    }
    return this.selectedDeckId
  }

  async generate(): Promise<void> {
    if (this.isGenerating) return
    const topic = this.topic.trim()
    if (!topic) {
      this.toast('请输入主题或内容')
      return
    }
    const settings = getAppSettings()
    if (!getAiApiKey()) {
      this.toast('请先在设置中填写 ' + getAiProviderLabel(settings.aiProvider) + ' API Key')
      return
    }
    const deckId = this.getTargetDeckId()
    if (deckId === -1) {
      this.toast('请先创建一个卡组')
      return
    }

    this.isGenerating = true
    try {
      const csv = await aiGenerateCSV(topic, this.parseCount())
      if (!csv.trim()) {
        this.toast('生成失败：返回内容为空')
        return
      }
      const before = getDecks().find(d => d.id === deckId)?.cards.length ?? 0
      importCSVToDeck(deckId, csv)
      const after = getDecks().find(d => d.id === deckId)?.cards.length ?? before
      this.toast('已生成并导入 ' + String(Math.max(0, after - before)) + ' 条')
      this.topic = ''
    } catch (_) {
      this.toast('生成失败，请检查网络与Key')
    } finally {
      this.isGenerating = false
    }
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
        .onClick(() => {
          if (this.ctx) {
            this.ctx.onBack()
          }
        })

        Row() {
          Image($r('app.media.fa_wand')).width(18).height(18)
          Text(' AI 智能制卡').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#111827')
        }
        .layoutWeight(1)
        .padding({ left: 4 })
        .alignItems(VerticalAlign.Center)

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
              Column() {
                Text('生成主题').fontSize(12).fontColor('#6B7280')
                TextInput({ placeholder: '例如：雅思核心词汇，法语日常对话...', text: this.topic })
                  .height(44)
                  .border({ width: 1, color: '#E5E7EB' })
                  .borderRadius(12)
                  .padding({ left: 12, right: 12 })
                  .margin({ top: 10 })
                  .onChange((v: string) => this.topic = v)
              }.layoutWeight(1)

              Column() {
                Text('生成数量').fontSize(12).fontColor('#6B7280')
                TextInput({ placeholder: '10', text: this.countText })
                  .height(44)
                  .border({ width: 1, color: '#E5E7EB' })
                  .borderRadius(12)
                  .padding({ left: 12, right: 12 })
                  .margin({ top: 10 })
                  .onChange((v: string) => this.countText = v)
              }
              .width(160)
              .margin({ left: 12 })
            }

            Row() {
              Blank().layoutWeight(1)
              Button() {
                Row() {
                  Image($r('app.media.fa_wand_white')).width(14).height(14)
                  Text(this.isGenerating ? ' 生成中...' : ' 开始生成')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                }.alignItems(VerticalAlign.Center)
              }
              .height(44)
              .padding({ left: 18, right: 18 })
              .backgroundColor(this.isGenerating ? '#9CA3AF' : '#A5B4FC')
              .borderRadius(14)
              .onClick(() => this.generate())
            }.margin({ top: 16 })
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .border({ width: 1, color: '#E5E7EB' })
          .margin({ left: 16, right: 16, top: 16 })
          .shadow({ radius: 16, color: '#1F29370F', offsetX: 0, offsetY: 8 })

          Column() {
            Row() {
              Text('导入设置').fontSize(14).fontColor('#111827').fontWeight(FontWeight.Medium)
              Blank().layoutWeight(1)
              Text('当前模型：' + getAiProviderLabel(getAppSettings().aiProvider))
                .fontSize(12)
                .fontColor('#6B7280')
            }.padding({ left: 16, right: 16, top: 16, bottom: 12 })

            Divider().color('#EEF2FF')

            Column() {
              Text('导入到新卡组（可选）').fontSize(12).fontColor('#6B7280')
              TextInput({ placeholder: '填写则自动创建并导入', text: this.deckName })
                .height(44)
                .border({ width: 1, color: '#E5E7EB' })
                .borderRadius(12)
                .padding({ left: 12, right: 12 })
                .margin({ top: 10 })
                .onChange((v: string) => this.deckName = v)
            }
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })

            Divider().color('#EEF2FF')

            if (this.deckName.trim() === '' && getDecks().length > 0) {
              Column() {
                Text('选择导入卡组').fontSize(12).fontColor('#6B7280')
                ForEach(getDecks(), (d: Deck) => {
                  Row() {
                    Text(d.title).fontSize(14).fontColor('#111827')
                    Blank().layoutWeight(1)
                    if (this.selectedDeckId === d.id) {
                      Text('已选')
                        .fontSize(12)
                        .fontColor('#4F46E5')
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .backgroundColor('#EEF2FF')
                        .borderRadius(10)
                    }
                  }
                  .padding({ left: 14, right: 14, top: 12, bottom: 12 })
                  .border({ width: 1, color: this.selectedDeckId === d.id ? '#C7D2FE' : '#E5E7EB' })
                  .backgroundColor(this.selectedDeckId === d.id ? '#EEF2FF' : '#FFFFFF')
                  .borderRadius(14)
                  .margin({ top: 10 })
                  .onClick(() => this.selectedDeckId = d.id)
                })
                Blank().height(4)
              }
              .padding({ left: 16, right: 16, top: 14, bottom: 16 })
            }

            if (this.deckName.trim() === '' && getDecks().length === 0) {
              Column() {
                Text('还没有卡组').fontSize(12).fontColor('#6B7280')
                Text('请先在首页创建一个卡组，或在上方输入新卡组名称。')
                  .fontSize(11)
                  .fontColor('#9CA3AF')
                  .margin({ top: 6 })
              }
              .padding({ left: 16, right: 16, top: 14, bottom: 16 })
            }
          }
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .border({ width: 1, color: '#E5E7EB' })
          .margin({ left: 16, right: 16, top: 14 })
          .shadow({ radius: 16, color: '#1F29370F', offsetX: 0, offsetY: 8 })

          Text('提示：请先在“应用设置- AI 辅助功能设置”里配置 API Key')
            .fontSize(11)
            .fontColor('#9CA3AF')
            .textAlign(TextAlign.Center)
            .margin({ top: 18, bottom: 26 })
            .width('100%')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F7F7F9')
    }
    .backgroundColor('#F7F7F9')
    .height('100%')
    .width('100%')
  }
}

