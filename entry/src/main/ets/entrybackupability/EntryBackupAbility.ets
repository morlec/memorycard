import { hilog } from '@kit.PerformanceAnalysisKit';
import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import { exportDecksJSON, importDecksJSON } from '../services/storage'

const DOMAIN = 0x0000;

export default class EntryBackupAbility extends BackupExtensionAbility {
  /**
   * 备份：导出卡组 JSON（占位，实现备份通道对接时写入系统存储）
   */
  async onBackup() {
    const payload = exportDecksJSON()
    hilog.info(DOMAIN, 'backup', 'backup payload length %{public}d', payload.length)
    await Promise.resolve()
  }

  /**
   * 恢复：从 JSON 载入卡组（占位，实现从系统备份源读取后导入）
   */
  async onRestore(bundleVersion: BundleVersion) {
    hilog.info(DOMAIN, 'restore', 'bundleVersion %{public}s', JSON.stringify(bundleVersion));
    // 占位：示例不含真实载入源，保持流程打通
    const sample = '[]'
    importDecksJSON(sample)
    await Promise.resolve()
  }
}
