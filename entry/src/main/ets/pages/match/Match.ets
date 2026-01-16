import type { Deck } from '../../model/types'
import { getDecks } from '../../services/storage'
import { getAppSettings } from '../../services/appSettings'

interface MatchCtx {
  deckId: number
  onBack: () => void
}

interface GameCard {
  id: string
  originalId: number
  content: string
  isFlipped: boolean
  isMatched: boolean
}

@Component
export struct MatchPage {
  @Prop ctx: MatchCtx
  @State gameCards: GameCard[] = []
  @State flippedIndices: number[] = []
  @State matchedPairs: number = 0
  @State gameTime: number = 0
  @State finalGameTime: number = 0
  @State isComplete: boolean = false
  timerId: number | undefined = undefined

  private stopTimer(): void {
    if (this.timerId === undefined) {
      return
    }
    try {
      clearInterval(this.timerId)
    } catch (_) {
    }
    this.timerId = undefined
  }

  private getGameCardFontSize(content: string): number {
    const len = content.trim().length
    if (len <= 12) {
      return 24
    }
    if (len <= 20) {
      return 20
    }
    if (len <= 30) {
      return 18
    }
    if (len <= 45) {
      return 16
    }
    if (len <= 65) {
      return 14
    }
    return 12
  }

  private getGameCardFontWeight(content: string): FontWeight {
    return content.trim().length <= 30 ? FontWeight.Bold : FontWeight.Medium
  }

  private formatDuration(seconds: number): string {
    const s = Math.max(0, Math.floor(seconds))
    const mm = Math.floor(s / 60)
    const ss = s % 60
    const ssText = ss < 10 ? '0' + String(ss) : String(ss)
    return String(mm) + ':' + ssText
  }

  aboutToAppear(): void {
    const deck: Deck | undefined = getDecks().find(d => d.id === this.ctx.deckId)
    if (!deck || deck.cards.length < 2) {
      this.gameCards = []
      return
    }
    const settings = getAppSettings()
    const pickCount = Math.min(Math.max(2, settings.matchPickCount), deck.cards.length)
    const sourceCards = deck.cards
    const selected = (() => {
      if (!settings.matchRandom) {
        return sourceCards.slice(0, pickCount)
      }
      const pool = sourceCards.slice()
      for (let i = pool.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1))
        const tmp = pool[i]
        pool[i] = pool[j]
        pool[j] = tmp
      }
      return pool.slice(0, pickCount)
    })()
    const pairs: GameCard[] = []
    for (let i = 0; i < selected.length; i++) {
      const c = selected[i]
      const front: GameCard = {
        id: 'f-' + String(c.id),
        originalId: c.id,
        content: c.front,
        isFlipped: false,
        isMatched: false
      }
      const back: GameCard = {
        id: 'b-' + String(c.id),
        originalId: c.id,
        content: c.back,
        isFlipped: false,
        isMatched: false
      }
      pairs.push(front)
      pairs.push(back)
    }
    // 简单洗牌
    for (let i = pairs.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      const temp = pairs[i]
      pairs[i] = pairs[j]
      pairs[j] = temp
    }
    this.gameCards = pairs
    this.matchedPairs = 0
    this.flippedIndices = []
    this.gameTime = 0
    this.finalGameTime = 0
    this.isComplete = false
    this.stopTimer()
    this.timerId = setInterval(() => {
      if (this.isComplete) {
        return
      }
      this.gameTime += 1
    }, 1000)
  }

  aboutToDisappear(): void {
    this.stopTimer()
  }

  onClickCard(index: number): void {
    if (this.gameCards[index].isMatched || this.gameCards[index].isFlipped) {
      return
    }
    if (this.flippedIndices.length >= 2) {
      return
    }
    const arr: GameCard[] = []
    for (let i = 0; i < this.gameCards.length; i++) {
      arr.push(this.gameCards[i])
    }
    arr[index].isFlipped = true
    this.gameCards = arr
    const nextFlipped: number[] = []
    for (let i = 0; i < this.flippedIndices.length; i++) {
      nextFlipped.push(this.flippedIndices[i])
    }
    nextFlipped.push(index)
    this.flippedIndices = nextFlipped
    if (nextFlipped.length === 2) {
      const i1 = nextFlipped[0]
      const i2 = nextFlipped[1]
      const same = arr[i1].originalId === arr[i2].originalId
      setTimeout(() => {
        const upd: GameCard[] = []
        for (let i = 0; i < this.gameCards.length; i++) {
          upd.push(this.gameCards[i])
        }
        if (same) {
          upd[i1].isMatched = true
          upd[i2].isMatched = true
          this.matchedPairs += 1
          if (this.matchedPairs === this.gameCards.length / 2) {
            this.finalGameTime = this.gameTime
            this.isComplete = true
            this.stopTimer()
          }
        } else {
          upd[i1].isFlipped = false
          upd[i2].isFlipped = false
        }
        this.gameCards = upd
        this.flippedIndices = []
      }, same ? 400 : 800)
    }
  }

  build(): void {
    if (this.gameCards.length === 0) {
      Column() {
        Text('卡组不足以开始配对游戏').fontSize(18)
        Row() {
          Row() {
            Image($r('app.media.fa_arrow_left')).width(16).height(16)
            Text(' 退出').fontSize(14).fontColor('#111827')
          }.onClick(() => this.ctx.onBack())
        }.margin({ top: 12 })
      }.padding(24)
    } else if (this.isComplete) {
      Column() {
        Column() {
          Row() {
            Image($r('app.media.fa_check')).width(32).height(32)
          }
          .width(88)
          .height(88)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .backgroundColor('#DCFCE7')
          .borderRadius(44)

          Text('本轮挑战完成')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
            .margin({ top: 18 })

          Text('完成时长：' + this.formatDuration(this.finalGameTime))
            .fontSize(12)
            .fontColor('#6B7280')
            .margin({ top: 10 })

          Button('返回首页')
            .height(44)
            .padding({ left: 22, right: 22 })
            .backgroundColor('#4F46E5')
            .fontColor('#FFFFFF')
            .borderRadius(14)
            .margin({ top: 20 })
            .onClick(() => this.ctx.onBack())
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F7F7F9')
    } else {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.fa_arrow_left')).width(16).height(16)
            Text(' 退出').fontSize(14).fontColor('#111827')
          }.onClick(() => this.ctx.onBack())

          Blank()
          Row() {
            Row() {
              Image($r('app.media.fa_clock_rotate_gray')).width(14).height(14)
              Text(' ' + String(this.gameTime) + 's').fontSize(12).fontColor('#6B7280')
            }

            Text('  进度: ').fontSize(12).fontColor('#6B7280').margin({ left: 8 })
            Text(String(this.matchedPairs) + '/' + String(Math.floor(this.gameCards.length / 2)))
              .fontSize(12)
              .fontColor('#111827')
          }
        }
        .width('100%')
        .height(48)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 12, right: 12, top: 6 })

        Grid() {
          ForEach(this.gameCards, (gc: GameCard, idx: number) => {
            GridItem() {
              Column() {
                if (gc.isMatched) {
                  Blank().height(156).width('100%')
                } else if (!gc.isFlipped) {
                  Image($r('app.media.fa_gamepad_white')).width(32).height(32)
                } else {
                  Text(gc.content)
                    .fontSize(this.getGameCardFontSize(gc.content))
                    .fontWeight(this.getGameCardFontWeight(gc.content))
                    .fontColor('#111827')
                    .textAlign(TextAlign.Center)
                    .maxLines(6)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .width('100%')
              .height(156)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .padding({ left: 12, right: 12 })
              .backgroundColor(gc.isMatched ? '#00000000' : (gc.isFlipped ? '#FFFFFF' : '#4F46E5'))
              .borderRadius(18)
              .shadow({
                radius: 16,
                color: '#1F29371A',
                offsetX: 0,
                offsetY: 8
              })
              .onClick(() => this.onClickCard(idx))
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .padding({ left: 16, right: 16, top: 8, bottom: 38 })
      }
      .backgroundColor('#F7F7F9')
      .height('100%')
    }
  }
}
