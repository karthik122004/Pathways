# TEST PLAN — Pathways: Inside the Processor
**Tester:** Adriel Largo , Karthik Matli, Salam Elbahri, 
Hung Viet Nguyen, Luke Servantes


**Branch:** `testing/puzzle-features`  
**Project:** Pathways: Inside the Processor (iOS App — Swift/SwiftUI)  
**Last Updated:** April 23rd 2026

---

## 1. Overview

This document outlines the test plan for evaluating all features of the Pathways app, including the interactive puzzle feature added per instructor feedback. Testing will be conducted via screen share or in-person with a teammate running the app on Xcode's iOS simulator.

---

## 2. Features to Test

### 2.1 Home Screen
| # | Test Case | Expected Result | Pass/Fail | Notes |
|---|-----------|-----------------|-----------|-------|
| 1 | App launches without crashing | Home screen displays correctly |PASS | |
| 2 | All navigation buttons/links are visible | Each button leads to the correct screen | | |
| 3 | App title and description are displayed | Text is readable and correct | | |

---

### 2.2 Base Datapath Screen
| # | Test Case | Expected Result | Pass/Fail | Notes |
|---|-----------|-----------------|-----------|-------|
| 4 | Datapath diagram loads correctly | Full MIPS diagram is visible and clear | | |
| 5 | Select R-type instruction | Correct wires and components are highlighted | | |
| 6 | Select Load instruction | Correct wires and components are highlighted | | |
| 7 | Select Store instruction | Correct wires and components are highlighted | | |
| 8 | Select Branch instruction | Correct wires and components are highlighted | | |
| 9 | Tap a highlighted component | Popup appears with correct explanation | | |
| 10 | Tap a highlighted wire | Popup appears with correct explanation | | |
| 11 | Popup can be dismissed | Popup closes cleanly, diagram remains | | |
| 12 | Non-highlighted elements are tappable | No popup appears OR a "not used" message shows | | |

---

### 2.3 Modified Datapath Screen
| # | Test Case | Expected Result | Pass/Fail | Notes |
|---|-----------|-----------------|-----------|-------|
| 13 | Modified datapath screen loads | New components/wires are visible | | |
| 14 | New instruction 1 selected | Correct added components highlighted | | |
| 15 | New instruction 2 selected (if applicable) | Correct added components highlighted | | |
| 16 | Explanation text for modifications shown | Text explains WHY each change is needed | | |

---

### 2.4 Puzzle Feature (Interactive Datapath Completion)
> Based on instructor feedback: user is shown an incomplete datapath and must connect wires/add elements to complete it.

| # | Test Case | Expected Result | Pass/Fail | Notes |
|---|-----------|-----------------|-----------|-------|
| 17 | Puzzle screen loads with an incomplete datapath | Missing wires/elements are clearly indicated | | |
| 18 | Instruction label is shown to guide the user | User knows which instruction to complete | | |
| 19 | User can attempt to connect a wire between two elements | Connection interaction is possible (drag or tap) | | |
| 20 | Correct wire connection is accepted | Wire snaps into place or is marked correct | | |
| 21 | Incorrect wire connection is rejected | App does NOT allow the connection | | |
| 22 | Diagnostic message shown on wrong connection | Relevant error message displayed (not generic) | | |
| 23 | Diagnostic message is specific to the mistake | Message explains why that connection is wrong | | |
| 24 | User can try again after a wrong attempt | Puzzle resets or allows re-attempt | | |
| 25 | Completing the puzzle correctly gives feedback | Success message or visual confirmation shown | | |
| 26 | Multiple puzzle scenarios available | At least one puzzle per instruction type | | |

---

### 2.5 Quiz Module
| # | Test Case | Expected Result | Pass/Fail | Notes |
|---|-----------|-----------------|-----------|-------|
| 27 | Quiz screen loads correctly | Questions are displayed clearly | | |
| 28 | Questions cover all instruction types | R-type, Load, Store, Branch all represented | | |
| 29 | Selecting a correct answer | Correct feedback shown with explanation | | |
| 30 | Selecting an incorrect answer | Incorrect feedback shown with explanation of right answer | | |
| 31 | Quiz presents different questions each attempt | Questions are randomized from question bank | | |
| 32 | Quiz completes after all questions answered | Score or summary screen shown | | |
| 33 | User can retake the quiz | New attempt starts with fresh/different questions | | |

---

## 3. Bug Report Template

Use this template to document any issues found during testing.


Feature: [Home / Datapath / Modified Datapath / Puzzle / Quiz]
Test Case #: 

Description:
[What happened?]

Steps to Reproduce:
1. 
2. 
3. 

Expected Result:
[What should have happened?]

Actual Result:
[What actually happened?]


Screenshot/Notes:
```

---

## 4. User Feedback Collection

After teammates and classmates use the app, collect informal feedback using these questions:

1. Was the datapath diagram easy to read and understand?
2. Did the highlighted wires/components make sense for each instruction?
3. Were the popup explanations clear and helpful?
4. Did the puzzle feel intuitive? Were the instructions clear?
5. Were the error messages for wrong connections helpful?
6. Did the quiz help reinforce your understanding?
7. What was the most confusing part of the app?
8. What would you improve?

---


---

## 5. Sign-Off

- [ ] All test cases executed  
- [ ] All bugs documented and reported to team  
- [ ] User feedback collected  
- [ ] Test results shared with Salam (Evaluation Lead) for final report  
