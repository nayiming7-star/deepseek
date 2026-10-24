# dsh-boot-two-act · 两幕开机动画

把两个**第三方** DSH 插件打包成一个可安装的组合，并在中间加一处衔接补丁，
让它们从"各演各的"变成**连续的两幕**。

```
黑幕 → 第一幕  dsh-startup-screen   五步访问授权（真声台词 + 界面音效）
     → 揭幕     内容化进底色 200ms → 底色淡出 420ms
     → 第二幕  boot-splash         全屏短片（三段轮播，可带声）
     → 溶解     片尾交叉溶解进聊天窗口
```

> **这不是我的作品。** 两个插件分别属于 [沈宏宏](https://github.com/6shenhonghong9) 和
> [GA17-LHY](https://github.com/GA17-LHY)。本仓库只是打包 + 加了一处 20 行的衔接补丁，
> 版权与原许可见 [CREDITS.md](CREDITS.md)，每个 `vendor/` 目录里都保留着上游的 LICENSE。

## 为什么需要打包

单独装这两个插件，它们**都会在页面加载时立刻往屏幕上糊一层**：谁也不认识谁，
谁后注入谁盖住谁，另一个在底下白白播完。等上面的演完淡出，底下那个早就放完了 ——
所谓"两幕"根本不存在。

衔接补丁解决的就是这一件事：让第二幕**等**第一幕揭幕再上场。

## 安装

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

装完**完全退出 DeepSeek Harness（窗口 + 托盘）再打开**。

脚本做的事（全部可回滚）：

1. 把 `vendor/` 下两个插件复制到 `%USERPROFILE%\.dsh\plugins\`
2. 在 desktop profile 的 `node_modules` 下建两个目录联接
3. 往 profile 的 `cordis.patch.yml` 追加两行 `insert`（已存在就跳过，先自动备份）
4. 打印下一步

只想看它要做什么、不动手：`powershell -ExecutionPolicy Bypass -File install.ps1 -CheckOnly`

## 卸载

```powershell
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

摘掉两行配置和两个联接，保留 `plugins/` 下的目录（想彻底删就自己删）。

## 唯一的改动

`vendor/boot-splash/panel.js` 的末尾，原本是：

```js
build()
bind()
setHint('正在准备…')
start()
```

改成先等第一幕收场：

```js
function deferToStartup(go) {
  var t0 = Date.now(), seen = false
  var timer = globalThis.setInterval(function () {
    var el = document.getElementById('dsh-startup-root')
    if (el) {
      seen = true
      var leaving = el.classList &&
        (el.classList.contains('dsu-handoff') || el.classList.contains('dsu-gone'))
      if (leaving) { stop(); return }
      return
    }
    if (seen) { stop(); return }             // 它演完被移除了
    if (Date.now() - t0 > 4000) { stop() }   // 没装第一幕，别干等
  }, 100)
  function stop() { globalThis.clearInterval(timer); go() }
}
```

判断只用 `dsh-startup-screen` 公开的两个 class（`dsu-handoff` / `dsu-gone`）和根元素 id，
不猜别的。4 秒内没见到根元素就按"没装第一幕"处理，照常开始 —— 不会把人卡在黑屏上。

完整 diff 在 [`patches/boot-splash-wait-for-startup.diff`](patches/boot-splash-wait-for-startup.diff)。

## 配置

| 文件 | 管什么 |
|---|---|
| `~/.dsh/dsh-startup.json` | 第一幕：身份名称、配色、语速、显示模式、是否要求点击 |
| `~/.dsh/boot-splash.json` | 第二幕：`sound`（`gesture` / `auto` / `mute`）、`volume`、`fadeMs`、`enterMode`、`dir`、`clips` |

两个文件都不存在也能跑（用默认值）。

## 目录

```
install.ps1 / uninstall.ps1     安装 / 卸载
patches/                        boot-splash 的衔接补丁（diff）
vendor/dsh-startup-screen/      第一幕（MIT · 沈宏宏）
vendor/boot-splash/             第二幕（MIT · GA17-LHY，含其自带素材）
CREDITS.md                      出处与许可
```

## 许可

本仓库的打包脚本与衔接补丁：MIT，见 [LICENSE](LICENSE)。
`vendor/` 下两份插件各自保留上游 LICENSE，逐条列在 [CREDITS.md](CREDITS.md)。
