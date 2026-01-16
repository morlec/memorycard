import http from '@ohos.net.http'
import { getAppSettings } from './appSettings'

class GeminiPart {
  text?: string
}

class GeminiContent {
  parts?: Array<GeminiPart>
}

class GeminiCandidate {
  content?: GeminiContent
}

class GeminiGenerateContentResponse {
  candidates?: Array<GeminiCandidate>
}

class ChatMessage {
  content?: string
}

class ChatChoice {
  message?: ChatMessage
}

class ChatCompletionsResponse {
  choices?: Array<ChatChoice>
}

function escapeJsonString(v: string): string {
  return v
    .replace(/\\/g, '\\\\')
    .replace(/"/g, '\\"')
    .replace(/\r/g, '\\r')
    .replace(/\n/g, '\\n')
    .replace(/\t/g, '\\t')
}

function normalizeCsv(text: string): string {
  let t = text.trim()
  if (t.startsWith('```')) {
    t = t.replace(/^```[a-zA-Z]*\n/, '')
    t = t.replace(/\n```$/, '')
    t = t.trim()
  }
  return t
}

function buildPrompt(topic: string, count: number): string {
  return (
    '请根据主题生成记忆卡片，要求：\n' +
    `1) 共生成${count}条\n` +
    '2) 每条一行CSV，格式为：front,back\n' +
    '3) 不要输出标题行，不要输出序号，不要输出解释\n' +
    '4) 如果内容含逗号或引号，请使用CSV标准双引号转义\n' +
    `主题：${topic}\n`
  )
}

function normalizeBaseUrl(v: string): string {
  return v.replace(/\/+$/, '')
}

export function getAiProviderLabel(provider: string): string {
  if (provider === 'openai') return 'GPT'
  if (provider === 'gemini') return 'Gemini'
  return 'DeepSeek'
}

export function getAiApiKey(): string {
  const s = getAppSettings()
  if (s.aiProvider === 'openai') return (s.openaiApiKey ?? '').trim()
  if (s.aiProvider === 'gemini') return (s.geminiApiKey ?? '').trim()
  return s.deepseekApiKey.trim()
}

export async function aiGenerateCSV(topic: string, count: number): Promise<string> {
  const settings = getAppSettings()
  const provider = settings.aiProvider
  const apiKey = getAiApiKey()
  if (!apiKey) {
    throw new Error('missing_api_key')
  }

  const prompt = buildPrompt(topic, count)
  const client = http.createHttp()
  try {
    if (provider === 'gemini') {
      const baseUrl = normalizeBaseUrl(settings.geminiBaseUrl ?? 'https://generativelanguage.googleapis.com')
      const model = settings.geminiModel ?? 'gemini-1.5-flash'
      const modelName = model.startsWith('models/') ? model.slice('models/'.length) : model
      const url = `${baseUrl}/v1beta/models/${encodeURIComponent(modelName)}:generateContent?key=${encodeURIComponent(apiKey)}`
      const bodyJson =
        '{' +
        '"contents":[{"parts":[{"text":"' + escapeJsonString(prompt) + '"}]}],' +
        '"generationConfig":{"temperature":0.3}' +
        '}'
      const resp = await client.request(url, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: bodyJson,
        connectTimeout: 15000,
        readTimeout: 30000
      })
      const raw = typeof resp.result === 'string' ? resp.result : JSON.stringify(resp.result)
      const parsed: GeminiGenerateContentResponse = JSON.parse(raw) as GeminiGenerateContentResponse
      const text = parsed.candidates?.[0]?.content?.parts?.[0]?.text
      return normalizeCsv(text ?? '')
    }

    const isOpenAI = provider === 'openai'
    const baseUrl = normalizeBaseUrl(
      isOpenAI ? (settings.openaiBaseUrl ?? 'https://api.openai.com/v1') : settings.deepseekBaseUrl
    )
    const model = isOpenAI ? (settings.openaiModel ?? 'gpt-4o-mini') : settings.deepseekModel

    let url = baseUrl
    if (!url.endsWith('/chat/completions')) {
      if (url.endsWith('/v1')) {
        url = url + '/chat/completions'
      } else {
        url = url + '/v1/chat/completions'
      }
    }

    const bodyJson =
      '{' +
      '"model":"' + escapeJsonString(String(model ?? '')) + '",' +
      '"temperature":0.3,' +
      '"messages":[' +
      '{"role":"system","content":"' + escapeJsonString('你是一个只输出CSV内容的助手。') + '"},' +
      '{"role":"user","content":"' + escapeJsonString(prompt) + '"}' +
      ']' +
      '}'

    const resp = await client.request(url, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + apiKey
      },
      extraData: bodyJson,
      connectTimeout: 15000,
      readTimeout: 30000
    })

    const raw = typeof resp.result === 'string' ? resp.result : JSON.stringify(resp.result)
    const parsed: ChatCompletionsResponse = JSON.parse(raw) as ChatCompletionsResponse
    const content = parsed.choices?.[0]?.message?.content
    return normalizeCsv(content ?? '')
  } finally {
    try {
      client.destroy()
    } catch (_) {
    }
  }
}
