import type { Deck, Card } from '../../model/types'
import { getDecks, updateDeck, importCSVToDeck } from '../../services/storage'
import fs from '@ohos.file.fs'
import { common } from '@kit.AbilityKit'
import { picker, fileIo } from '@kit.CoreFileKit'
import promptAction from '@ohos.promptAction'

interface EditCtx {
  deckId: number
  onBack: () => void
}

@Component
export struct EditPage {
  @Prop ctx: EditCtx
  @State deck: Deck | undefined = undefined
  @State newFront: string = ''
  @State newBack: string = ''

  private toast(message: string): void {
    try {
      promptAction.showToast({ message })
    } catch (_) {
    }
  }

  aboutToAppear(): void {
    if (this.ctx.deckId === -1) {
      this.deck = undefined
      return
    }
    this.deck = getDecks().find(d => d.id === this.ctx.deckId)
  }

  addCard(): void {
    if (!this.deck) {
      return
    }
    if (!this.newFront.trim() || !this.newBack.trim()) {
      return
    }
    const card: Card = {
      id: Date.now(),
      front: this.newFront.trim(),
      back: this.newBack.trim(),
      nextReview: new Date().toISOString()
    }
    const nextCards: Card[] = []
    for (let i = 0; i < this.deck.cards.length; i++) {
      nextCards.push(this.deck.cards[i])
    }
    nextCards.push(card)
    this.deck = {
      id: this.deck.id,
      title: this.deck.title,
      description: this.deck.description,
      cards: nextCards
    }
    updateDeck(this.deck!)
    this.newFront = ''
    this.newBack = ''
  }

  removeCard(id: number): void {
    if (!this.deck) {
      return
    }
    const nextCards: Card[] = []
    for (let i = 0; i < this.deck.cards.length; i++) {
      const c = this.deck.cards[i]
      if (c.id !== id) {
        nextCards.push(c)
      }
    }
    this.deck = {
      id: this.deck.id,
      title: this.deck.title,
      description: this.deck.description,
      cards: nextCards
    }
    updateDeck(this.deck!)
  }

  private formatNextReview(v?: string): string {
    if (!v) {
      return '下次复习：-'
    }
    const d = new Date(v as string)
    if (Number.isNaN(d.getTime())) {
      return '下次复习：-'
    }
    return '下次复习：' + String(d.getFullYear()) + '/' + String(d.getMonth() + 1) + '/' + String(d.getDate())
  }

  private normalizeCsvUri(uri: string, ctx: common.Context): string {
    const decoded = (() => {
      try {
        return decodeURIComponent(uri)
      } catch (_) {
        return uri
      }
    })()
    if (decoded.startsWith('file://')) {
      return decoded.slice('file://'.length)
    }
    const cachePrefix = 'internal://cache/'
    if (decoded.startsWith(cachePrefix)) {
      return `${(ctx as any).cacheDir}/${decoded.slice(cachePrefix.length)}`
    }
    const filesPrefix = 'internal://app/files/'
    if (decoded.startsWith(filesPrefix)) {
      return `${(ctx as any).filesDir}/${decoded.slice(filesPrefix.length)}`
    }
    return decoded
  }

  private tryReadText(pathOrUri: string): string {
    try {
      return fs.readTextSync(pathOrUri, { encoding: 'utf-8' })
    } catch (_) {
      return ''
    }
  }

  async importCSVFromFile(): Promise<void> {
    if (!this.deck) {
      return
    }
    try {
      const ctx = getContext(this) as common.Context
      const documentPicker = new picker.DocumentViewPicker(ctx)
      const uris = await documentPicker.select()
      if (!uris || uris.length === 0) {
        this.toast('未选择文件')
        return
      }
      const uri = uris[0]

      const beforeCount = this.deck.cards.length
      let csvText = this.tryReadText(this.normalizeCsvUri(uri, ctx))
      if (!csvText.trim()) {
        const filename = 'import_' + String(Date.now()) + '.csv'
        const cacheRelPath = '/cache/' + filename
        const cacheUri = 'internal://cache/' + filename
        const maybeFileIo = fileIo as any
        try {
          if (maybeFileIo && typeof maybeFileIo.copyToCache === 'function') {
            try {
              await maybeFileIo.copyToCache(uri, cacheRelPath)
            } catch (_) {
              await maybeFileIo.copyToCache(uri, cacheUri)
            }
          }
        } catch (_) {
        }
        const cachePath = `${(ctx as any).cacheDir}/${filename}`
        csvText = this.tryReadText(cachePath)
      }

      if (!csvText.trim()) {
        this.toast('导入失败：无法读取文件，请选择设备上的CSV文件')
        return
      }

      importCSVToDeck(this.deck.id, csvText)
      this.deck = getDecks().find(d => d.id === this.deck!.id)
      const afterCount = this.deck?.cards.length ?? beforeCount
      const added = Math.max(0, afterCount - beforeCount)
      this.toast('已导入 ' + String(added) + ' 条')
    } catch (_) {
      this.toast('导入失败')
    }
  }

  build(): void {
    if (!this.deck) {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.fa_arrow_left')).width(16).height(16)
          }.onClick(() => this.ctx.onBack())
        }
        .margin({ bottom: 12 })

        Text('未找到卡组').fontSize(18)
      }.padding(24)
    } else {
      Column() {
        Row() {
          Row() {
            Image($r('app.media.fa_arrow_left')).width(16).height(16)
          }.onClick(() => this.ctx.onBack())

          Column() {
            Text('编辑: ' + this.deck.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#111827')
            Text('共 ' + String(this.deck.cards.length) + ' 张卡片')
              .fontSize(12)
              .fontColor('#6B7280')
              .margin({ top: 4 })
          }
          .margin({ left: 10 })
          .layoutWeight(1)

          Button() {
            Row() {
              Image($r('app.media.fa_upload')).width(16).height(16)
              Text(' 导入 CSV').fontSize(14).fontColor('#111827')
            }
          }
          .height(36)
          .padding({ left: 14, right: 14 })
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .border({ width: 1, color: '#4F46E5' })
          .onClick(() => this.importCSVFromFile())
        }
        .alignItems(VerticalAlign.Center)
        .padding({
          left: 16,
          right: 16,
          top: 12,
          bottom: 12
        })
        .backgroundColor('#FFFFFF')

        Scroll() {
          Column() {
            Column() {
              Row() {
                Image($r('app.media.fa_plus_purple')).width(14).height(14)
                Text(' 添加新卡片').fontSize(14).fontColor('#111827').fontWeight(FontWeight.Medium)
              }

              Row() {
                TextArea({ placeholder: '正面...', text: this.newFront })
                  .height(100)
                  .layoutWeight(1)
                  .onChange((v: string) => this.newFront = v)
                  .borderRadius(12)
                  .border({ width: 1, color: '#E5E7EB' })

                TextArea({ placeholder: '背面...', text: this.newBack })
                  .height(100)
                  .layoutWeight(1)
                  .onChange((v: string) => this.newBack = v)
                  .borderRadius(12)
                  .border({ width: 1, color: '#E5E7EB' })
                  .margin({ left: 12 })
              }.margin({ top: 14 })

              Row() {
                Blank().layoutWeight(1)
                Button() {
                  Row() {
                    Image($r('app.media.fa_floppy_disk_white')).width(16).height(16)
                    Text(' 保存').fontSize(14).fontColor('#FFFFFF')
                  }
                }
                .height(40)
                .padding({ left: 18, right: 18 })
                .backgroundColor('#4F46E5')
                .borderRadius(12)
                .onClick(() => this.addCard())
              }.margin({ top: 14 })
            }
            .padding({
              left: 16,
              right: 16,
              top: 16,
              bottom: 16
            })
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .border({ width: 1, color: '#E5E7EB' })
            .margin({ left: 16, right: 16, top: 16 })

            Column() {
              ForEach(this.deck.cards, (card: Card, index: number) => {
                Row() {
                  Text(String(index + 1))
                    .width(28)
                    .height(28)
                    .backgroundColor('#EEF2FF')
                    .borderRadius(14)
                    .textAlign(TextAlign.Center)
                    .fontSize(12)
                    .fontColor('#4F46E5')

                  Column() {
                    Text(card.front).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#111827')
                    Text(this.formatNextReview(card.nextReview as string))
                      .fontSize(11)
                      .fontColor('#9CA3AF')
                      .margin({ top: 6 })
                  }
                  .layoutWeight(1)
                  .margin({ left: 12 })

                  Text(card.back)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#111827')
                    .textAlign(TextAlign.Center)
                    .width(120)

                  Row() {
                    Image($r('app.media.fa_trash')).width(18).height(18)
                  }
                  .width(44)
                  .height(44)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(VerticalAlign.Center)
                  .onClick(() => this.removeCard(card.id))
                }
                .padding({
                  left: 16,
                  right: 10,
                  top: 12,
                  bottom: 12
                })
                .backgroundColor('#FFFFFF')
                .borderRadius(14)
                .border({ width: 1, color: '#E5E7EB' })
                .margin({ left: 16, right: 16, top: 12 })
              })
              Blank().height(20)
            }
          }.width('100%')
        }
        .layoutWeight(1)
      }
      .height('100%')
      .backgroundColor('#F7F7F9')
    }
  }
}
