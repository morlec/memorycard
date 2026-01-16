export interface Card {
  id: number
  front: string
  back: string
  nextReview?: string
  interval?: number
  repetitions?: number
  easeFactor?: number
}

export interface Deck {
  id: number
  title: string
  description?: string
  cards: Card[]
}

