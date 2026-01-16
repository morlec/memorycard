import { getAppSettings, updateAppSettings } from '../../services/appSettings'
import { APP_NAME, APP_VERSION } from '../../services/appInfo'

interface SettingsCtx {
  onBack: () => void
  onOpenPreferences: () => void
}

@Component
export struct SettingsPage {
  @Prop ctx?: SettingsCtx
  @State nickname: string = '学习者'
  @State avatarIndex: number = 0

  aboutToAppear(): void {
    const s = getAppSettings()
    this.nickname = s.profileNickname
    this.avatarIndex = s.profileAvatarIndex
  }

  private getAvatarColor(): string {
    const colors: string[] = ['#4F46E5', '#06B6D4', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#111827']
    const idx = Math.max(0, Math.min(colors.length - 1, this.avatarIndex % colors.length))
    return colors[idx]
  }

  private getAvatarText(): string {
    const t = this.nickname.trim()
    if (!t) {
      return '我'
    }
    return t.slice(0, 1)
  }

  private cycleAvatar(): void {
    const next = (this.avatarIndex + 1) % 7
    this.avatarIndex = next
    updateAppSettings({ profileAvatarIndex: this.avatarIndex })
  }

  private setNickname(v: string): void {
    this.nickname = v
    updateAppSettings({ profileNickname: this.nickname })
  }

  build(): void {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.fa_arrow_left')).width(16).height(16)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          if (this.ctx) {
            this.ctx.onBack()
          }
        })

        Row() {
          Image($r('app.media.fa_user_purple')).width(18).height(18)
          Text(' 个人设置').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#111827')
        }
        .layoutWeight(1)
        .padding({ left: 4 })
        .alignItems(VerticalAlign.Center)

        Row().width(44).height(44)
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 12, right: 12, top: 6 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          Column() {
            Row() {
              Stack({ alignContent: Alignment.Center }) {
                Row()
                  .width(56)
                  .height(56)
                  .backgroundColor(this.getAvatarColor())
                  .borderRadius(28)
                Text(this.getAvatarText())
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
              }
              .width(56)
              .height(56)

              Column() {
                Text('头像').fontSize(12).fontColor('#6B7280')
                Text('点击更换').fontSize(14).fontColor('#111827').fontWeight(FontWeight.Medium).margin({ top: 6 })
              }
              .margin({ left: 12 })
              .layoutWeight(1)

              Row() {
                Image($r('app.media.fa_chevron_right')).width(16).height(16)
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
            }
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .onClick(() => this.cycleAvatar())

            Divider().color('#EEF2FF')

            Column() {
              Text('昵称').fontSize(12).fontColor('#6B7280')
              TextInput({ placeholder: '请输入昵称', text: this.nickname })
                .height(44)
                .border({ width: 1, color: '#E5E7EB' })
                .borderRadius(12)
                .padding({ left: 12, right: 12 })
                .margin({ top: 10 })
                .onChange((v: string) => this.setNickname(v))
            }
            .padding({ left: 16, right: 16, top: 14, bottom: 16 })
          }
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .border({ width: 1, color: '#E5E7EB' })
          .margin({ left: 16, right: 16, top: 16 })
          .shadow({ radius: 16, color: '#1F29370F', offsetX: 0, offsetY: 8 })

          Column() {
            Row() {
              Text('偏好设置').fontSize(14).fontColor('#111827').fontWeight(FontWeight.Medium)
              Blank().layoutWeight(1)
              Image($r('app.media.fa_chevron_right')).width(16).height(16)
            }
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .onClick(() => {
              if (this.ctx) {
                this.ctx.onOpenPreferences()
              }
            })
          }
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .border({ width: 1, color: '#E5E7EB' })
          .margin({ left: 16, right: 16, top: 14 })
          .shadow({ radius: 16, color: '#1F29370F', offsetX: 0, offsetY: 8 })

          Column() {
            Row() {
              Text('关于').fontSize(14).fontColor('#111827').fontWeight(FontWeight.Medium)
              Blank().layoutWeight(1)
            }
            .padding({ left: 16, right: 16, top: 16, bottom: 10 })

            Divider().color('#EEF2FF')

            Row() {
              Text('软件名称').fontSize(14).fontColor('#111827')
              Blank().layoutWeight(1)
              Text(APP_NAME).fontSize(14).fontColor('#6B7280')
            }
            .padding({ left: 16, right: 16, top: 14, bottom: 10 })

            Row() {
              Text('版本号').fontSize(14).fontColor('#111827')
              Blank().layoutWeight(1)
              Text(APP_VERSION).fontSize(14).fontColor('#6B7280')
            }
            .padding({ left: 16, right: 16, top: 10, bottom: 16 })
          }
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .border({ width: 1, color: '#E5E7EB' })
          .margin({ left: 16, right: 16, top: 14, bottom: 18 })
          .shadow({ radius: 16, color: '#1F29370F', offsetX: 0, offsetY: 8 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F7F7F9')
    }
    .backgroundColor('#F7F7F9')
    .height('100%')
    .width('100%')
  }
}
