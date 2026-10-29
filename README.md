# mylocal AI 코딩 에이전트 플러그인

MyLocal의 `mylocal` CLI용 AI 코딩 에이전트 스킬입니다. 에이전트가 MyLocal의 활동 로그를 분석하고, 문제를 진단하고, 지금 열린 개발 서버와 정리 판단 근거를 보고, 일정·규칙·정리 설정을 바꿀 수 있게 합니다.

서버를 정리·유지·연기하는 것은 에이전트가 하지 않습니다. 그 결정은 사용자가 MyLocal 앱에서 합니다.

## 설치

### Claude Code

```bash
# 마켓플레이스 등록 (최초 1회)
claude plugin marketplace add my-locals/mylocal-plugin

# 플러그인 설치
claude plugin install mylocal@mylocal
```

로컬 개발:

```bash
git clone https://github.com/my-locals/mylocal-plugin.git
claude --plugin-dir ./mylocal-plugin
```

### OpenAI Codex CLI

```bash
codex plugin marketplace add my-locals/mylocal-plugin
codex plugin install mylocal
```

### Google Antigravity CLI

```bash
agy plugin install https://github.com/my-locals/mylocal-plugin
```

## 사전 요구사항

Homebrew로 MyLocal을 설치하면 앱 안의 `mylocal` CLI가 함께 연결됩니다.

```bash
brew tap my-locals/mylocal
brew trust --tap my-locals/mylocal
brew install --cask mylocal
mylocal schema > /dev/null && echo ok
```

DMG로 설치했다면 앱의 일반 > 정보에서 안내하는 명령으로 CLI를 `~/.local/bin`에 연결합니다.

## 포함 내용

| 에이전트 | 파일 | 범위 |
|---|---|---|
| Claude Code | `skills/mylocal/SKILL.md` | `/mylocal` 스킬: MyLocal 활동 로그·진단·일정·규칙 관련 요청에 자동 트리거 |
| Codex CLI | `skills/mylocal/SKILL.md` | `@mylocal` 스킬 |
| Antigravity CLI | `skills/mylocal/SKILL.md` | 플러그인 스킬 |

## 업데이트

```bash
claude plugin update mylocal        # Claude Code
codex plugin upgrade mylocal        # Codex CLI
agy plugin install https://github.com/my-locals/mylocal-plugin   # Antigravity CLI
```

## 제거

```bash
claude plugin uninstall mylocal     # Claude Code
codex plugin uninstall mylocal      # Codex CLI
agy plugin uninstall mylocal        # Antigravity CLI
```

## 라이선스

Apache 2.0. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
