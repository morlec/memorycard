import fs from '@ohos.file.fs'
import { common } from '@kit.AbilityKit'

export interface AppSettings {
  matchPickCount: number
  matchRandom: boolean
  profileNickname: string
  profileAvatarIndex: number
  dailyReviewDate: string
  dailyReviewCount: number
  aiProvider: 'deepseek' | 'openai' | 'gemini'
  deepseekApiKey: string
  deepseekBaseUrl: string
  deepseekModel: string
  openaiApiKey?: string
  openaiBaseUrl?: string
  openaiModel?: string
  geminiApiKey?: string
  geminiBaseUrl?: string
  geminiModel?: string
}

export interface AppSettingsPatch {
  matchPickCount?: number
  matchRandom?: boolean
  profileNickname?: string
  profileAvatarIndex?: number
  dailyReviewDate?: string
  dailyReviewCount?: number
  aiProvider?: 'deepseek' | 'openai' | 'gemini'
  deepseekApiKey?: string
  deepseekBaseUrl?: string
  deepseekModel?: string
  openaiApiKey?: string
  openaiBaseUrl?: string
  openaiModel?: string
  geminiApiKey?: string
  geminiBaseUrl?: string
  geminiModel?: string
}

const SETTINGS_FILE_NAME = 'app-settings.json'

let initialized: boolean = false
let settingsFilePath: string = ''
let settings: AppSettings = {
  matchPickCount: 6,
  matchRandom: true,
  profileNickname: '学习者',
  profileAvatarIndex: 0,
  dailyReviewDate: '',
  dailyReviewCount: 0,
  aiProvider: 'deepseek',
  deepseekApiKey: '',
  deepseekBaseUrl: 'https://api.deepseek.com',
  deepseekModel: 'deepseek-chat'
}

function sanitizePickCount(v: number): number {
  if (!Number.isFinite(v)) {
    return 6
  }
  const n = Math.floor(v)
  if (n < 2) {
    return 2
  }
  if (n > 20) {
    return 20
  }
  return n
}

function sanitizeNickname(v: string): string {
  const t = v.trim()
  if (!t) {
    return '学习者'
  }
  if (t.length > 16) {
    return t.slice(0, 16)
  }
  return t
}

function sanitizeAvatarIndex(v: number): number {
  if (!Number.isFinite(v)) {
    return 0
  }
  const n = Math.floor(v)
  if (n < 0) {
    return 0
  }
  if (n > 9) {
    return 9
  }
  return n
}

function getTodayKey(): string {
  const now = new Date()
  const y = now.getFullYear()
  const m = String(now.getMonth() + 1).padStart(2, '0')
  const d = String(now.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

function sanitizeDailyReviewDate(v: string): string {
  const t = v.trim()
  if (!t) {
    return getTodayKey()
  }
  return t
}

function sanitizeDailyReviewCount(v: number): number {
  if (!Number.isFinite(v)) {
    return 0
  }
  const n = Math.floor(v)
  if (n < 0) {
    return 0
  }
  return n
}

function sanitizeSettings(next: AppSettingsPatch): AppSettings {
  const provider = (next.aiProvider ?? settings.aiProvider) as 'deepseek' | 'openai' | 'gemini'
  const openaiBaseUrlDefault = 'https://api.openai.com/v1'
  const openaiModelDefault = 'gpt-4o-mini'
  const geminiBaseUrlDefault = 'https://generativelanguage.googleapis.com'
  const geminiModelDefault = 'gemini-1.5-flash'

  const openaiApiKey = typeof next.openaiApiKey === 'string' ? next.openaiApiKey : (settings.openaiApiKey ?? '')
  const openaiBaseUrl = typeof next.openaiBaseUrl === 'string' && next.openaiBaseUrl ? next.openaiBaseUrl :
    (settings.openaiBaseUrl ?? openaiBaseUrlDefault)
  const openaiModel = typeof next.openaiModel === 'string' && next.openaiModel ? next.openaiModel :
    (settings.openaiModel ?? openaiModelDefault)

  const geminiApiKey = typeof next.geminiApiKey === 'string' ? next.geminiApiKey : (settings.geminiApiKey ?? '')
  const geminiBaseUrl = typeof next.geminiBaseUrl === 'string' && next.geminiBaseUrl ? next.geminiBaseUrl :
    (settings.geminiBaseUrl ?? geminiBaseUrlDefault)
  const geminiModel = typeof next.geminiModel === 'string' && next.geminiModel ? next.geminiModel :
    (settings.geminiModel ?? geminiModelDefault)

  const todayKey = getTodayKey()
  let dailyReviewDate = typeof next.dailyReviewDate === 'string' ? sanitizeDailyReviewDate(next.dailyReviewDate) :
    sanitizeDailyReviewDate(settings.dailyReviewDate)
  let dailyReviewCount = typeof next.dailyReviewCount === 'number' ? sanitizeDailyReviewCount(next.dailyReviewCount) :
    sanitizeDailyReviewCount(settings.dailyReviewCount)
  if (dailyReviewDate !== todayKey) {
    dailyReviewDate = todayKey
    dailyReviewCount = 0
  }

  return {
    matchPickCount: sanitizePickCount(next.matchPickCount ?? settings.matchPickCount),
    matchRandom: typeof next.matchRandom === 'boolean' ? next.matchRandom : settings.matchRandom,
    profileNickname: typeof next.profileNickname === 'string' ? sanitizeNickname(next.profileNickname) : settings.profileNickname,
    profileAvatarIndex: typeof next.profileAvatarIndex === 'number' ? sanitizeAvatarIndex(next.profileAvatarIndex) :
      settings.profileAvatarIndex,
    dailyReviewDate,
    dailyReviewCount,
    aiProvider: provider,
    deepseekApiKey: typeof next.deepseekApiKey === 'string' ? next.deepseekApiKey : settings.deepseekApiKey,
    deepseekBaseUrl: typeof next.deepseekBaseUrl === 'string' && next.deepseekBaseUrl ? next.deepseekBaseUrl :
      settings.deepseekBaseUrl,
    deepseekModel: typeof next.deepseekModel === 'string' && next.deepseekModel ? next.deepseekModel :
      settings.deepseekModel,
    openaiApiKey,
    openaiBaseUrl,
    openaiModel,
    geminiApiKey,
    geminiBaseUrl,
    geminiModel
  }
}

function persist(): void {
  if (!settingsFilePath) {
    return
  }
  try {
    const file = fs.openSync(settingsFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
    fs.writeSync(file.fd, JSON.stringify(settings))
    fs.closeSync(file)
  } catch (_) {
  }
}

export function initAppSettings(ctx?: common.Context): AppSettings {
  if (initialized) {
    return settings
  }
  initialized = true
  const filesDir = ctx?.filesDir as string | undefined
  if (filesDir) {
    settingsFilePath = `${filesDir}/${SETTINGS_FILE_NAME}`
  }

  if (settingsFilePath) {
    try {
      if (fs.accessSync(settingsFilePath)) {
        const json = fs.readTextSync(settingsFilePath, { encoding: 'utf-8' })
        const parsed = JSON.parse(json) as AppSettingsPatch
        settings = sanitizeSettings(parsed)
        return settings
      }
    } catch (_) {
    }
  }

  persist()
  return settings
}

export function getAppSettings(): AppSettings {
  return settings
}

export function updateAppSettings(patch: AppSettingsPatch): AppSettings {
  settings = sanitizeSettings(patch)
  persist()
  return settings
}

export function incrementDailyReviewCount(delta: number = 1): AppSettings {
  const next = Math.max(0, settings.dailyReviewCount + Math.floor(delta))
  return updateAppSettings({ dailyReviewDate: getTodayKey(), dailyReviewCount: next })
}
