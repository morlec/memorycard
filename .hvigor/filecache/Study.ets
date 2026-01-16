import type { Deck, Card } from '../../model/types'
import { getDecks, updateDeck } from '../../services/storage'
import { calculateSM2 } from '../../utils/sm2'
import { speakText } from '../../utils/tts'

interface StudyCtx {
  deckId: number
  onBack: () => void
}

@Component
export struct StudyPage {
  @Prop ctx: StudyCtx
  @State deck: Deck | undefined = undefined
  @State studyCards: Card[] = []
  @State currentIndex: number = 0
  @State isFlipped: boolean = false
  @State isComplete: boolean = false
  @State flipAngle: number = 0
  @State isFlipping: boolean = false

  aboutToAppear(): void {
    this.deck = getDecks().find(d => d.id === this.ctx.deckId)
    if (!this.deck || this.deck.cards.length === 0) {
      this.studyCards = []
      return
    }
    const now = new Date()
    let due = this.deck.cards.filter(c => !c.nextReview || new Date(c.nextReview as string) <= now)
    if (due.length === 0) {
      const tmp: Card[] = []
      for (let i = 0; i < this.deck.cards.length && i < Math.min(10, this.deck.cards.length); i++) {
        tmp.push(this.deck.cards[i])
      }
      due = tmp
    } else {
      due.sort((a, b) => new Date(a.nextReview ?? 0).getTime() - new Date(b.nextReview ?? 0).getTime())
    }
    this.studyCards = due
    this.currentIndex = 0
    this.isFlipped = false
    this.isComplete = false
    this.flipAngle = 0
    this.isFlipping = false
  }

  toggleFlip(): void {
    if (this.isFlipping) return
    const targetAngle = this.isFlipped ? 0 : 180
    if (this.isFlipped) {
      this.isFlipped = false
    }
    this.isFlipping = true
    animateTo({ duration: 260 }, () => {
      this.flipAngle = targetAngle
    })
    setTimeout(() => {
      if (targetAngle === 180) {
        this.isFlipped = true
      }
      this.isFlipping = false
    }, 260)
  }

  rate(rating: number): void {
    if (!this.deck) {
      return
    }
    const current = this.studyCards[this.currentIndex]
    const updated = calculateSM2(current, rating)
    const newCards: Card[] = []
    for (let i = 0; i < this.deck.cards.length; i++) {
      const c = this.deck.cards[i]
      if (c.id === updated.id) {
        newCards.push(updated)
      } else {
        newCards.push(c)
      }
    }
    const newDeck: Deck = {
      id: this.deck.id,
      title: this.deck.title,
      description: this.deck.description,
      cards: newCards
    }
    updateDeck(newDeck)
    this.deck = newDeck
    this.isFlipped = false
    this.flipAngle = 0
    if (this.currentIndex + 1 < this.studyCards.length) {
      this.currentIndex += 1
    } else {
      this.isComplete = true
    }
  }

  build(): void {
    if (!this.deck || this.studyCards.length === 0) {
      Column() {
        Text('今天无需复习或卡组为空').fontSize(18)
        Row() {
          Button('返回首页').onClick(() => this.ctx.onBack())
        }.margin({ top: 12 })
      }.padding(24)
    } else if (this.isComplete) {
      Column() {
        Text('本轮复习完成').fontSize(22).fontWeight(FontWeight.Bold)
        Button('返回首页').onClick(() => this.ctx.onBack()).margin({ top: 12 })
      }.padding(24)
    } else {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.fa_xmark')).width(18).height(18)
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .onClick(() => this.ctx.onBack())

          Blank().layoutWeight(1)

          Text(String(this.currentIndex + 1) + '/' + String(this.studyCards.length))
            .fontSize(14)
            .fontColor('#6B7280')

          Blank().layoutWeight(1)

          Row().width(44).height(44)
        }
        .width('100%')
        .height(56)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 12, right: 12, top: 6 })

        Stack({ alignContent: Alignment.CenterStart }) {
          Row().width('100%').height(4).backgroundColor('#E5E7EB').borderRadius(2)
          Row()
            .width(String(Math.floor(((this.currentIndex + 1) * 100) / this.studyCards.length)) + '%')
            .height(4)
            .backgroundColor('#4F46E5')
            .borderRadius(2)
            .align(Alignment.CenterStart)
        }
        .width('100%')
        .height(4)
        .padding({ left: 24, right: 24 })

        Column() {
          Stack({ alignContent: Alignment.Center }) {
            Column() {
              Row() {
                Blank().layoutWeight(1)
                Row() {
                  Image($r('app.media.fa_volume_high')).width(18).height(18)
                }
                .width(36)
                .height(36)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
                .backgroundColor('#EEF2FF')
                .borderRadius(18)
                .onClick(() => speakText(this.studyCards[this.currentIndex].front))
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16 })

              Column() {
                Text('正面').fontSize(12).fontColor('#4F46E5').textAlign(TextAlign.Center)
                Text(this.studyCards[this.currentIndex].front)
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#111827')
                  .textAlign(TextAlign.Center)
                  .margin({ top: 10 })
              }
              .layoutWeight(1)
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .height('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(18)
            .opacity(this.flipAngle < 90 ? 1 : 0)

            Column() {
              Row() {
                Blank().layoutWeight(1)
                Row() {
                  Image($r('app.media.fa_volume_high_white')).width(18).height(18)
                }
                .width(36)
                .height(36)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
                .backgroundColor('#6366F1')
                .borderRadius(18)
                .onClick(() => speakText(this.studyCards[this.currentIndex].back))
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16 })

              Column() {
                Text('背面').fontSize(12).fontColor('#E5E7FF').textAlign(TextAlign.Center)
                Text(this.studyCards[this.currentIndex].back)
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .textAlign(TextAlign.Center)
                  .margin({ top: 10 })
              }
              .layoutWeight(1)
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .height('100%')
            .backgroundColor('#4F46E5')
            .borderRadius(18)
            .rotate({ x: 0, y: 1, z: 0, angle: 180 })
            .opacity(this.flipAngle >= 90 ? 1 : 0)
          }
          .width('100%')
          .height(260)
          .rotate({ x: 0, y: 1, z: 0, angle: this.flipAngle })
          .shadow({ radius: 18, color: '#1F29371A', offsetX: 0, offsetY: 10 })
          .onClick(() => this.toggleFlip())

          if (!this.isFlipped) {
            Text('点击卡片翻看背面')
              .fontSize(12)
              .fontColor('#9CA3AF')
              .textAlign(TextAlign.Center)
              .margin({ top: 14 })

            Button('显示答案')
              .width('100%')
              .height(52)
              .backgroundColor('#4F46E5')
              .fontColor('#FFFFFF')
              .borderRadius(16)
              .margin({ top: 16 })
              .shadow({ radius: 18, color: '#4F46E540', offsetX: 0, offsetY: 12 })
              .onClick(() => this.toggleFlip())
          } else {
            Text('您觉得这张卡片难度如何？')
              .fontSize(12)
              .fontColor('#9CA3AF')
              .textAlign(TextAlign.Center)
              .margin({ top: 14 })

            Row() {
              Button() {
                Column() {
                  Text('重来').fontSize(14).fontColor('#DC2626')
                  Text('1分钟').fontSize(10).fontColor('#DC2626').margin({ top: 2 })
                }.alignItems(HorizontalAlign.Center)
              }
              .layoutWeight(1)
              .height(52)
              .backgroundColor('#FEE2E2')
              .borderRadius(14)
              .onClick(() => this.rate(0))

              Button() {
                Column() {
                  Text('困难').fontSize(14).fontColor('#EA580C')
                  Text('2天').fontSize(10).fontColor('#EA580C').margin({ top: 2 })
                }.alignItems(HorizontalAlign.Center)
              }
              .layoutWeight(1)
              .height(52)
              .backgroundColor('#FFEDD5')
              .borderRadius(14)
              .margin({ left: 10 })
              .onClick(() => this.rate(3))

              Button() {
                Column() {
                  Text('良好').fontSize(14).fontColor('#2563EB')
                  Text('4天').fontSize(10).fontColor('#2563EB').margin({ top: 2 })
                }.alignItems(HorizontalAlign.Center)
              }
              .layoutWeight(1)
              .height(52)
              .backgroundColor('#DBEAFE')
              .borderRadius(14)
              .margin({ left: 10 })
              .onClick(() => this.rate(4))

              Button() {
                Column() {
                  Text('容易').fontSize(14).fontColor('#059669')
                  Text('7天').fontSize(10).fontColor('#059669').margin({ top: 2 })
                }.alignItems(HorizontalAlign.Center)
              }
              .layoutWeight(1)
              .height(52)
              .backgroundColor('#D1FAE5')
              .borderRadius(14)
              .margin({ left: 10 })
              .onClick(() => this.rate(5))
            }
            .margin({ top: 16 })
          }
        }
        .padding({ left: 20, right: 20, top: 18 })
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#F7F7F9')
    }
  }
}
