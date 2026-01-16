import { calculateSM2 } from '../../../ets/utils/sm2'

/**
 * SM-2 算法单元测试（简版）
 */
export default function runSm2Tests(): void {
  const base = { id: 1, front: 'A', back: 'a' }
  const r1 = calculateSM2(base as any, 5)
  if (r1.interval !== 1) {
    throw new Error('首次复习 interval 应为 1')
  }
  const r2 = calculateSM2(r1 as any, 4)
  if (r2.interval !== 6) {
    throw new Error('第二次复习 interval 应为 6')
  }
  const r3 = calculateSM2(r2 as any, 4)
  if (!r3.interval || r3.interval < 6) {
    throw new Error('第三次复习 interval 应大于等于 6')
  }
}
