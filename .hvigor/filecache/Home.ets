import type { Deck } from '../../model/types'

interface HomeHandlers {
  onStartStudy: (id: number) => void
  onStartMatch: (id: number) => void
  onOpenEditor: (id: number) => void
  onDeleteDeck: (id: number) => void
  onOpenSettings: () => void
  onRefresh: () => void
}

@Component
export struct HomePage {
  @Prop decks: Deck[]
  @Prop handlers: HomeHandlers

  private getDueCount(deck: Deck): number {
    return deck.cards.filter(c => !c.nextReview || new Date(c.nextReview as string) <= new Date()).length
  }

  build(): void {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          Text('记忆大师')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
          Blank().layoutWeight(1)
          Row() {
            Image($r('app.media.fa_gear')).width(18).height(18)
          }
          .width(44)
          .height(36)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .backgroundColor('#F3F4F6')
          .borderRadius(18)
          .border({ width: 1, color: '#E5E7EB' })
          .onClick(() => this.handlers.onOpenSettings())
        }
        .width('100%')
        .height(52)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')

        Scroll() {
          Column() {
            if (this.decks.length === 0) {
              Column() {
                Text('您还没有需要记忆的卡片')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#111827')
                Text('点击添加按钮添加一个吧')
                  .fontSize(12)
                  .fontColor('#6B7280')
                  .margin({ top: 10 })
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .padding({ left: 24, right: 24 })
            } else {
              ForEach(this.decks, (deck: Deck) => {
                const dueCount = deck.cards.filter(c => !c.nextReview || new Date(c.nextReview as string) <= new Date()).length
                Column() {
                  Column() {
                    Row() {
                      Row() {
                        Image($r('app.media.fa_bars')).width(18).height(18)
                      }
                      .width(40)
                      .height(40)
                      .justifyContent(FlexAlign.Center)
                      .alignItems(VerticalAlign.Center)
                      .backgroundColor('#EEF2FF')
                      .borderRadius(12)

                      Blank().layoutWeight(1)

                      Row() {
                        Row() {
                          Image($r('app.media.fa_pen')).width(18).height(18)
                        }
                        .width(36)
                        .height(36)
                        .justifyContent(FlexAlign.Center)
                        .alignItems(VerticalAlign.Center)
                        .onClick(() => this.handlers.onOpenEditor(deck.id))

                        Row() {
                          Image($r('app.media.fa_trash')).width(18).height(18)
                        }
                        .width(36)
                        .height(36)
                        .justifyContent(FlexAlign.Center)
                        .alignItems(VerticalAlign.Center)
                        .margin({ left: 4 })
                        .onClick(() => this.handlers.onDeleteDeck(deck.id))
                      }
                    }
                    .width('100%')
                    .padding({ left: 16, right: 12, top: 12 })

                    Column() {
                      Text(deck.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#111827')
                      Text(deck.description ?? '日常生活中常用的英语词汇')
                        .fontSize(12)
                        .fontColor('#6B7280')
                        .margin({ top: 6 })

                      Row() {
                        Image($r('app.media.fa_clock_red')).width(12).height(12)
                        Text(' 待复习: ' + String(dueCount)).fontSize(11).fontColor('#EF4444')
                      }
                      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                      .backgroundColor('#FEE2E2')
                      .borderRadius(14)
                      .margin({ top: 12 })
                    }
                    .padding({ left: 16, right: 16, top: 12, bottom: 14 })
                  }

                  Divider().color('#F3F4F6').margin({ left: 16, right: 16 })

                  Row() {
                    Row() {
                      Image($r('app.media.fa_book_open')).width(16).height(16)
                      Text('智能复习').fontSize(14).fontColor('#4F46E5').margin({ left: 6 })
                    }
                    .layoutWeight(1)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(VerticalAlign.Center)
                    .onClick(() => this.handlers.onStartStudy(deck.id))

                    Divider().vertical(true).height(18).color('#E5E7EB')
                    Row() {
                      Image($r('app.media.fa_gamepad_green')).width(16).height(16)
                      Text('游戏挑战').fontSize(14).fontColor('#10B981').margin({ left: 6 })
                    }
                    .layoutWeight(1)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(VerticalAlign.Center)
                    .onClick(() => this.handlers.onStartMatch(deck.id))
                  }
                  .height(48)
                  .padding({ left: 16, right: 16 })
                  .backgroundColor('#FFFFFF')
                }
                .borderRadius(16)
                .backgroundColor('#FFFFFF')
                .margin({ left: 20, right: 20, top: 14 })
                .shadow({
                  radius: 16,
                  color: '#1F29371A',
                  offsetX: 0,
                  offsetY: 8
                })
              })
              Blank().height(20)
            }
          }.width('100%')
        }
        .layoutWeight(1)
        .backgroundColor('#F7F7F9')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F7F7F9')
      .align(Alignment.TopStart)

      Stack() {
        Image($r('app.media.fa_plus_white')).width(20).height(20)
      }
      .width(56)
      .height(56)
      .borderRadius(28)
      .backgroundColor('#4F46E5')
      .alignContent(Alignment.Center)
      .onClick(() => this.handlers.onOpenEditor(-1))
      .margin({ right: 20, bottom: 20 })
    }.height('100%').width('100%')
  }
}
