# HR Please — Expansion Plan: From Prototype to Full Game

## Overview

Expand from a 5-day prototype to a 15-day, three-week campaign with deeper narrative,
more mechanics, recurring characters, and English localization support.

**Current state**: 5 days, 5 events, 5 endings, ~23 candidates, 6 directives, 8 inconsistency types
**Target state**: 15 days, 20+ events, 10 endings, ~90 candidates, 15+ directives, 12+ inconsistency types

---

## 1. THREE-WEEK NARRATIVE STRUCTURE

### Week 1: "Oryantasyon" (Orientation) — Days 1-5
*You're the new HR officer. Learn the ropes, meet the players.*

| Day | Title (TR) | Title (EN) | Candidates | Duration | New Directives | Events | Theme |
|-----|-----------|-----------|-----------|----------|---------------|--------|-------|
| 1 | Pazartesi — İlk Gün | Monday — First Day | 3 | 4:00 | min_experience_3 | office_tour | Tutorial: basics of document checking |
| 2 | Salı — Rutine Giriş | Tuesday — Into the Routine | 4 | 3:30 | no_engineering | complaint_letter | First moral nudge |
| 3 | Çarşamba — CEO'nun Gölgesi | Wednesday — CEO's Shadow | 5 | 3:15 | disability_quota | ceo_nephew | Nepotism pressure |
| 4 | Perşembe — Sendika Kapıda | Thursday — Union at the Door | 5 | 3:00 | must_hire_ahmet, no_hiring | union_pressure, whistleblower | Contradictory orders |
| 5 | Cuma — İlk Fırtına | Friday — First Storm | 6 | 2:30 | report_suspicious | internal_audit_warning | Week 1 cliffhanger |

**Week 1 ends with**: An internal audit is announced. Everything you did this week will be reviewed.

### Week 2: "Baskı" (Pressure) — Days 6-10
*The stakes rise. New document types, corporate politics, and recurring characters return.*

| Day | Title (TR) | Title (EN) | Candidates | Duration | New Directives | Events | Theme |
|-----|-----------|-----------|-----------|----------|---------------|--------|-------|
| 6 | Pazartesi — Yeni Kurallar | Monday — New Rules | 5 | 3:30 | age_limit_40, background_check | new_hr_policy | New directives cascade — age discrimination |
| 7 | Salı — Eski Bir Tanıdık | Tuesday — A Familiar Face | 6 | 3:15 | gender_balance | returning_candidate, anonymous_tip | A rejected Week 1 candidate returns with new documents |
| 8 | Çarşamba — Basın Baskısı | Wednesday — Press Pressure | 6 | 3:00 | no_criminal_record, priority_hire_list | journalist_visit | A journalist investigates the company |
| 9 | Perşembe — Gizli Toplantı | Thursday — Secret Meeting | 7 | 2:45 | loyalty_test | secret_meeting, double_agent | CEO tests your loyalty with a planted candidate |
| 10 | Cuma — Denetim Günü | Friday — Audit Day | 7 | 2:30 | perfect_compliance | audit_review, week2_choice | The audit reviews your Week 1 decisions |

**Week 2 ends with**: The auditor presents findings. You must choose: cover for the company or cooperate with the auditor.

### Week 3: "Hesap Günü" (Day of Reckoning) — Days 11-15
*Your past choices shape the present. Multiple storylines converge.*

| Day | Title (TR) | Title (EN) | Candidates | Duration | New Directives | Events | Theme |
|-----|-----------|-----------|-----------|----------|---------------|--------|-------|
| 11 | Pazartesi — Yeni Düzen | Monday — New Order | 6 | 3:00 | political_hire, no_over_30 | regime_change | New management, new (worse) rules |
| 12 | Salı — Hayalet Dosyalar | Tuesday — Ghost Files | 7 | 2:45 | verify_all_references | ghost_employees, informant_return | Discover fake employees on payroll |
| 13 | Çarşamba — Savcılık | Wednesday — Prosecution | 7 | 2:30 | emergency_freeze | prosecutor_visit, evidence_choice | Prosecutors arrive at the company |
| 14 | Perşembe — Son Mülakat | Thursday — Last Interview | 8 | 2:15 | hire_replacement | confrontation, ally_or_enemy | Your replacement interviews — you decide who takes your seat |
| 15 | Cuma — Veda | Friday — Farewell | 8 | 2:00 | final_directive | final_choice_expanded | Everything converges — the last day |

**Week 3 ends with**: One of 10 possible endings based on cumulative choices.

---

## 2. NEW DIRECTIVES (10 new, 16 total)

### Week 2 Directives
| ID | Text (TR) | Text (EN) | Type |
|----|----------|----------|------|
| `age_limit_40` | 40 yaş üstü adayları almayın | Don't hire candidates over 40 | Ethically questionable |
| `background_check` | Referans mektubu olmayan adayları reddedin | Reject candidates without reference letters | Document check |
| `gender_balance` | Kadın-erkek eşit sayıda alın | Hire equal numbers of men and women | Quota |
| `no_criminal_record` | Sabıka kaydı şüphesi olan adayları bildirin | Report candidates with suspected criminal records | Report |
| `priority_hire_list` | Öncelikli liste: bu isimleri mutlaka alın | Priority list: must hire these names | Override |
| `loyalty_test` | CEO'nun sorularını adaylara sorun | Ask CEO's questions to candidates | Compliance test |
| `perfect_compliance` | Bugün sıfır ihlal toleransı | Zero violation tolerance today | Pressure |

### Week 3 Directives
| ID | Text (TR) | Text (EN) | Type |
|----|----------|----------|------|
| `political_hire` | Partinin adamını işe alın | Hire the party's candidate | Political pressure |
| `no_over_30` | 30 yaş üstü alım yok — "genç kan" politikası | No hires over 30 — "young blood" policy | Discriminatory |
| `verify_all_references` | Tüm referansları çapraz kontrol edin | Cross-check all references | Investigative |
| `emergency_freeze` | Acil durum — sadece kritik pozisyonlara alım | Emergency — hire for critical positions only | Restriction |
| `hire_replacement` | Yerinize gelecek kişiyi seçin | Choose your own replacement | Meta |
| `final_directive` | Vicdanınıza göre karar verin | Decide according to your conscience | Freedom |

---

## 3. NEW EVENTS (15 new, 20 total)

### Week 1 — New Events
```
office_tour:
  Day 1, day_start — Your manager gives you the tour
  Choices: "Ask about the previous HR officer" / "Just nod along"
  Sets: curious_about_past / obedient
  Purpose: Tutorial + foreshadowing

internal_audit_warning:
  Day 5, day_end — Manager whispers: "Auditors are coming Monday"
  Choices: "Should I be worried?" / "My records are clean"
  Sets: audit_anxious / audit_confident
```

### Week 2 — New Events
```
new_hr_policy:
  Day 6, day_start — New discriminatory age policy announced
  Choices: "This is wrong but I'll comply" / "I'll find a way around it"
  Sets: compliant_ageism / resisted_ageism

returning_candidate:
  Day 7, candidate_2 — A candidate you rejected in Week 1 returns
  with different documents (possibly forged)
  Choices: "I remember you..." / "Let me check your documents again"
  Sets: recognized_returner / treated_as_new

anonymous_tip:
  Day 7, day_end — Anonymous note on your desk about a candidate
  Choices: "Investigate" / "Throw it away"
  Sets: investigated_tip / ignored_tip

journalist_visit:
  Day 8, day_start — A journalist posing as a candidate
  They ask probing questions about company hiring practices
  Auto-detected later if you hired them
  Sets: hired_journalist / rejected_journalist

secret_meeting:
  Day 9, day_start — CEO invites you to a private meeting
  "I need to know who I can trust"
  Choices: "I'm loyal to the company" / "I'm loyal to doing things right"
  Sets: pledged_loyalty / pledged_integrity

double_agent:
  Day 9, candidate_4 — A candidate is clearly a corporate spy
  from a rival company. Documents are perfect but behavior is suspicious
  Choices: "Report to CEO" / "Report to authorities" / "Ignore"
  Sets: reported_spy_to_ceo / reported_spy_to_law / ignored_spy

audit_review:
  Day 10, day_start — Auditor presents findings from Week 1
  Your past decisions are reviewed on screen
  No choice — narrative beat showing consequences

week2_choice:
  Day 10, day_end — Auditor asks you to sign a statement
  "Were there any irregularities?"
  Choices: "Everything was by the book" / "There were... complications"
  Sets: lied_to_auditor / told_auditor_truth
```

### Week 3 — New Events
```
regime_change:
  Day 11, day_start — New CEO installed after board coup
  All previous directives void, new (worse) ones incoming
  Sets: new_management (automatic)

ghost_employees:
  Day 12, candidate_3 — You discover a candidate who is already
  "employed" at the company — a ghost employee drawing salary
  Choices: "Flag it in the system" / "Pretend you didn't see it"
  Sets: flagged_ghost / ignored_ghost

informant_return:
  Day 12, day_end — The whistleblower from Day 4 returns
  "Did you do anything with what I told you?"
  Branches based on listened_whistleblower flag

prosecutor_visit:
  Day 13, day_start — A real prosecutor arrives (not a candidate)
  "We need to see your hiring records from the past two weeks"
  Choices: "Full cooperation" / "I need to consult legal first"
  Sets: cooperated_prosecutor / stalled_prosecutor

evidence_choice:
  Day 13, day_end — You find a USB drive with evidence
  Choices: "Copy it" / "Give it to the prosecutor" / "Destroy it"
  Sets: copied_evidence / gave_evidence / destroyed_evidence

confrontation:
  Day 14, candidate_1 — The CEO's nephew returns, now as your
  "supervisor" if you hired him, or as an angry accuser if you didn't
  Branches based on accepted_nepotism flag

ally_or_enemy:
  Day 14, day_end — Someone you helped/hurt earlier offers/demands
  something. Branches based on cumulative moral score

final_choice_expanded:
  Day 15, day_end — The ultimate choice, with more branches than
  the prototype. 4 options based on what paths are available:
  1. "Submit the evidence to the press" (requires copied_evidence)
  2. "Testify before the board" (requires cooperated_prosecutor)
  3. "Accept the golden parachute and walk away"
  4. "Burn everything and start over"
```

---

## 4. RECURRING CHARACTERS

Characters who appear across multiple days, creating continuity:

| Character | First Appears | Returns | Arc |
|-----------|--------------|---------|-----|
| **Selim Patronoğlu** (CEO's nephew) | Day 3 | Day 14 | From unqualified applicant to either your boss or your accuser |
| **Ahmet Yılmaz** (Union candidate) | Day 4 | Day 11 | Union man caught in the regime change |
| **The Whistleblower** (Deniz Fırat) | Day 4 | Day 12 | Returns to see if you acted on their intel |
| **The Journalist** (Elif Korkmaz) | Day 8 | Day 15 | Publishes story about the company based on what she learned |
| **The Auditor** (Hakan Sezer) | Day 10 | Day 13 | Returns with the prosecutors |
| **Your Manager** (Canan Hanım) | Day 1 | Days 5, 9, 14 | Increasingly conflicted; may become ally or obstacle |

---

## 5. EXPANDED ENDINGS (10 total)

### Original (refined)
1. **KOVULDUNUZ / FIRED** — 3+ violations at any point
2. **MUHBİR / WHISTLEBLOWER** — Exposed corruption, lost your job, gained your soul
3. **YOLSUZLUK / CORRUPT** — Climbed the ladder on broken rungs
4. **TERFİ / PROMOTED** — Clean record, rewarded... but now you're "one of them"
5. **SIRADAN / ORDINARY** — The default, bureaucratic existence continues

### New Endings
6. **KAHRAMAN / HERO** — Cooperated with prosecutors + gave evidence + supported union
   *"The trial made national news. Your testimony brought down the board. They offered you a medal. You said you were just doing your job."*

7. **SÜRGÜN / EXILE** — Told the truth but had no evidence to back it up
   *"Nobody believed you. Your career in HR is over. You work at a different company now, filing papers nobody reads."*

8. **ÇİFTE AJAN / DOUBLE AGENT** — Pledged loyalty to CEO + cooperated with prosecutor
   *"You played both sides. Both sides know. Trust is a currency you've spent."*

9. **REFORM / REFORMER** — Resisted ageism + resisted nepotism + hired fairly + low violations
   *"The new board asked you to write the company's new ethics charter. Ironic — or exactly right."*

10. **KAYIP / THE VANISHED** — Destroyed evidence + lied to auditor + ignored all whistleblowers
    *"One Monday, your desk was empty. No resignation letter. No forwarding address. The system erased you, just like you erased those files."*

---

## 6. NEW INCONSISTENCY TYPES (4 new, 12 total)

| ID | Name (TR) | Name (EN) | Available From |
|----|----------|----------|---------------|
| `address_mismatch` | CV'deki şehir ile kimlik şehri farklı | City on CV doesn't match ID | Day 6 |
| `photo_mismatch` | Fotoğraf adayla uyuşmuyor | Photo doesn't match candidate | Day 8 |
| `employment_gap` | Açıklanamayan iş boşluğu | Unexplained employment gap | Day 7 |
| `duplicate_candidate` | Aynı kişi farklı isimle daha önce başvurmuş | Same person applied before under a different name | Day 11 |

---

## 7. NEW DOCUMENT TYPES (2 new, 6 total)

| Document | Available From | Description |
|----------|---------------|-------------|
| **Sabıka Kaydı / Criminal Record** | Day 8 | Clean or flagged; may be forged |
| **Sağlık Raporu / Health Report** | Day 11 | Required for new management; can reveal disability status |

---

## 8. LOCALIZATION SYSTEM

### Architecture: Key-based translation with TR/EN JSON files

```
localization/
├── tr.json    # Turkish (primary)
├── en.json    # English
└── locale_manager.gd  # Autoload singleton
```

**Approach:**
- All hardcoded Turkish strings replaced with `tr("KEY")` calls
- `locale_manager.gd` autoload that loads the correct JSON at startup
- Language selection on the main menu
- All dialogue pools get parallel EN arrays
- Document content generated through the locale system
- Event text and choice text all keyed

**Key categories:**
- `ui.*` — Button labels, menu items, status bar text
- `day.*` — Day titles, headlines, briefing text
- `event.*` — Event titles, descriptions, choice text
- `ending.*` — Ending titles and narrative text
- `doc.*` — Document field labels
- `dialogue.*` — Greetings, reactions, interview lines
- `directive.*` — Directive descriptions
- `candidate.*` — Candidate generation data (names stay Turkish for authenticity, labels get translated)

**Estimated string count:** ~500 keys

---

## 9. IMPLEMENTATION PHASES

### Phase 1: Foundation (Localization + Architecture)
**Files to modify/create:**
- [ ] Create `localization/tr.json` — Extract all Turkish strings
- [ ] Create `localization/en.json` — English translations
- [ ] Create `autoload/locale_manager.gd` — Translation singleton
- [ ] Modify `project.godot` — Register new autoload
- [ ] Modify `scenes/main_menu/main_menu.gd` — Add language selector
- [ ] Update all scenes to use `tr()` calls instead of hardcoded strings

### Phase 2: Content Expansion — Week 2 (Days 6-10)
**Files to modify/create:**
- [ ] Modify `autoload/game_manager.gd` — Add day configs 6-10, update max_days to 15
- [ ] Modify `data/directives.gd` — Add 7 new Week 2 directives
- [ ] Modify `data/events.gd` — Add 8 new Week 2 events
- [ ] Modify `data/candidates.gd` — Add new inconsistency types, returning candidate logic
- [ ] Create `data/recurring_characters.gd` — Named character definitions and state tracking
- [ ] Modify `resources/candidate_data.gd` — Add new fields (criminal_record, health_report)
- [ ] Create `resources/recurring_character_data.gd` — Character arc tracking

### Phase 3: Content Expansion — Week 3 (Days 11-15)
**Files to modify/create:**
- [ ] Modify `autoload/game_manager.gd` — Add day configs 11-15
- [ ] Modify `data/directives.gd` — Add 6 new Week 3 directives
- [ ] Modify `data/events.gd` — Add 7 new Week 3 events
- [ ] Modify `autoload/game_manager.gd` (`get_ending()`) — Expand to 10 endings
- [ ] Add branching event logic based on accumulated flags

### Phase 4: New Document Types + Inconsistencies
**Files to modify/create:**
- [ ] Modify `data/candidates.gd` — Criminal record + health report generation
- [ ] Modify `resources/document_data.gd` — Support new doc types
- [ ] Modify `scenes/game_day/document_view.gd` — Render new document types
- [ ] Add 4 new inconsistency types to `inject_inconsistency()`

### Phase 5: Recurring Characters + Story Arcs
**Files to modify/create:**
- [ ] Create `data/recurring_characters.gd` — Full character definitions
- [ ] Modify `scenes/game_day/game_day.gd` — Event branching based on prior flags
- [ ] Modify `data/events.gd` — Conditional event text based on past choices
- [ ] Modify `autoload/game_manager.gd` — Moral score tracking

### Phase 6: Week 1 Refinement
**Files to modify/create:**
- [ ] Modify existing Day 1-5 configs for better pacing
- [ ] Add `office_tour` and `internal_audit_warning` events
- [ ] Adjust difficulty curve for 15-day arc
- [ ] Tune inconsistency ratios across all 15 days

---

## 10. DIFFICULTY CURVE (15 days)

```
Day:   1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
      ┌────────────────┬────────────────┬────────────────┐
Cands: 3    4    5    5    6    5    6    6    7    7    6    7    7    8    8
Time:  4:00 3:30 3:15 3:00 2:30 3:30 3:15 3:00 2:45 2:30 3:00 2:45 2:30 2:15 2:00
Inc%:  .15  .25  .30  .35  .40  .30  .35  .40  .45  .50  .40  .45  .50  .55  .60
Dirs:  1    2    3    3    2    2    2    3    3    2    3    2    3    3    1
Events:1    1    1    2    1    1    2    1    2    2    1    2    2    2    1
      └────────────────┴────────────────┴────────────────┘
       ORIENTATION       PRESSURE         RECKONING
```

**Note:** Each new week starts slightly easier (more time, fewer inconsistencies) to let the player
adjust to new mechanics before difficulty ramps up again. This creates a "sawtooth" difficulty curve
that feels fair while constantly escalating.

---

## 11. MORAL TRACKING SYSTEM

A hidden composite score that determines ending eligibility:

```gdscript
# Computed from flags at game end
var moral_score: int = 0

# Positive actions
if has_flag("rejected_nepotism"): moral_score += 2
if has_flag("supported_union"): moral_score += 1
if has_flag("listened_whistleblower"): moral_score += 2
if has_flag("reported_fraud"): moral_score += 3
if has_flag("resisted_ageism"): moral_score += 2
if has_flag("cooperated_prosecutor"): moral_score += 2
if has_flag("gave_evidence"): moral_score += 3
if has_flag("flagged_ghost"): moral_score += 1
if has_flag("told_auditor_truth"): moral_score += 2

# Negative actions
if has_flag("accepted_nepotism"): moral_score -= 2
if has_flag("ignored_fraud"): moral_score -= 3
if has_flag("compliant_ageism"): moral_score -= 2
if has_flag("lied_to_auditor"): moral_score -= 2
if has_flag("destroyed_evidence"): moral_score -= 3
if has_flag("ignored_ghost"): moral_score -= 1
if has_flag("pledged_loyalty"): moral_score -= 1
```

**Ending thresholds:**
- HERO: moral_score >= 12 AND specific evidence flags
- REFORMER: moral_score >= 8 AND low violations
- WHISTLEBLOWER: moral_score >= 6 AND reported_fraud
- PROMOTED: moral_score 0-5 AND violations <= 2
- ORDINARY: moral_score -2 to 2
- DOUBLE AGENT: contradictory flags (pledged_loyalty AND cooperated_prosecutor)
- CORRUPT: moral_score <= -4 AND accepted_nepotism
- EXILE: told truth but no evidence (told_auditor_truth AND NOT gave_evidence)
- VANISHED: moral_score <= -8
- FIRED: violations >= max_violations (always overrides)

---

## 12. CONTENT VOLUME SUMMARY

| Category | Prototype | Expanded | Growth |
|----------|-----------|----------|--------|
| Game Days | 5 | 15 | 3x |
| Total Candidates | ~23 | ~90 | ~4x |
| Story Events | 5 | 20 | 4x |
| Directives | 6 | 16 | 2.7x |
| Endings | 5 | 10 | 2x |
| Inconsistency Types | 8 | 12 | 1.5x |
| Document Types | 4 | 6 | 1.5x |
| Recurring Characters | 1 | 6 | 6x |
| Dialogue Strings | ~160 | ~400+ | 2.5x |
| Localized Languages | 1 | 2 | 2x |
| Moral Choice Flags | 7 | 20+ | 3x |
| Total Strings (est.) | ~200 | ~500 | 2.5x |

---

## 13. FILE CHANGE SUMMARY

### New Files (7)
```
localization/tr.json
localization/en.json
autoload/locale_manager.gd
data/recurring_characters.gd
resources/recurring_character_data.gd
resources/criminal_record_data.gd
resources/health_report_data.gd
```

### Modified Files (11)
```
project.godot                          — New autoload, metadata
autoload/game_manager.gd               — 15 days, 10 endings, moral tracking
data/candidates.gd                     — New inconsistencies, document types, EN pools
data/directives.gd                     — 10 new directives
data/events.gd                         — 15 new events with conditional branches
resources/candidate_data.gd            — New fields
resources/document_data.gd             — New doc types
scenes/main_menu/main_menu.gd          — Language selector
scenes/game_day/game_day.gd            — Recurring character insertion, new event triggers
scenes/game_day/document_view.gd       — Render new document types
scenes/ending/ending.gd                — 10 ending colors/styles
```
