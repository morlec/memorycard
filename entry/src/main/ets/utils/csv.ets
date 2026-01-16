import type { Card } from '../model/types'

/**
 * 解析 CSV 文本为卡片列表（支持双引号与逗号）
 * - 每行至少两列：front, back
 * - 自动生成 id 与 nextReview（当前时间）
 */
export function parseCardsFromCSV(text: string, idBase: number = Date.now()): Card[] {
  const cards: Card[] = []
  const lines = text.split(/\r?\n/)
  let idx = 0
  for (const line of lines) {
    if (!line.trim()) continue
    const row: string[] = []
    let current = ''
    let inQuotes = false
    for (let i = 0; i < line.length; i++) {
      const ch = line[i]
      if (ch === '"') {
        if (i + 1 < line.length && line[i + 1] === '"') {
          current += '"'
          i++
        } else {
          inQuotes = !inQuotes
        }
      } else if (ch === ',' && !inQuotes) {
        row.push(current.trim())
        current = ''
      } else {
        current += ch
      }
    }
    row.push(current.trim())
    if (row.length >= 2 && row[0] && row[1]) {
      const nowIso = new Date().toISOString()
      cards.push({
        id: idBase + idx,
        front: row[0].replace(/^\"(.*)\"$/, '$1'),
        back: row[1].replace(/^\"(.*)\"$/, '$1'),
        nextReview: nowIso
      })
      idx++
    }
  }
  return cards
}

