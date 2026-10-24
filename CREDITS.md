# 出处与许可

本仓库**不包含任何原创动画**。三份内容都是别人的，按各自的 MIT 许可原样再分发。

## 1. 第一幕 · dsh-startup-screen

- 作者：**沈宏宏**（[@6shenhonghong9](https://github.com/6shenhonghong9)）
- 上游：https://github.com/6shenhonghong9/dsh-startup-screen
- 版本：1.1.1
- 许可：MIT（`vendor/dsh-startup-screen/LICENSE`）
- 我们改了什么：**没有改代码**，只把它原样放进组合里

## 2. 第二幕 · boot-splash

- 作者：**[GA17-LHY](https://github.com/GA17-LHY)**
- 上游：https://github.com/GA17-LHY/dsh-boot-splash
- 版本：0.1.0
- 许可：MIT（`vendor/boot-splash/LICENSE`）
- 我们改了什么：在 `panel.js` 末尾加了 20 行"等第一幕揭幕再开始"的闸门，
  其余一字未动。diff 见 `patches/`

## 3. 素材 · 1.mp4 / 2.mp4 / 3.mp4

- 来源：**[lxj5820/dsh-boot-animation](https://github.com/lxj5820/dsh-boot-animation)**
- 原始版权行：`Copyright (c) 2026 dsh-boot-animation contributors`
- 许可：MIT，完整文本随素材放在 `vendor/boot-splash/assets/videos/LICENSE-dsh-boot-animation.txt`
- 说明：这三段是 boot-splash 上游自带的素材，我们跟着上游一起再分发，没有额外改动。
  上游的 CREDITS 里记录过这几段的 C2PA 内容凭证（生成式模型产出），这里照录，不额外声称
  它们是手作动画。

## 如果你要用这里的做法

用了别人的，就说出来。上面三位都该被 @ 到。
