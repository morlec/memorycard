import fs from '@ohos.file.fs'

export interface AppSettings {
  matchPickCount: number
  matchRandom: boolean
  deepseekApiKey: string
  deepseekBaseUrl: string
  deepseekModel: string
}

export interface AppSettingsPatch {
  matchPickCount?: number
  matchRandom?: boolean
  deepseekApiKey?: string
  deepseekBaseUrl?: string
  deepseekModel?: string
}

const SETTINGS_FILE_NAME = 'app-settings.json'

let initialized: boolean = false
let settingsFilePath: string = ''
let settings: AppSettings = {
  matchPickCount: 6,
  matchRandom: true,
  deepseekApiKey: '',
  deepseekBaseUrl: 'https://api.deepseek.com',
  deepseekModel: 'deepseek-chat'
}

function sanitizePickCount(v: number): number {
  if (!Number.isFinite(v)) return 6
  const n = Math.floor(v)
  if (n < 2) return 2
  if (n > 20) return 20
  return n
}

function sanitizeSettings(next: AppSettingsPatch): AppSettings {
  return {
    matchPickCount: sanitizePickCount(next.matchPickCount ?? settings.matchPickCount),
    matchRandom: typeof next.matchRandom === 'boolean' ? next.matchRandom : settings.matchRandom,
    deepseekApiKey: typeof next.deepseekApiKey === 'string' ? next.deepseekApiKey : settings.deepseekApiKey,
    deepseekBaseUrl: typeof next.deepseekBaseUrl === 'string' && next.deepseekBaseUrl ? next.deepseekBaseUrl : settings.deepseekBaseUrl,
    deepseekModel: typeof next.deepseekModel === 'string' && next.deepseekModel ? next.deepseekModel : settings.deepseekModel
  }
}

function persist(): void {
  if (!settingsFilePath) return
  try {
    const file = fs.openSync(settingsFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
    fs.writeSync(file.fd, JSON.stringify(settings))
    fs.closeSync(file)
  } catch (_) {
  }
}

export function initAppSettings(ctx?: any): AppSettings {
  if (initialized) return settings
  initialized = true

  const filesDir = (ctx as any)?.filesDir as string | undefined
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
