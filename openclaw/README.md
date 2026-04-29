# OpenClaw Adapter

> UCP v0.1 reference adapter for [OpenClaw](https://openclaw.ai)
> Maintained by uclawos community  ·  License: MIT

## 这是什么

把 OpenClaw 接入 U-ClawOS 平台的"插件包"。包含：

- `agent.toml` — UCP manifest（核心）
- `install.ps1` / `install.sh` — 复用自 [`dongsheng123132/u-claw/install/`](https://github.com/dongsheng123132/u-claw/tree/main/install)
- `uninstall.ps1` / `uninstall.sh` — 反向操作

## 装完用户得到什么

- 一个跑在 `127.0.0.1:18789` 的 OpenClaw gateway
- admin API 在 `127.0.0.1:18788/mcp`，可被 Goose Orchestrator 调用
- 配置在 `~/.uclaw/data/.openclaw/openclaw.json`，热重载

## 能干什么

- 写代码、改文件
- 跑 shell 命令
- 浏览网页（内置浏览器 skill）
- 文件 IO

## 派单偏好

OpenClaw 是 U-ClawOS 的"全能员工"。Orchestrator 派单算法把它当默认选择 —— 除非任务明确需要：

- 长上下文 → claude-code (200k context)
- 推理密集 → hermes
- API 调用密集 → codex

## 与 Goose 的关系

OpenClaw 装好后会被 Goose（L2 Orchestrator）通过 MCP 协议调用：

```
Goose ─[MCP]─> OpenClaw gateway (18788) ─[内部]─> 各 OpenClaw skill
```

详见 [`docs/14-UCP协议规范.md`](../../docs/14-UCP协议规范.md) §3.2。
