import type { Deck } from '../../model/types'
import { getAppSettings } from '../../services/appSettings'
import { APP_NAME } from '../../services/appInfo'

interface HomeHandlers {
  onStartStudy: (id: number) => void
  onStartMatch: (id: number) => void
  onOpenEditor: (id: number) => void
  onDeleteDeck: (id: number) => void
  onCreateDeck: (title: string, description: string) => void
  onOpenSettings: () => void
  onRefresh: () => void
}

@Component
export struct HomePage {
  @Prop decks: Deck[]
  @Prop handlers: HomeHandlers
  @State showCreateDeckDialog: boolean = false
  @State createDeckTitle: string = ''
  @State createDeckDescription: string = ''
  @State expandedDeckId: number = -1
  @State nickname: string = '学习者'
  @State avatarIndex: number = 0
  @State quote: string = ''
  @State reviewedToday: number = 0

  private getDueCount(deck: Deck): number {
    return deck.cards.filter(c => !c.nextReview || new Date(c.nextReview as string) <= new Date()).length
  }

  private getTotalDue(): number {
    let total = 0
    for (let i = 0; i < this.decks.length; i++) {
      total += this.getDueCount(this.decks[i])
    }
    return total
  }

  private getTodayReviewTotal(): number {
    return this.reviewedToday + this.getTotalDue()
  }

  private getTodayReviewPercent(): number {
    const total = this.getTodayReviewTotal()
    if (total <= 0) {
      return 1
    }
    return this.reviewedToday / total
  }

  private getAvatarColor(): string {
    const colors: string[] = ['#4F46E5', '#06B6D4', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#111827']
    const idx = Math.max(0, Math.min(colors.length - 1, this.avatarIndex % colors.length))
    return colors[idx]
  }

  private getAvatarText(): string {
    const t = this.nickname.trim()
    if (!t) {
      return '我'
    }
    return t.slice(0, 1)
  }

  private pickQuote(nickname: string): string {
    const quotes: string[] = [
      '每天进步一点点，终会很惊艳。',
      '记住的不是单词，是你坚持的习惯。',
      '把今天的卡片清空，明天会更轻松。',
      '学会一个词，就多了一种表达世界的方式。',
      '慢慢来，但不要停。',
      '你比昨天更强一点。'
    ]
    const now = new Date()
    const dayKey = Number(String(now.getFullYear()) + String(now.getMonth() + 1).padStart(2, '0') + String(now.getDate()).padStart(2, '0'))
    let sum = dayKey
    for (let i = 0; i < nickname.length; i++) {
      sum += nickname.charCodeAt(i) * (i + 1)
    }
    const idx = Math.abs(sum) % quotes.length
    return quotes[idx]
  }

  aboutToAppear(): void {
    const s = getAppSettings()
    this.nickname = s.profileNickname
    this.avatarIndex = s.profileAvatarIndex
    this.reviewedToday = s.dailyReviewCount
    this.quote = this.pickQuote(this.nickname)
    if (this.expandedDeckId === -1 && this.decks.length > 0) {
      this.expandedDeckId = this.decks[0].id
    }
  }

  build(): void {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          Text(APP_NAME)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
          Blank().layoutWeight(1)
          Row() {
            Stack({ alignContent: Alignment.Center }) {
              Row()
                .width(36)
                .height(36)
                .backgroundColor('#F3F4F6')
                .borderRadius(18)
                .border({ width: 1, color: '#E5E7EB' })
              Image($r('app.media.fa_gear')).width(18).height(18)
            }
            .width(36)
            .height(36)
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
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
            Column() {
              Row() {
                Stack({ alignContent: Alignment.Center }) {
                  Row()
                    .width(52)
                    .height(52)
                    .backgroundColor(this.getAvatarColor())
                    .borderRadius(26)
                  Text(this.getAvatarText())
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                }
                .width(52)
                .height(52)

                Column() {
                  Text('欢迎 ' + this.nickname).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#111827')
                  Text(this.quote).fontSize(12).fontColor('#6B7280').margin({ top: 6 })
                }
                .margin({ left: 12 })
                .layoutWeight(1)
              }
              .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            }
            .backgroundColor('#FFFFFF')
            .borderRadius(18)
            .border({ width: 1, color: '#E5E7EB' })
            .margin({ left: 16, right: 16, top: 16 })
            .shadow({ radius: 16, color: '#1F29370F', offsetX: 0, offsetY: 8 })

            Column() {
              Row() {
                Text('本日待复习').fontSize(12).fontColor('#6B7280')
                Blank().layoutWeight(1)
                Text(String(this.reviewedToday) + '/' + String(this.getTodayReviewTotal()))
                  .fontSize(12)
                  .fontColor('#111827')
              }
              .padding({ left: 16, right: 16, top: 14, bottom: 10 })

              Stack({ alignContent: Alignment.Start }) {
                Row().width('100%').height(6).backgroundColor('#E5E7EB').borderRadius(3)
                Row()
                  .width(String(Math.floor(this.getTodayReviewPercent() * 100)) + '%')
                  .height(6)
                  .backgroundColor('#4F46E5')
                  .borderRadius(3)
                  .align(Alignment.Start)
              }
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 14 })
            }
            .backgroundColor('#FFFFFF')
            .borderRadius(18)
            .border({ width: 1, color: '#E5E7EB' })
            .margin({ left: 16, right: 16, top: 14 })
            .shadow({ radius: 16, color: '#1F29370F', offsetX: 0, offsetY: 8 })

            Row() {
              Text('记忆卡片')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#111827')
              Blank().layoutWeight(1)
            }
            .padding({ left: 16, right: 16, top: 18, bottom: 6 })

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
                if (this.expandedDeckId === deck.id) {
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
                      .onClick(() => this.expandedDeckId = deck.id)

                      Column() {
                        Text(deck.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#111827')
                        Text(deck.description ?? '日常生活中常用的英语词汇')
                          .fontSize(12)
                          .fontColor('#6B7280')
                          .margin({ top: 6 })
                        Row() {
                          Image($r('app.media.fa_clock_red')).width(12).height(12)
                          Text(' 待复习: ' + String(this.getDueCount(deck))).fontSize(11).fontColor('#EF4444')
                        }
                        .padding({
                          left: 10,
                          right: 10,
                          top: 5,
                          bottom: 5
                        })
                        .backgroundColor('#FEE2E2')
                        .borderRadius(14)
                        .margin({ top: 12 })
                      }
                      .padding({
                        left: 16,
                        right: 16,
                        top: 12,
                        bottom: 14
                      })
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
                  .margin({ left: 16, right: 16, top: 14 })
                  .shadow({
                    radius: 16,
                    color: '#1F29371A',
                    offsetX: 0,
                    offsetY: 8
                  })
                } else {
                  Row() {
                    Text(deck.title)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#111827')
                    Blank().layoutWeight(1)
                    Row() {
                      Image($r('app.media.fa_clock_red')).width(12).height(12)
                      Text(' ' + String(this.getDueCount(deck)))
                        .fontSize(11)
                        .fontColor('#EF4444')
                    }
                    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                    .backgroundColor('#FEE2E2')
                    .borderRadius(14)
                  }
                  .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                  .backgroundColor('#FFFFFF')
                  .borderRadius(16)
                  .border({ width: 1, color: '#E5E7EB' })
                  .margin({ left: 16, right: 16, top: 12 })
                  .onClick(() => this.expandedDeckId = deck.id)
                }
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
      .onClick(() => {
        this.createDeckTitle = ''
        this.createDeckDescription = ''
        this.showCreateDeckDialog = true
      })
      .margin({ right: 20, bottom: 20 })

      if (this.showCreateDeckDialog) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#00000066')
            .onClick(() => this.showCreateDeckDialog = false)

          Column() {
            Text('创建新卡组')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111827')

            TextInput({ placeholder: '标题', text: this.createDeckTitle })
              .onChange((v: string) => this.createDeckTitle = v)
              .margin({ top: 16 })

            TextArea({ placeholder: '描述', text: this.createDeckDescription })
              .height(120)
              .onChange((v: string) => this.createDeckDescription = v)
              .margin({ top: 12 })

            Row() {
              Blank().layoutWeight(1)

              Text('取消')
                .fontSize(16)
                .fontColor('#111827')
                .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                .onClick(() => this.showCreateDeckDialog = false)

              Button('创建')
                .height(40)
                .padding({ left: 18, right: 18 })
                .backgroundColor('#4F46E5')
                .fontColor('#FFFFFF')
                .borderRadius(12)
                .margin({ left: 10 })
                .onClick(() => {
                  const title = this.createDeckTitle.trim()
                  if (!title) return
                  this.handlers.onCreateDeck(title, this.createDeckDescription.trim())
                  this.showCreateDeckDialog = false
                })
            }
            .margin({ top: 14 })
          }
          .width('92%')
          .padding({ left: 18, right: 18, top: 20, bottom: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .onClick(() => {})
          .align(Alignment.Center)
        }
        .width('100%')
        .height('100%')
      }
    }.height('100%').width('100%')
  }
}
