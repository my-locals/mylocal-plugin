# CLAUDE.md

이 파일은 Claude Code (claude.ai/code)가 이 저장소에서 작업할 때 참고하는 가이드입니다.

## 프로젝트 개요

MyLocal의 `mylocal` CLI용 AI 코딩 에이전트 플러그인입니다. MyLocal은 업무 외 시간에 열린 개발 서버를 찾아 정리하는 macOS 메뉴바 앱이고, 이 플러그인은 Claude Code(`/mylocal`)·Codex CLI(`@mylocal`)·Antigravity CLI 스킬로 CLI 사용법을 알려 줍니다. 에이전트는 이 스킬로 활동 로그 분석, 진단, 일정·규칙·정리 설정 변경을 합니다.

코드 프로젝트가 **아닙니다**. 빌드·테스트할 소스가 없고, 선언적 설정 파일과 스킬 마크다운으로만 이루어집니다.

## 저장소 구조

- `.claude-plugin/plugin.json`: Claude Code 플러그인 메타데이터
- `.claude-plugin/marketplace.json`: Claude Code 마켓플레이스 등록 설정
- `.codex-plugin/plugin.json`: Codex CLI 플러그인 메타데이터
- `gemini-extension.json`: Antigravity CLI(`agy`)·Gemini CLI 공용 메타데이터
- `skills/mylocal/SKILL.md`: 세 에이전트가 함께 쓰는 스킬. **원본은 `../mylocal-app/skills/mylocal/SKILL.md`**이고, 이 파일은 그 사본입니다(아래 "스킬 편집").
- `README.md`: 설치·업데이트·제거 안내
- `scripts/bump-version.sh`: 메타데이터 파일 4개의 `version`을 한 번에 바꿉니다. 사용법: `scripts/bump-version.sh 0.2.0`

## 개발

로컬 실행:

```bash
claude --plugin-dir ./mylocal-plugin
```

`my-locals/mylocal-plugin` GitHub 저장소에 push하면 배포됩니다. 버전은 메타데이터 파일을 하나씩 고치지 말고 `scripts/bump-version.sh <version>`으로 올립니다.

## 스킬 편집

`skills/mylocal/SKILL.md`는 사본입니다. **원본(`../mylocal-app/skills/mylocal/SKILL.md`)을 먼저 고친 뒤 복사**합니다.

```bash
cp ../mylocal-app/skills/mylocal/SKILL.md skills/mylocal/SKILL.md
```

이 저장소에서 본문을 직접 고치지 않습니다. 다음 동기화 때 덮어써집니다. 원본은 mylocal-app의 CLI 테스트가 스킬 속 `mylocal …` 명령이 실제로 파싱되는지 검사하므로, 원본 쪽에서 고쳐야 그 검사를 거칩니다. 명령·옵션·설정 키의 전체 목록은 `mylocal schema` 출력이 기준입니다.

## 관련 저장소

- `../mylocal-app/`: MyLocal 원본(Rust·Tauri, 비공개). 스킬 원본 `skills/mylocal/SKILL.md`, CLI `crates/mylocal-cli`(`mylocal schema`의 원본), 설계 `docs/DESIGN.md` §6.4, ADR-0010
- `../homebrew-mylocal/`: Homebrew tap(`brew install --cask mylocal`)과 배포 파일(GitHub Releases). 스킬의 사전 요구사항인 CLI 설치가 이 cask로 됩니다
