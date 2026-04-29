# Hermes Adapter

> UCP v0.1 reference adapter for [hermes-agent](https://github.com/NousResearch/hermes-agent)
> 中文社区版：[u-hermes](https://github.com/dongsheng123132/u-hermes)
> Maintained by uclawos community  ·  License: MIT

## 角色定位

Hermes 在 U-ClawOS 里是**双重身份**：

1. **L3 IM 网关** —— 接微信 / 飞书 / 企业微信 / Telegram，把消息桥到平台内部
2. **L1 推理型 Agent** —— 偏推理强度高的任务（逻辑、推算、规划）

## 包含什么

- `agent.toml` — UCP manifest
- `install.{ps1|sh}` — pip 虚拟环境装机
- `uninstall.{ps1|sh}` — 清 venv + 配置

## 装完得到什么

- 一个跑在 `127.0.0.1:8642` 的 Hermes gateway
- venv 在 `~/.uclaw/agents/hermes/venv/`
- 配置 `~/.uclaw/agents/hermes/config/hermes.yaml`

## IM 配置

装完后默认不接 IM。要接，编辑 `config/hermes.yaml` 加 platform：

```yaml
platforms:
  feishu:
    app_id: "cli_..."
    app_secret: "..."
  wecom:
    corp_id: "..."
    secret: "..."
```

详见 [`docs/16-Phase3-IM集成.md`](../../docs/16-Phase3-IM集成.md)（待写）。

## 派单偏好

适合：

- 复杂推理任务（多步逻辑）
- 需要 IM 桥接的任务（"发飞书通知给 #开发组"）
- 中文长文本（DeepSeek 系列长上下文）

不适合：

- 浏览器操作 → 用 OpenClaw
- IDE 内代码改动 → 用 Claude Code
