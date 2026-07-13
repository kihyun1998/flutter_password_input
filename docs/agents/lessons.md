# Lessons — flutter_password_input 실증

이 repo 가 `theflow` 의 각 단계에서 실제로 **확인한** 것만 기록한다 — 규칙에 무게를 주는
근거. **다른 repo 의 사고 기록을 옮겨 오지 않는다**(틀린 근거가 리포에 남으면 다음 사람이
그걸 믿는다). 단계 번호는 `theflow` SKILL.md 와 일치. 새 실증은 해당 단계 밑에.

이 repo 는 다른 소비처들보다 실증이 적다 — flow 규칙 대부분은 아직 *원칙*으로 서 있고(그건
`theflow` 스킬이 담는다), 아래는 여기서 실제로 밟은 것들이다.

---

## Step 1/2 — 실측 (외부 표면이 넓다)

- **`just_tooltip` 0.3.0 → 0.4.0 은 두 번의 연속 breaking 마이그레이션**이었다(e143183,
  74637ef). 외부 패키지의 API 표면 변화는 매번 **실제 소스**에서 확인한다 — pub.dev 문서나
  CHANGELOG 가 아니라. 이 패키지는 `just_tooltip`·`flutter_ime` 두 개에 넓게 붙어 있다.
- **빌드 모드가 명제의 참·거짓을 가른다.** `flutter test`/debug 는 widget creation
  tracking 으로 `const` 정규화를 막아 `identical(const SizedBox(), const SizedBox())` 가
  **test 에선 false, release 에선 true** 다. `assert` 안에서만 던지는 에러도 release 에선
  발동하지 않는다 — debug 크래시보다 release 의 조용한 오작동이 나쁘다. 빌드 모드에 따라
  갈리는 명제를 테스트로 굳히지 마라.

## Step 2 — 경계 (seam 은 계약 결정)

- **`flutter_ime` 를 `KeyboardInputMonitor` 뒤로 격리한 것(6622807)은 순수 리팩터가 아니라
  테스트 seam 을 어디에 그을지의 계약 결정**이었다. red 테스트를 쓰기 *전에* 정해졌다.
- **이름은 계약이다.** `PasswordFieldWarning` → `PasswordFieldStatus` 개명(de934a5)은
  `feat!` 이었다 — 공개 이름·의미를 바꾸는 커밋은 코드 전에 grilling 을 거친다.

## Step 4/5 — 테스트 신뢰 (통과가 증명이 아니다)

- **#5 (dispose 는 위젯 테스트가 안 잡는다)**: `JustTooltipController` 를 dispose 하지 않아
  `ChangeNotifier` 가 샜다(9f21d51). 통과하던 위젯 테스트들은 누수를 전혀 보지 못했다.
  컨트롤러·notifier·리스너를 만드는 코드는 **수명 테스트를 함께** 낸다.
- **동등성 테스트는 identity 로 조용히 통과한다.** Dart 는 동일 인자 `const` 를 같은
  인스턴스로 정규화하므로 `const a == const b` 는 `operator ==` 가 없어도 통과한다. 값을
  런타임에 만들고 `expect(identical(a, b), isFalse)` 를 **먼저** 단언한다.
- **tooltip 정렬 테스트는 "툴팁이 실제로 떴다" 를 먼저 확인**해야 한다 — 안 뜨면 좌표
  단언이 공허하게 통과한다.
- **`copyWith` 의 `x ?? this.x`** 는 각 필드를 *교체할 때만* 테스트하면 오른쪽 피연산자가
  한 번도 평가되지 않는다. 인자 없는 `copyWith()` 가 원본과 동등해야 한다는 속성 하나로 전
  필드를 덮는다.

## Step 6/7 — 정합성 & 게이트

- **`.pubignore` 는 `.gitignore` 를 무력화한다** (2026-07-10 확인): `/coverage/` 가
  `.gitignore` 에 있음에도 `pub publish --dry-run` 아카이브에 `coverage/lcov.info` 가
  실려 있었다 — `.pubignore` 가 `docs/`·`CLAUDE.md`·`build/` 만 나열했기 때문(305e7d3 이
  `coverage/` 를 추가). CI·로컬이 새로 만드는 디렉터리는 `.pubignore` 에 직접 추가한다.
- **`interactive`·`waitDuration` 은 이 repo 의 툴팁에 효과가 없다**(bb73b06) — 비상호작용
  표시용이라, 노출하거나 의존하지 않는다. dartdoc 에도 그렇게 적혀 있다.
- **CI 에 커버리지 게이트도 `--fatal-infos/-warnings` 도 없다** — 커버리지 회귀와 새
  info/warning 은 사람이 본다. 남기고 지나가면 아무도 안 잡는다.
