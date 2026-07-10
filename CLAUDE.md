## Agent skills

### Issue tracker

Issues are tracked as GitHub issues in `kihyun1998/flutter_password_input`, managed via the `gh` CLI. External PRs are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical triage roles map 1:1 to identically-named labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout — one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

**아직 둘 다 없다.** 용어가 실제로 충돌하거나 결정이 실제로 내려질 때 lazily 만든다 — 미리 채우지 않는다. 다만 아래 Step 7 은 "없으니 스킵" 이 아니라 **"이번 변경이 용어/결정을 건드렸는가" 를 매번 묻는다**는 뜻이다.

---

## 작업 flow

*Substantive 변경*(버그 수정·기능 추가·동작 변경)이면 이 8단계로 짠다. 단계를 *생략*하려면 (건너뛰는 게 아니라) *왜 이 변경엔 해당 없는지를 명시*한다 — 조용한 스킵 금지.

괄호 안 실증은 **이 repo 에서 실제로 확인된 것만** 적는다. 다른 repo 의 사고 기록을 옮겨 오지 마라 — 틀린 근거가 리포에 남으면 다음 사람이 그걸 믿고 판단한다.

### 1. 이슈 먼저 — 실측 숫자·기각한 대안·부정 결과

측정한 숫자를 이슈에 박고, **기각한 대안과 그 이유**를 함께 적는다. 안 그러면 같은 대안이 다시 제안된다.

- **이슈 본문에 쓴 근거도 실측 대상이다.** 착수 전에 본문의 주장을 한 번 더 검증하고, 틀렸으면 본문부터 정정한 뒤 코드를 만진다.
- **삭제에는 도달 불가의 *적극적 증명*을 요구한다.** 커버리지 부재는 증거가 아니다. "테스트가 안 밟더라" 는 "도달 불가" 가 아니다 — 도달 가능한데 안 밟았을 뿐일 수 있고, 그렇다면 지운 순간 처리되지 않은 에러가 된다.
- **부정 결과·범위 밖 발견도 재현과 함께 남긴다.** 작업 중 발견했지만 원인이 구조적이라 그 자리에서 고칠 수 없는 것은, 재현 절차·수치·기각한 후보를 담아 **별도 이슈로** 연다.

### 2. 추측 금지 — spike 로 실측한다

**코드를 *읽어서* 얻은 확신은 확신이 아니다.**

- **버리는 프로브 테스트** (`test/_probe_test.dart`, 확인 후 삭제). 실제 rect·좌표·호출 순서·notifier 수명을 `debugPrint` 로 뽑는다. 프로브는 버리되 **숫자는 이슈/PR 에 남긴다.**
- **Flutter SDK 및 의존 패키지 소스를 직접 `grep`/`sed`.** 기억·요약 금지. 이 패키지는 외부 표면이 넓다 — `just_tooltip` 과 `flutter_ime` 의 **실제 소스**가 진실의 출처지, pub.dev 문서나 CHANGELOG 가 아니다. 실증: `just_tooltip` 0.3.0 → 0.4.0 은 두 번의 연속된 breaking 마이그레이션이었다(e143183, 74637ef). API 표면 변화는 매번 소스에서 확인한다.
- **프레임워크의 debug 동작을 프로덕션 동작으로 착각하지 마라.** `assert` 안에서만 던지는 에러는 **release 에서 발동하지 않는다.** debug 크래시보다 release 의 조용한 오작동이 나쁘다.
- **테스트 환경이 프로덕션과 다를 수 있다.** `flutter test` 와 debug 빌드는 widget creation tracking 으로 const 위젯 정규화를 막는다 — `identical(const SizedBox(), const SizedBox())` 는 test 에선 false, release 에선 true 다. 빌드 모드에 따라 참·거짓이 갈리는 명제를 테스트로 굳히지 마라.
- **외부 사실도 조회 대상이다.** pub.dev 상태는 `curl -s https://pub.dev/api/packages/flutter_password_input`.
- **"확인했다" 가 정말 확인인지 본다.** 어느 쪽이든 빈 결과가 나오는 검사는 검사가 아니다. grep 이 0 건이면 *패턴이 틀린 것*과 *대상이 없는 것*을 먼저 갈라라.

**"확인 못 했다" ≠ "없다".** 미확인 사실은 갭이다. 이슈로 surfacing 하거나 사용자에게 묻는다 — 조용히 설계 가정으로 승격시키지 마라.

### 3. 설계 판단은 코드 전에 사용자와 확정

**TDD 는 "무엇이 옳은가" 를 답해주지 않는다.** 기대값을 발명하기 전에 정책을 못 박는다. *결정 유형으로 라우팅*한다.

- **순수 메커니즘**(좌표계·훅 선택·자료구조 — 소스로 도출 가능) → 직접 결정하고 **검증 결과만** 제시. 답이 코드에 있는 걸 묻는 건 일 떠넘기기다.
- **계약·정책**(테스트 seam, 폴백 동작, 공개 API 표면, 동작 변경 허용 여부) → **묻는다.** 실증: `flutter_ime` 를 `KeyboardInputMonitor` 뒤로 격리한 것(6622807)은 순수 리팩터가 아니라 **테스트 seam 을 어디에 그을지**의 계약 결정이었다. 이런 건 red 테스트를 쓰기 *전에* 정해진다.
- **`/grilling` 으로 설계 트리를 먼저 흔든다.** 특히 breaking change(`feat!:`)는 코드 전에 grilling 을 거친다 — 이 repo 의 `feat!` 커밋은 전부 공개 API 이름·의미를 바꿨다.

### 4. `/tdd` 로 RED→GREEN 수직 슬라이스

한 번에 하나 — 테스트 하나 → 최소 구현 → 반복. **이슈 하나가 작업 단위다.**

- **공개 seam 에서 관찰한다.** 위젯의 속성을 읽지 말고, 그 위젯이 만들어내는 관측 가능한 사실을 읽는다. `expect(find.byType(X).evaluate().single.widget as X, ...)` 로 내부 위젯의 필드를 단언하기 시작하면, 구현을 바꾸는 순간 **동작이 하나도 안 바뀌었는데 테스트가 무더기로 깨진다** — implementation-coupled 의 교과서적 증상이다.
- **RED 가 정말 RED 인지 본다.** 프레임워크가 이미 던지는 예외를 `throwsA(isA<FlutterError>())` 로 단언하면 **처음부터 초록불**이다. 우리 코드가 원인임을 지목하는 조건까지 요구해야 red 가 된다.
- **규칙을 어겼으면 되돌린다.** red 없이 두 개를 한 번에 넣었다면 두 번째를 되돌리고 red 부터 다시 한다. TDD 의 가치는 코드가 아니라 "이 테스트가 정말 실패하는가" 를 보는 순간에 있다.

### 5. 테스트 신뢰 게이트 — 두 질문은 다르다

- **구분력이 있는가.** 통과하는 테스트는 그 자체로 아무것도 증명하지 않는다. Dart 는 동일 인자의 `const` 값을 **같은 인스턴스로 정규화**하므로, `const a == const b` 는 `operator ==` 가 없어도 identity 로 통과한다. 동등성 테스트는 값을 런타임에 만들고 `expect(identical(a, b), isFalse)` 를 **먼저** 단언한다.
- **옳은 이유로 통과하는가.** 부수 조건까지 단언해 우연한 순서로 통과할 수 없게 만든다. tooltip 정렬 테스트는 "정렬이 맞다" 만이 아니라 **"툴팁이 실제로 떴다"** 를 먼저 확인해야 한다 — 안 뜨면 좌표 단언이 공허하게 통과한다.
- **커버리지는 "무엇을 안 봤는지" 를 알려주지, "본 것이 옳은지" 는 말해주지 않는다.** `copyWith` 의 `x ?? this.x` 는 각 필드를 *교체할 때만* 테스트하면 오른쪽 피연산자가 **한 번도 평가되지 않는다**. 인자 없는 `copyWith()` 가 원본과 동등해야 한다는 속성 하나로 전 필드를 덮는다.
- **dispose 는 테스트가 안 잡는다 — 명시적으로 단언한다.** 실증: `JustTooltipController` 를 dispose 하지 않아 `ChangeNotifier` 가 샜다(9f21d51, #5). 통과하던 위젯 테스트들은 누수를 전혀 보지 못했다. 컨트롤러·notifier·리스너를 만드는 코드는 수명 테스트를 함께 낸다.

### 6. `/code-review`

구현·테스트가 끝나고 릴리스 전에 돌린다. 지적은 고치거나, 안 고치면 *왜 안 고치는지*를 남긴다.

### 7. 정합성 스윕 — 동작을 기술하는 모든 표면

코드만 고치고 끝나는 변경은 없다. 아무도 안 보므로 **명시적으로 훑는다**.

- **`CHANGELOG.md`** — pub.dev 는 *발행 시점의* CHANGELOG 를 스냅샷으로 박는다. 이미 발행된 버전의 항목을 고치지 말고 새 버전을 연다.
- **`README.md`** — 공개 API 표면이 바뀌면 README 도 바뀐다. `feat!` 인데 README diff 가 비어 있으면 둘 중 하나가 틀렸다.
- **`pubspec.yaml` 의 의존 제약** — 실증: `just_tooltip` 은 두 릴리스 연속 breaking 이었다. 하한을 올렸으면 그 하한에서만 존재하는 API 를 쓰는지, `example/pubspec.lock` 이 같은 버전을 가리키는지 함께 본다.
- **`CONTEXT.md` 용어집 (아직 없음)** — 도메인 용어의 source of truth. 용어집이 개념을 덜 정의하면 코드가 그 빈칸을 임의로 채운다. 이 repo 의 후보: *Status* vs *Warning*(`PasswordFieldWarning` → `PasswordFieldStatus` 로 개명된 이력이 있다, de934a5), *active warning*, *checked*, *caps-lock monitor*. 이번 변경이 이 중 하나의 의미를 건드리면 그때 `CONTEXT.md` 를 연다.
- **`docs/adr/` (아직 없음)** — 결정이 뒤집히면 ADR 도 뒤집는다. 되돌리기 비싼 결정(테스트 seam, 공개 API 형태, 외부 패키지 선택)을 내렸으면 ADR 을 연다.
- **`.pubignore`** — **`.pubignore` 가 존재하면 pub 은 git 기반 파일 목록을 끈다. `.gitignore` 는 더 이상 적용되지 않는다.** 실증(2026-07-10 확인): `/coverage/` 가 `.gitignore` 에 있음에도 `flutter pub publish --dry-run` 아카이브에 `coverage/lcov.info` 가 실려 있었다 — `.pubignore` 가 `docs/`·`CLAUDE.md`·`build/` 만 나열했기 때문. CI 나 로컬이 새로 만드는 디렉터리는 **`.pubignore` 에 직접** 추가해야 한다. **pub.dev 아카이브는 한 번 올라가면 내릴 수 없다.**
- **낡은 근거 회수** — 연속 작업에서 앞선 이슈·PR 에 적은 근거가 뒤 작업에 의해 거짓이 된다.

### 8. 게이트 & 커밋 & 릴리스

CI(`.github/workflows/ci.yml`)가 push(main)·PR 에서 이 순서로 돌린다. Flutter 는 `3.41.9` 로 핀 고정 — 러너 기본값 드리프트 방지:

```
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

- **포맷 검사는 `pub get` 뒤여야 한다.** `dart format` 은 `.dart_tool/package_config.json` 에서 언어 버전을 읽는다. 패키지 설정이 없으면 포매터가 최신 언어 버전을 가정해 레포 전체를 재포맷한다. 로컬엔 `.dart_tool` 이 항상 있어 **절대 재현되지 않는** 실패다.
- **커버리지 게이트가 없다.** `flutter test` 는 `--coverage` 없이 돌고 바닥값 검사도 없다. 즉 **Step 5 의 판단을 CI 가 대신해 주지 않는다** — 커버리지 회귀는 사람이 본다. (게이트를 추가할 거라면 바닥은 100 이다. 여유를 두면 딱 그 여유만큼의 회귀를 허용하고, 실제 회귀는 임계값 근처에 앉는다.)
- **`analyze` 에 `--fatal-infos --fatal-warnings` 가 없다.** info·warning 은 CI 를 빨갛게 만들지 않는다. 새 경고를 남기고 지나가지 마라 — 아무도 안 잡는다.
- **릴리스 전 `flutter pub publish --dry-run` 이 경고 0 개**여야 하고, 아카이브에 `build/`·`coverage/`·`docs/`·`.github/` 가 없어야 한다(Step 7 의 `.pubignore` 항목). dry-run 은 **깨끗한 워킹 트리에서** 돌린다 — 수정된 파일이 있으면 그 경고가 다른 경고를 가린다.
- **커밋은 사용자가 요청할 때만.** 이슈 하나를 `/tdd` 로 끝낸 뒤, **`lib` + `test` 경로만 명시적으로 stage** 한다(`git add -A` 금지). 커밋 본문 끝에 `Fixes #<n>` 과 Co-Authored-By 트레일러. 기본은 `main` 직접 커밋이며 push 는 요청 시에만 한다 — 따라서 `Fixes #n` 은 push 시점에야 이슈를 닫는다.
- **워킹 트리에 무관한 변경이 상주할 수 있다.** 의존 버전 bump·`example/pubspec.lock` 재생성 같은 것이 feature 커밋에 쓸려 들어가지 않게 한다.
- **태그는 커밋을 가리키는 불변 포인터다.** 문서까지 다 들어간 뒤에 단다. **발행되지 않은 태그를 옮기는 비용은 0 이다** — 잘못 달았으면 다음 버전으로 도망가지 말고 태그를 옮긴다. 버전 사이에 이유 없는 구멍을 남기지 마라.
- **`flutter pub publish` 는 되돌릴 수 없고 pub.dev 는 버전 삭제가 없다(retract 만). 에이전트가 실행하지 않는다 — 사용자가 직접.**
