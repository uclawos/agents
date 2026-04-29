# Goose Adapter

> UCP v0.1 reference adapter for [Goose](https://block.github.io/goose/) (`aaif-goose/goose`)
> Maintained by u-claw-os community  ·  License: MIT (adapter) · Apache-2.0 (Goose)

## 双重身份

Goose 在 U-ClawOS 里既是 **L2 Orchestrator**，也是 **L1 worker Agent**：

| 场景 | 角色 |
|---|---|
| 用户在虾盘管家主对话框输入任务 | Orchestrator —— 派单给其他 Agent |
| 第三方 Orchestrator 想"调一个推理 Agent" | Worker —— 被 dispatch 进来 |

## 关键技术决策

- **协议**：ACP (Zed/Goose) over WebSocket，不是 MCP
- **端口**：动态（默认从 18789 起）
- **传输**：直连 WebView，Tauri 后端不做反代（避开 stdio 大输出丢包，见 docs/12）
- **环境变量**：`GOOSE_PROVIDER=openai` + `OPENAI_HOST=https://api.u-claw.org`

## 在虾盘管家里的特殊位置

Goose 的二进制已经预置在 `src-tauri/binaries/goose-package/goose.exe`，**不走 install 流程**。
虾盘管家启动时直接 `spawn` 它（见 `src-tauri/src/sidecar.rs`）。

这个 adapter 主要给：

- 第三方 Orchestrator 想用 Goose 当 worker
- 用户在自己的工作流里需要"独立 spawn 一个 Goose"

## 派单偏好

Goose 是"通用兜底" —— 当其他 Agent 都不匹配 capabilities 时，派给 Goose。

## 离线安装

Goose 单二进制 219MB（解压后），ZIP 66MB。
离线 bundle 见 `install.offline.bundle_url`。
