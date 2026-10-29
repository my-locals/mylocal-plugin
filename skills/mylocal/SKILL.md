---
name: mylocal
description: mylocal CLI로 MyLocal(업무 외 시간에 열린 개발 서버를 정리하는 macOS 메뉴바 앱)을 조회·진단하고 설정을 바꾼다. 사용자가 MyLocal의 활동 로그를 보거나 분석해 달라고 할 때(어젯밤·지난주에 무엇이 정리됐는지, 왜 정리되지 않았는지), MyLocal이나 데몬(mylocald)의 문제를 진단할 때(정리가 안 됨, 데몬이 안 뜸, 설정 오류), 지금 열린·외부에 노출된 개발 서버와 그것이 정리되거나 유지되는 이유를 확인할 때, MyLocal의 일정(업무 시간, 휴일, 경고, 연기), 규칙(유지·정리 규칙 추가·삭제·순서), 정리 옵션(실제 정리 켜기, 정리 범위, 기본 동작)을 바꿀 때 사용한다.
---

# MyLocal CLI

MyLocal은 업무 시간이 끝나면 열려 있는 개발 서버(node, java, docker 컨테이너 등)를 찾아 정리하는 macOS 메뉴바 앱이다. 실제 정리는 사용자 권한으로 도는 데몬 `mylocald`가 하고, `mylocal` CLI는 데몬과 설정 파일을 읽고 설정만 바꾼다.

## 설치

앱 번들에 CLI가 들어 있다. Homebrew로 설치하면 함께 연결된다.

```bash
brew tap my-locals/mylocal
brew install --cask mylocal
```

DMG로 설치해 PATH에 없으면 링크한다(관리자 권한이 필요 없는 `~/.local/bin`).

```bash
mkdir -p ~/.local/bin
ln -s /Applications/MyLocal.app/Contents/MacOS/mylocal ~/.local/bin/mylocal
```

개발 빌드는 레포에서 `cargo build -p mylocal-cli`로 만든 `target/debug/mylocal`을 쓴다.

## 먼저 `mylocal schema`

```bash
mylocal schema
```

모든 명령의 인자·옵션·기본값·선택지, `--json` 출력 모양, 설정 키(형식·기본값·범위·`--yes` 필요 여부), 규칙 조건 필드, 판단 단계와 사유, 활동 로그 이벤트, 종료 코드를 JSON 하나로 준다. 파서와 설정 표에서 바로 만들어지므로 이 문서보다 정확하다. 플래그가 헷갈리면 추측하지 말고 schema를 본다. 이 문서는 무엇을 해도 되는지와 작업 순서만 다룬다.

## 할 수 있는 것과 없는 것

**할 수 있다:** 열린 서버와 판단 근거, 활동 로그, 진단, 설정·규칙·일정 조회. 설정 파일 변경(일정, 규칙, `[enforce]` 옵션). 모든 변경의 `--check` 시뮬레이션.

**하지 않는다:**

- 서버 멈추기, "오늘은 유지", 연기, "지금 정리"는 CLI에 없다. 사용자의 결정이므로 **MyLocal 앱(메뉴바 팝오버, 메인 창의 프로세스 화면, 경고 창)에서 하도록 안내한다.**
- `kill`, `pkill`, `launchctl bootout`, `docker stop` 등으로 서버를 직접 멈추지 않는다. MyLocal의 보호(시스템 프로세스, Docker 런타임, 다른 사용자의 프로세스, 같은 감독자 아래 유지할 서버)와 재확인을 모두 건너뛴다.
- 보호를 풀 수 없다. 보호 목록은 코드에 고정이라 어떤 설정으로도 바뀌지 않는다. "이 시스템 프로세스도 정리해 줘" 같은 요청은 할 수 없다고 답한다.
- MyLocal은 아무것도 다시 실행하지 않는다. 정리된 서버를 되살리는 기능은 없다. 계속 켜 둘 서버는 `keep` 규칙으로 정한다.
- **실제 정리를 켜는 것**(`enforce.dry_run`을 `false`로)은 사용자가 분명히 원할 때만 한다. 이때만 `--yes`를 붙인다. 기본은 dry run(기록만)이다.

## 출력과 종료 코드

`--json`을 붙이면 stdout에 그 명령의 JSON 객체만 쓰고(감싸는 봉투 없음), 경고는 stderr에 쓴다. 프로그램으로 읽을 때는 항상 `--json`을 쓴다. 읽기 명령의 JSON에는 `"source"`가 있다. `daemon`이면 실행 중인 데몬이 답했고, `local`이면 데몬 없이 CLI가 직접 수집하고 파일을 읽어 답했다. 실패하면 `{"error": {"kind", "message", "exit"}}`를 쓴다.

| 종료 | kind | 다음 행동 |
|---|---|---|
| 0 | | 성공 |
| 1 | `error` | 메시지를 읽는다. 같은 명령을 그대로 다시 해도 대개 소용없다 (없는 Target 등) |
| 2 | 사용법 | 인자가 틀렸다. `mylocal schema`의 `commands`를 본다 |
| 3 | `daemon_not_running` | 데몬이 없다. 사용자에게 MyLocal 앱을 열도록 안내한다. 읽기 명령은 알아서 `local`로 답한다 |
| 4 | `stale_revision` | 그 사이 설정 파일이 바뀌었다(앱이나 사용자가 고침). `config show --json`을 다시 읽고 변경을 다시 만들어 새 `--revision`으로 재시도한다 |
| 5 | `invalid_config` | 잘못된 값·패치. 아무것도 쓰지 않았다. 메시지대로 고친다. 그대로 재시도하지 않는다 |
| 6 | `confirmation_required` | 실제 정리를 켜는 변경. 사용자에게 묻고, 동의하면 `--yes`로 다시 한다 |

출력의 명령줄은 비밀값이 `••••`로 가려져 있다. `mylocal ls --dump-snapshot FILE --raw`는 가리지 않은 원문을 쓰므로 사용자가 직접 원할 때만 쓴다. 기본(`--raw` 없이)도 경로·사용자 이름이 들어 있어 공유 전에 사용자에게 확인한다.

## 설정을 바꾸는 순서

CLI는 설정 파일(`~/Library/Application Support/MyLocal/config.toml`)을 직접 고친다. 데몬과 같은 검증과 `revision` 잠금을 거치고, 주석과 나머지 내용은 그대로 둔다. 데몬은 다음 요청 때 바뀐 파일을 읽고, 활동 로그에 `config_changed`(`source: "file"`)로 남긴다.

1. 지금 설정을 읽는다. `revision`을 적어 두고 `error`가 비었는지 본다.

   ```bash
   mylocal config show --json
   ```

2. 바꿀 내용을 사용자에게 제안한다.
3. `--check`로 시뮬레이션한다. `changes`(바뀌는 설정), `targets`(판단이 바뀌는 서버, 이전 → 이후), `rule_counts`, `schedule`(정리 시각 전후)을 사용자에게 보여 준다.

   ```bash
   mylocal rules add --name "데모 유지" --action keep --match cwd_prefix=~/code/demo --at 1 --revision fa64301e12f9f7c5 --check --json
   ```

4. 같은 명령을 `--check` 없이 실행한다. 종료 코드 4면 1번부터 다시 한다.
5. 결과의 `daemon.applied`가 `true`인지 확인한다(`daemon.running`이 `false`면 데몬이 시작할 때 읽는다). 판단이 기대대로인지 본다.

   ```bash
   mylocal ls --explain --json
   mylocal rules list --json
   ```

여러 값을 한 번에 바꿀 때는 `config apply --patch`에 JSON 패치를 준다. 모양은 schema의 `patch_format`이다. `rules`는 순서 있는 전체 목록이라 `config show --json`의 `config.rules`에서 시작한다.

```bash
mylocal config apply --patch patch.json --revision fa64301e12f9f7c5 --check --json
```

## 작업별 순서

### 지난주에 무엇이 정리됐나

```bash
mylocal log --since 7d --kind cleanup --kind stop --kind would_stop --json
```

`would_stop`은 dry run이라 기록만 한 것, `stop`은 실제로 멈춘 것이다(`manual: true`는 사용자가 앱에서 직접 정리). `cleanup`은 정리 한 번의 요약이다. `warn`, `snooze`, `appeared`, `restarted`, `sleep`, `wake`로 그날의 흐름을 따라간다. 더 이전은 마지막 항목의 `time`을 `--before`로 넘긴다. 파일로 달라고 하면 내보낸다(덮어쓰지 않음, 0600).

```bash
mylocal log export --since 30d --format csv -o activity.csv
```

### 이 서버는 왜 정리됐나 / 왜 안 정리되나

```bash
mylocal ls --explain --json
mylocal show process:30491:1793270230713245 --json
```

`ls --explain`의 `decision`(또는 `show`)에서 `action`, `step`, `reason`을 읽는다. 단계별 뜻과 사유 종류는 schema의 `concepts.steps`, `concepts.reasons`에 있다. 자주 보는 것은 이렇다.

- `out_of_scope`(3단계): 외부에 노출되지 않은 서버다. `enforce.target = "external_only"`이면 정리하지 않는다.
- `rule`(4단계): 그 이름의 규칙이 정했다.
- `app_protection`(5단계): IDE 같은 앱 안의 프로세스다. `bundle_id`나 `.app`까지 쓴 `exe_prefix` 규칙만 적용된다.
- `stop_unit_shared`(7단계): 같은 감독자(nodemon 등) 아래 유지할 서버가 있어 함께 멈출 수 없다.
- `pending`: 정리 시각 이후에 뜬 서버라 유예·경고를 기다린다.

이미 멈춘 서버는 목록에 없으니 `log`의 `stop` 항목의 `targets[].reason`을 본다.

### 프로젝트 폴더의 서버는 늘 유지

```bash
mylocal config show --json
mylocal rules add --name "demo 유지" --action keep --match cwd_prefix=~/code/acme/demo --at 1 --check --json
mylocal rules add --name "demo 유지" --action keep --match cwd_prefix=~/code/acme/demo --at 1 --revision fa64301e12f9f7c5 --json
```

처음 일치하는 규칙 하나만 적용되므로 `keep` 예외는 넓은 `stop` 규칙보다 앞(`--at 1`)에 둔다. `cwd_prefix`는 폴더 단위 비교이고 `~`는 홈이며, compose 컨테이너의 프로젝트 폴더에도 맞는다. 조건 필드와 정규식 규칙(전체 일치·부분 일치)은 schema의 `rule_fields`를 본다. 규칙 수정·이동·삭제는 `rules edit`, `rules move`, `rules remove`다.

```bash
mylocal rules move "demo 유지" --to 1 --json
mylocal rules edit 2 --match port=3000-3999 --json
mylocal rules remove "demo 유지" --json
```

### 휴일 추가

```bash
mylocal schedule holiday add 2026-12-25 2027-01-01 --check --json
mylocal schedule holiday add 2026-12-25 2027-01-01 --json
mylocal schedule show --json
```

휴일은 하루 종일 Off-hours다. 전날 밤부터 이어지는 업무 시간은 그 전날의 것이라 그대로다.

### 업무 시간 바꾸기

```bash
mylocal schedule show --json
mylocal schedule hours set mon-thu=09:00-19:00 fri=09:00-16:00 --check --json
mylocal schedule hours set mon-thu=09:00-19:00 fri=09:00-16:00 --json
```

인자 하나가 업무 시간 구간 하나이고 전체를 바꾼다. 각 구간의 끝이 정리 시각이다. `--check`의 `schedule.before`·`after`로 다가오는 정리 시각이 어떻게 바뀌는지 보여 준다. 경고·연기는 `config set`으로 바꾼다(경고는 가장 짧은 연기보다 짧아야 한다).

```bash
mylocal config set schedule.warn_before_min 10 --check --json
mylocal config set schedule.snooze_options_min 15,30,60 --json
mylocal config set schedule.timezone Asia/Seoul --json
```

### 실제 정리 켜기 (사용자의 분명한 동의가 있을 때만)

먼저 `--check`로 지금 켜면 무엇이 멈출지 보여 주고, 사용자가 켜겠다고 하면 `--yes`를 붙인다. 앱의 일반 탭 "실제로 정리"와 같다.

```bash
mylocal config set enforce.dry_run false --check --json
mylocal config set enforce.dry_run false --yes --json
```

결과의 `daemon.forced_dry_run`이 `true`면 데몬이 `--dry-run`으로 실행돼 설정과 관계없이 기록만 한다. 다시 끄려면 `mylocal config set enforce.dry_run true`(확인 필요 없음).

### "아무것도 정리되지 않는다" / "데몬이 안 뜬다"

```bash
mylocal diag --json
mylocal status --json
mylocal config show --json
mylocal schedule show --json
mylocal log --since 24h --json
```

차례로 본다.

- `diag`가 종료 코드 3이면 데몬이 없다. 사용자에게 MyLocal 앱을 열고, 첫 실행 안내에서 "백그라운드 실행"을 허용하도록 안내한다. 개발 빌드는 `mylocal agent install`이다.
- `config show`의 `error`가 있으면 설정 파일이 거부돼 데몬이 마지막 유효 설정을 쓰고 있다. 로그에도 `config_error`가 있다.
- `status`의 `dry_run`이 `true`면 기록만 한다. 로그에 `stop` 대신 `would_stop`이 쌓인다.
- `schedule show`의 `phase`가 지금 업무 시간인지, `upcoming`의 정리 시각이 기대와 맞는지 본다.
- `ls --explain`에서 그 서버의 사유를 본다(위 "왜 안 정리되나").
- `diag`의 `collection.docker`가 실패면 컨테이너를 매핑하지 못해 런타임 포트가 보호된다. `unmapped`에 그 포트가 나온다. `sleep_blockers`는 잠자기를 막는 프로세스로, 표시만 한다.

## 그 밖

- 앱이 열려 있어도 CLI로 설정을 바꿀 수 있다. 앱 화면은 다시 읽을 때 바뀐 내용을 보여 주고, 그 사이 앱이 저장하려 하면 revision이 달라 다시 읽는다.
- 규칙은 이름 또는 1부터 세는 위치로 가리킨다. 같은 이름이 둘이면 위치를 쓴다.
- 시각 인자(`--since`, `--before`)는 RFC 3339, `YYYY-MM-DD`(시스템 시간대 자정), `30m`·`24h`·`7d`·`2w`다.
