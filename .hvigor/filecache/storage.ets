import type { Deck, Card } from '../model/types'
import { parseCardsFromCSV } from '../utils/csv'
import fs from '@ohos.file.fs'

let memoryDecks: Deck[] = []
const STORAGE_KEY = 'flashcard-decks'
let storageFilePath: string = ''
let storageInitialized: boolean = false

/**
 * 初始化存储：加载已有数据或填充默认示例数据
 * - 返回当前卡组列表
 */
export function initStorage(defaultDecks: Deck[] = [], ctx?: any): Deck[] {
  if (storageInitialized) {
    return memoryDecks
  }
  storageInitialized = true

  const filesDir = (ctx as any)?.filesDir as string | undefined
  if (filesDir) {
    storageFilePath = `${filesDir}/${STORAGE_KEY}.json`
  }

  if (storageFilePath) {
    try {
      const exists = fs.accessSync(storageFilePath)
      if (exists) {
        const json = fs.readTextSync(storageFilePath, { encoding: 'utf-8' })
        const parsed = JSON.parse(json) as Deck[]
        if (Array.isArray(parsed)) {
          memoryDecks = parsed
          return memoryDecks
        }
      }
    } catch (_) {
    }
  }

  memoryDecks = defaultDecks
  persist()
  return memoryDecks
}

/**
 * 获取所有卡组
 */
export function getDecks(): Deck[] {
  return memoryDecks
}

/**
 * 持久化当前内存数据到本地存储
 */
export function persist(): void {
  if (!storageFilePath) {
    return
  }
  try {
    try {
      if (!fs.accessSync(storageFilePath)) {
        const file = fs.openSync(storageFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        fs.closeSync(file)
      }
    } catch (_) {
    }
    const file = fs.openSync(storageFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC)
    fs.writeSync(file.fd, exportDecksJSON())
    fs.closeSync(file)
  } catch (_) {
  }
}

/**
 * 保存卡组列表（覆盖）
 */
export function saveDecks(decks: Deck[]): void {
  memoryDecks = decks
  persist()
}

/**
 * 新增卡组
 */
export function addDeck(deck: Deck): void {
  const next: Deck[] = []
  for (let i = 0; i < memoryDecks.length; i++) {
    next.push(memoryDecks[i])
  }
  next.push(deck)
  memoryDecks = next
  persist()
}

/**
 * 更新指定卡组
 */
export function updateDeck(updated: Deck): void {
  const next: Deck[] = []
  for (let i = 0; i < memoryDecks.length; i++) {
    const d = memoryDecks[i]
    if (d.id === updated.id) {
      next.push(updated)
    } else {
      next.push(d)
    }
  }
  memoryDecks = next
  persist()
}

/**
 * 删除指定卡组
 */
export function deleteDeck(id: number): void {
  const next: Deck[] = []
  for (let i = 0; i < memoryDecks.length; i++) {
    const d = memoryDecks[i]
    if (d.id !== id) {
      next.push(d)
    }
  }
  memoryDecks = next
  persist()
}

/**
 * 向卡组追加新卡片
 */
export function appendCardsToDeck(deckId: number, cards: Card[]): void {
  const nextDecks: Deck[] = []
  for (let i = 0; i < memoryDecks.length; i++) {
    const d = memoryDecks[i]
    if (d.id === deckId) {
      const newCards: Card[] = []
      for (let j = 0; j < d.cards.length; j++) {
        newCards.push(d.cards[j])
      }
      for (let k = 0; k < cards.length; k++) {
        newCards.push(cards[k])
      }
      const updatedDeck: Deck = {
        id: d.id,
        title: d.title,
        description: d.description,
        cards: newCards
      }
      nextDecks.push(updatedDeck)
    } else {
      nextDecks.push(d)
    }
  }
  memoryDecks = nextDecks
  persist()
}

/**
 * 解析 CSV 文本并导入到指定卡组
 * - 返回导入的卡片数量
 */
export function importCSVToDeck(deckId: number, csvText: string): number {
  const cards = parseCardsFromCSV(csvText)
  appendCardsToDeck(deckId, cards)
  return cards.length
}

/**
 * 导出所有卡组为 JSON 字符串
 */
export function exportDecksJSON(): string {
  try {
    return JSON.stringify(memoryDecks)
  } catch (_) {
    return '[]'
  }
}

/**
 * 从 JSON 字符串导入覆盖卡组列表
 */
export function importDecksJSON(json: string): void {
  try {
    const decks = JSON.parse(json) as Deck[]
    saveDecks(decks)
  } catch (_) {
  }
}
