# U-ClawOS Reference Agents

> UCP v0.1 reference adapter 集合。每个子目录 = 一个 AI Agent 的"插件包"。
> 一旦稳定，会被独立推到 `github.com/u-claw-os/agents`，每个 Agent 一个独立仓库或子目录。

## 已收录

| Agent | 角色 | 协议 | 默认端口 | 装机状态 |
|---|---|---|---|---|
| [goose](./goose/) | Orchestrator + 通用 worker | acp / WebSocket | 18789 | ✅ v0.1 真装通（binary）|
| [openclaw](./openclaw/) | 全能型 worker | http_mcp | 18788 / 18789 | ✅ v0.1 真装通（probe_install 实测 6/6 步）|
| [hermes](./hermes/) | 推理型 + IM 网关 | http_mcp | 8642 | 🔴 装机失败（pip 包名错，0.1.1 修，详见 `docs/17`）|

## 占位 manifest（Phase 5 真接）

manifest 已就位，schema 校验通过；装机命令 `exit 1` fail-fast 自报"Phase 5 接入"：

| Agent | 协议 | 备注 |
|---|---|---|
| [claude-code](./claude-code/) | stdio_mcp | Anthropic 官方 CLI，需 stdio shim |
| [codex](./codex/) | http_api | OpenAI Codex CLI |
| [opencode](./opencode/) | stdio_mcp | sst/opencode |

## Phase 5+ 候选

| Agent | 协议 | 备注 |
|---|---|---|
| cursor-cli | stdio_mcp | Cursor 命令行 |
| aider | cli_oneshot | Aider 老牌 |

## 怎么贡献新 Agent

1. fork 仓库
2. 在 `agents/<your-agent-id>/` 建子目录
3. 写 `agent.toml`（参考 [`docs/14-UCP协议规范.md`](../docs/14-UCP协议规范.md) §4）
4. 跑 `cargo test -p u-claw-os-sdk`，确保 schema 校验通过
5. 写一份 `README.md` 说明能力边界、安装/卸载边界
6. 提 PR

## 测试

每个 adapter 应当通过：

- ✅ `agent.toml` 能被 `parse_agent_manifest` 解析
- ✅ schema 校验通过
- ✅ `install.{ps1|sh}` 在干净 VM 上能装通
- ✅ 装完 `health.checks` 全过
- ✅ `uninstall.{ps1|sh}` 能干净卸载

## 命名约定

- `meta.id` 必须 `^[a-z][a-z0-9-]*$`
- 显示名（display）可含中文/符号
- 子目录名 = `meta.id`
