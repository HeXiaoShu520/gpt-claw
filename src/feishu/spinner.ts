const styles = [
  ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"],
  ["◐", "◓", "◑", "◒"],
  ["◴", "◷", "◶", "◵"],
  ["·", "··", "···"],
] as const;

const prefixes = ["思考中", "正在思考", "分析中", "处理中"] as const;

/** One reply keeps the same animation style while advancing through its frames. */
export class Spinner {
  private readonly frames: readonly string[] = styles[Math.floor(Math.random() * styles.length)]!;
  private prefix: string = prefixes[Math.floor(Math.random() * prefixes.length)]!;
  private index = 0;

  withPrefix(prefix: string): void { this.prefix = prefix; }

  next(): string {
    return `${this.prefix} ${this.frames[this.index++ % this.frames.length]}`;
  }
}
