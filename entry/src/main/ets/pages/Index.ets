import type { Deck } from '../model/types'
import { initStorage, getDecks, deleteDeck, addDeck } from '../services/storage'
import { initAppSettings } from '../services/appSettings'
import { HomePage } from './home/Home'
import { EditPage } from './edit/Edit'
import { StudyPage } from './study/Study'
import { MatchPage } from './match/Match'
import { AiAgentPage } from './aiagent/AiAgent'
import { SettingsPage } from './settings/Settings'
import { BasicSettingsPage } from './settings/BasicSettings'

@Entry
@Component
struct Index {
  @State currentView: string = 'home'
  @State activeDeckId: number = -1
  @State decks: Deck[] = []
  @State showDeleteDeckConfirm: boolean = false
  @State pendingDeleteDeckId: number = -1

  aboutToAppear(): void {
    const demo: Deck[] = [
      {
        id: 1,
        title: '基础英语单词',
        description: '日常生活常用词汇',
        cards: [
          {
            id: 1,
            front: 'Apple',
            back: '苹果',
            nextReview: new Date().toISOString()
          },
          {
            id: 2,
            front: 'Water',
            back: '水',
            nextReview: new Date().toISOString()
          }
        ]
      }
    ]
    this.decks = initStorage(demo, getContext(this))
    initAppSettings(getContext(this))
  }

  setView(view: string, deckId: number = -1): void {
    this.currentView = view
    this.activeDeckId = deckId
    this.decks = getDecks()
  }

  private requestDeleteDeck(id: number): void {
    this.pendingDeleteDeckId = id
    this.showDeleteDeckConfirm = true
  }

  private confirmDeleteDeck(): void {
    const id = this.pendingDeleteDeckId
    this.pendingDeleteDeckId = -1
    this.showDeleteDeckConfirm = false
    if (id === -1) {
      return
    }
    deleteDeck(id)
    this.setView('home')
  }

  build(): void {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Column() {
          if (this.currentView === 'home') {
            HomePage({
              decks: this.decks,
              handlers: {
                onStartStudy: (id: number): void => this.setView('study', id),
                onStartMatch: (id: number): void => this.setView('match', id),
                onOpenEditor: (id: number): void => this.setView('edit', id),
                onCreateDeck: (title: string, description: string): void => {
                  addDeck({
                    id: Date.now(),
                    title,
                    description,
                    cards: []
                  })
                  this.setView('home')
                },
                onDeleteDeck: (id: number): void => this.requestDeleteDeck(id),
                onOpenSettings: (): void => this.setView('settings_basic'),
                onRefresh: (): void => this.setView('home')
              }
            })
              .width('100%')
              .height('100%')
          } else if (this.currentView === 'aiagent') {
            AiAgentPage({
              ctx: {
                onBack: (): void => this.setView('home')
              }
            }).width('100%').height('100%')
          } else if (this.currentView === 'profile') {
            SettingsPage({
              ctx: {
                onBack: (): void => this.setView('home'),
                onOpenPreferences: (): void => this.setView('settings_basic')
              }
            }).width('100%').height('100%')
          } else if (this.currentView === 'settings_basic') {
            BasicSettingsPage({
              ctx: {
                onBack: (): void => this.setView('home')
              }
            }).width('100%').height('100%')
          } else if (this.currentView === 'edit') {
            EditPage({
              ctx: {
                deckId: this.activeDeckId,
                onBack: (): void => this.setView('home')
              }
            }).width('100%').height('100%')
          } else if (this.currentView === 'study') {
            StudyPage({
              ctx: {
                deckId: this.activeDeckId,
                onBack: (): void => this.setView('home')
              }
            }).width('100%').height('100%')
          } else if (this.currentView === 'match') {
            MatchPage({
              ctx: {
                deckId: this.activeDeckId,
                onBack: (): void => this.setView('home')
              }
            }).width('100%').height('100%')
          }
        }
        .layoutWeight(1)
        .width('100%')

        if (this.currentView === 'home' || this.currentView === 'aiagent' || this.currentView === 'profile') {
          Row() {
            Column() {
              if (this.currentView === 'home') {
                Image($r('app.media.fa_house_purple')).width(22).height(22)
              } else {
                Image($r('app.media.fa_house_gray')).width(22).height(22)
              }
              Text('记忆')
                .fontSize(10)
                .fontColor(this.currentView === 'home' ? '#4F46E5' : '#9CA3AF')
                .margin({ top: 4 })
            }
            .width('33%')
            .height(60)
            .justifyContent(FlexAlign.End)
            .padding({ bottom: 8 })
            .onClick(() => this.setView('home'))

            Column() {
              if (this.currentView === 'aiagent') {
                Image($r('app.media.fa_sparkles_purple')).width(22).height(22)
              } else {
                Image($r('app.media.fa_sparkles_gray')).width(22).height(22)
              }
              Text('生成')
                .fontSize(10)
                .fontColor(this.currentView === 'aiagent' ? '#4F46E5' : '#9CA3AF')
                .margin({ top: 4 })
            }
            .width('33%')
            .height(60)
            .justifyContent(FlexAlign.End)
            .padding({ bottom: 8 })
            .onClick(() => this.setView('aiagent'))

            Column() {
              if (this.currentView === 'profile') {
                Image($r('app.media.fa_user_purple')).width(22).height(22)
              } else {
                Image($r('app.media.fa_user_gray')).width(22).height(22)
              }
              Text('我的')
                .fontSize(10)
                .fontColor(this.currentView === 'profile' ? '#4F46E5' : '#9CA3AF')
                .margin({ top: 4 })
            }
            .width('34%')
            .height(60)
            .justifyContent(FlexAlign.End)
            .padding({ bottom: 8 })
            .onClick(() => this.setView('profile'))
          }
          .height(60)
          .width('100%')
          .backgroundColor('#FFFFFF')
        }
      }
      .height('100%')
      .width('100%')

      if (this.showDeleteDeckConfirm) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#11182780')
            .onClick(() => {
              this.showDeleteDeckConfirm = false
              this.pendingDeleteDeckId = -1
            })

          Column() {
            Text('确认删除')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111827')

            Text('删除后不可恢复')
              .fontSize(12)
              .fontColor('#6B7280')
              .margin({ top: 8 })

            Row() {
              Blank().layoutWeight(1)

              Text('取消')
                .fontSize(16)
                .fontColor('#111827')
                .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                .onClick(() => {
                  this.showDeleteDeckConfirm = false
                  this.pendingDeleteDeckId = -1
                })

              Button('删除')
                .height(40)
                .padding({ left: 18, right: 18 })
                .backgroundColor('#EF4444')
                .fontColor('#FFFFFF')
                .borderRadius(12)
                .margin({ left: 10 })
                .onClick(() => this.confirmDeleteDeck())
            }
            .margin({ top: 14 })
          }
          .width('84%')
          .padding({ left: 18, right: 18, top: 18, bottom: 14 })
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#E5E7EB' })
          .borderRadius(20)
          .shadow({ radius: 24, color: '#1118271A', offsetX: 0, offsetY: 12 })
          .onClick(() => {})
        }
        .width('100%')
        .height('100%')
      }
    }
    .height('100%')
    .width('100%')
  }
}
