import type { Deck } from '../model/types'
import { initStorage, getDecks, deleteDeck } from '../services/storage'
import { HomePage } from './home/Home'
import { EditPage } from './edit/Edit'
import { StudyPage } from './study/Study'
import { MatchPage } from './match/Match'
import { HistoryPage } from './history/History'
import { SettingsPage } from './settings/Settings'
import { BasicSettingsPage } from './settings/BasicSettings'

@Entry
@Component
struct Index {
  @State currentView: string = 'home'
  @State activeDeckId: number = -1
  @State decks: Deck[] = []

  aboutToAppear(): void {
    const demo: Deck[] = [
      {
        id: 1,
        title: '基础英语单词',
        description: '日常生活常用词汇',
        cards: [
          { id: 1, front: 'Apple', back: '苹果', nextReview: new Date().toISOString() },
          { id: 2, front: 'Water', back: '水', nextReview: new Date().toISOString() }
        ]
      }
    ]
    this.decks = initStorage(demo, getContext(this))
  }

  setView(view: string, deckId: number = -1): void {
    this.currentView = view
    this.activeDeckId = deckId
    this.decks = getDecks()
  }

  build(): void {
    Column() {
      Column() {
        if (this.currentView === 'home') {
        HomePage({
          decks: this.decks,
          handlers: {
            onStartStudy: (id: number): void => this.setView('study', id),
            onStartMatch: (id: number): void => this.setView('match', id),
            onOpenEditor: (id: number): void => this.setView('edit', id),
            onDeleteDeck: (id: number): void => {
              deleteDeck(id)
              this.setView('home')
            },
            onOpenSettings: (): void => this.setView('settings_basic'),
            onRefresh: (): void => this.setView('home')
          }
        })
          .width('100%')
          .height('100%')
        } else if (this.currentView === 'history') {
          HistoryPage().width('100%').height('100%')
        } else if (this.currentView === 'profile') {
          SettingsPage().width('100%').height('100%')
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

      if (this.currentView === 'home' || this.currentView === 'history' || this.currentView === 'profile') {
        Row() {
          Column() {
            if (this.currentView === 'home') {
              Image($r('app.media.fa_house_purple')).width(22).height(22)
            } else {
              Image($r('app.media.fa_house_gray')).width(22).height(22)
            }
          }
          .width('33%')
          .height(56)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.setView('home'))

          Column() {
            if (this.currentView === 'history') {
              Image($r('app.media.fa_clock_rotate_purple')).width(22).height(22)
            } else {
              Image($r('app.media.fa_clock_rotate_gray')).width(22).height(22)
            }
          }
          .width('33%')
          .height(56)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.setView('history'))

          Column() {
            if (this.currentView === 'profile') {
              Image($r('app.media.fa_user_purple')).width(22).height(22)
            } else {
              Image($r('app.media.fa_user_gray')).width(22).height(22)
            }
          }
          .width('34%')
          .height(56)
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.setView('profile'))
        }
        .height(56)
        .width('100%')
        .backgroundColor('#FFFFFF')
      }
    }
    .height('100%')
    .width('100%')
  }
}
