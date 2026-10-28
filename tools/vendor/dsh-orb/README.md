# dsh-orb Windows 操作层

来源：[mini-yifan/dsh-orb-cordis](https://github.com/mini-yifan/dsh-orb-cordis)，`packages/computer-use/src/`，MIT，版权及完整许可见 `LICENSE`。

移植基于本地上游提交 `f540317d4bf5ef640393a52bc36b2282761c0a61`。

保留 Win32 / Koffi 输入、窗口识别和 DPI 坐标处理。`windows.ts` 仅保留原生层需要的接口、键位表和 PNG 编码；增加 Unicode 输入和鼠标位置的目标窗口校验。gpt-claw 不使用这里的 GDI 截图入口和剪贴板功能，截图由 MiniPet 本地 Qt 界面提供。Cordis、DeepSeek Harness、Electron 悬浮球和模型循环没有移植。

授权、取消、并发限制及截图有效性由 `tools/computer.ts` 和 `src/services/screen-share.ts` 负责。
