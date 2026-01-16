import type { Card } from '../model/types'

/**
 * 计算并更新卡片的 SM-2 间隔重复参数
 * - 输入评分：0=Again，3=Hard，4=Good，5=Easy
 * - 返回更新后的卡片（包含 interval、repetitions、easeFactor、nextReview）
 */
export function calculateSM2(card: Card, rating: number): Card {
  let interval = card.interval ?? 0
  let repetitions = card.repetitions ?? 0
  let easeFactor = card.easeFactor ?? 2.5

  if (rating === 0) {
    repetitions = 0
    interval = 0
  } else {
    easeFactor = easeFactor + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02))
    if (easeFactor < 1.3) easeFactor = 1.3
    repetitions += 1
    if (repetitions === 1) {
      interval = 1
    } else if (repetitions === 2) {
      interval = 6
    } else {
      interval = Math.round(interval * easeFactor)
    }
  }

  const nextReviewDate = new Date()
  nextReviewDate.setDate(nextReviewDate.getDate() + interval)

  const updated: Card = {
    id: card.id,
    front: card.front,
    back: card.back,
    interval: interval,
    repetitions: repetitions,
    easeFactor: easeFactor,
    nextReview: nextReviewDate.toISOString()
  }
  return updated
}
