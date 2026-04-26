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
| 2 | All navigation buttons/links are visible | Each button leads to the correct screen |PASS | |
| 3 | App title and description are displayed | Text is readable and correct |PASS | |

---

### 2.2 Explore Datapath Screen
| # | Test Case | Expected Result | Pass/Fail | Notes |
|---|-----------|-----------------|-----------|-------|
| 4 | Datapath link loads correctly | Buttons are visible and clear |PASS | |
| 5 | Select Load instruction | Explore / Details Apear Correctly with Info |PASS | |
| 6 | Select Store instruction | Explore / Details Apear Correctly with Info |PASS | |
| 7 | Select ALU instruction | Explore / Details Apear Correctly with Info |PASS | |
| 8 | Select Branch instruction | Explore / Details Apear Correctly  | PASS| |
| 9 | Tap on Explanation  | Popup appears with correct explanation | PASS| |
| 10 | Tap on Detailed Page | Popup appears with correct Information |PASS | |
| 11 | Tab can be dismissed | Information tab closes cleanly| PASS| |
| 12 | All navigation buttons/links are visible | Each button leads to the correct screen |PASS | |

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
