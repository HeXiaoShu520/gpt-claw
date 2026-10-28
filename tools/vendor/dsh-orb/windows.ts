// Adapted from dsh-orb-cordis, MIT; see LICENSE and README.md.
import { deflateSync, crc32 } from 'node:zlib'
import type { WindowsDesktopSnapshot } from './windows-foreground.ts'

export interface WindowsRect {
  readonly x: number
  readonly y: number
  readonly width: number
  readonly height: number
}

/**
 * Host operations behind the Windows backend.
 * Production uses Win32. Tests supply fakes.
 * `listWindows` returns physical pixels. Capture and pointer input use that same space.
 */
export interface WindowsDesktopOps {
  /** Z-order snapshot in physical pixels, including the foreground hwnd. */
  listWindows(): WindowsDesktopSnapshot
  capturePng(bounds: WindowsRect): Uint8Array
  /** True when the foreground window is elevated above this process (UIPI). */
  targetBlocksInput(): boolean
  movePointer(x: number, y: number): void
  mouseButton(button: 'left' | 'right', down: boolean): void
  scrollWheel(x: number, y: number, delta: number): void
  /**
   * Post one key transition.
   * @param virtualKey - Win32 virtual-key code.
   * @param down - true for key down, false for key up.
   * @param extended - true for the extended navigation keys (`KEYEVENTF_EXTENDEDKEY`).
   */
  key(virtualKey: number, down: boolean, extended?: boolean): void
  unicodeKey(codeUnit: number, down: boolean): void
  windowAtPoint(x: number, y: number): number
  readClipboardText(): string
  setClipboardText(text: string): void
  copyImageFile(path: string): void
  listWindowApps(): readonly string[]
  /**
   * Bring a running app forward.
   * @param name - process base name or a substring of the window title.
   * @returns false when no window matches `name`.
   * @throws when a window matches but does not become foreground.
   */
  activateApp(name: string): boolean
  /**
   * HWND of the current foreground window.
   * @returns a positive HWND, or `0` when no window is foreground.
   */
  foregroundWindowId(): number
  /**
   * Bring `hwnd` forward with the same Alt plus `SetForegroundWindow` sequence as `activateApp`.
   * Restores an iconic window before that call.
   * @param hwnd - top-level HWND from an observation.
   * @returns false when that window is not in the current top-level list or does not become foreground.
   */
  focusWindow(hwnd: number): boolean
  launch(target: string, parameters?: string): void
  /**
   * Explorer address path for one Explorer window.
   * @param hwnd - Explorer window handle.
   * @returns the folder path, or undefined when it cannot be read.
   */
  explorerFolder(hwnd: number): string | undefined
}

const KEY_NAMES: Readonly<Record<string, number>> = {
  ctrl: 0x11,
  control: 0x11,
  alt: 0x12,
  option: 0x12,
  shift: 0x10,
  win: 0x5B,
  windows: 0x5B,
  meta: 0x5B,
  cmd: 0x5B,
  command: 0x5B,
  super: 0x5B,
  enter: 0x0D,
  return: 0x0D,
  tab: 0x09,
  escape: 0x1B,
  esc: 0x1B,
  space: 0x20,
  backspace: 0x08,
  delete: 0x2E,
  del: 0x2E,
  up: 0x26,
  down: 0x28,
  left: 0x25,
  right: 0x27,
  home: 0x24,
  end: 0x23,
  pageup: 0x21,
  pagedown: 0x22,
  insert: 0x2D,
}

/** Navigation keys whose scan code is the extended set. Numpad names are not in this map. */
const EXTENDED_KEY_NAMES = new Set([
  'up',
  'down',
  'left',
  'right',
  'home',
  'end',
  'pageup',
  'pagedown',
  'insert',
  'delete',
  'del',
])

export function windowsVirtualKey(key: string): number {
  const token = key.trim().toLowerCase()
  const named = KEY_NAMES[token]
  if (named !== undefined) return named
  if (/^[a-z]$/u.test(token)) return token.toUpperCase().charCodeAt(0)
  if (/^[0-9]$/u.test(token)) return token.charCodeAt(0)
  const fn = /^f([1-9]|1[0-2])$/u.exec(token)
  if (fn !== null) return 0x70 + Number(fn[1]) - 1
  throw new Error(`computer-use: unknown key ${JSON.stringify(key)}`)
}

/**
 * Whether a hotkey token needs `KEYEVENTF_EXTENDEDKEY`.
 * @param key - model-supplied key name.
 * @returns true for arrows, editing, and navigation keys. Letters and digits return false.
 */
export function windowsKeyIsExtended(key: string): boolean {
  return EXTENDED_KEY_NAMES.has(key.trim().toLowerCase())
}

export function encodeBgraPng(width: number, height: number, bgra: Buffer, bottomUp: boolean): Uint8Array {
  const rowBytes = width * 4
  const raw = Buffer.alloc((rowBytes + 1) * height)
  for (let y = 0; y < height; y += 1) {
    const sourceY = bottomUp ? height - 1 - y : y
    const dest = y * (rowBytes + 1)
    raw[dest] = 0
    for (let x = 0; x < width; x += 1) {
      const source = sourceY * rowBytes + x * 4
      const pixel = dest + 1 + x * 4
      raw[pixel] = bgra[source + 2] ?? 0
      raw[pixel + 1] = bgra[source + 1] ?? 0
      raw[pixel + 2] = bgra[source] ?? 0
      raw[pixel + 3] = 255
    }
  }
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])
  const ihdr = Buffer.alloc(13)
  ihdr.writeUInt32BE(width, 0)
  ihdr.writeUInt32BE(height, 4)
  ihdr[8] = 8
  ihdr[9] = 6
  return Buffer.concat([
    signature,
    pngChunk('IHDR', ihdr),
    pngChunk('IDAT', deflateSync(raw)),
    pngChunk('IEND', Buffer.alloc(0)),
  ])
}

function pngChunk(type: string, data: Buffer): Buffer {
  const length = Buffer.alloc(4)
  length.writeUInt32BE(data.length)
  const name = Buffer.from(type)
  const crc = Buffer.alloc(4)
  crc.writeUInt32BE(crc32(Buffer.concat([name, data])) >>> 0)
  return Buffer.concat([length, name, data, crc])
}

