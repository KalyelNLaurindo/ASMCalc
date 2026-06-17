# **📋 Agile Backlog & Task Management: ASMCalc**

**Role:** Agile Coach / Tech Lead / Project Manager

**Objective:** Maintain a prioritizable backlog of atomic, SMART tasks, tracking their progress across a basic Markdown Kanban board from planning to verification.

## **🏛️ Backlog Metadata**

* **Project Owner:** Kalyel N. Laurindo / Project Owner  
* **Lead Tech Lead:** Kalyel N. Laurindo / Software Engineer  
* **Current Sprint / Iteration:** Sprint 1  
* **Target Delivery Date:** June 25, 2026
* **Document Version:** v1.0

---

## **1. 📊 Prioritization & Task Sizing Framework**

*   **Field 1.0 - Prioritization & Estimation Framework:** Simple Priority (High-Medium-Low)

---

## **2. 🗂️ Prioritized Product Backlog Ledger**

### **📦 Backlog Phase 1: Infrastructure Setup**

* **[[TSK-01](TSK-01.md)]: Toolchain Verification & Makefile Bootstrap**  
  * *Epic/Requirement Link:* N/A  
  * *Estimation/Priority:* High  
  * *TDD Test File:* N/A (Build validation target)  
  * *Status:* Done

### **⚙️ Backlog Phase 2: Core Arithmetic Implementation**

* **[[TSK-02](TSK-02.md)]: Core Arithmetic Procedures (math.asm)**  
  * *Epic/Requirement Link:* RF01, RF03  
  * *Estimation/Priority:* High  
  * *TDD Test File:* `tests/unit_tests.c` (C Test Harness)  
  * *Status:* Done

### **🧪 Backlog Phase 3: Core Logic Verification (TDD)**

* **[[TSK-03](TSK-03.md)]: C Test Harness for Math Routines**  
  * *Epic/Requirement Link:* RF01, RF03  
  * *Estimation/Priority:* High  
  * *TDD Test File:* `tests/unit_tests.c`  
  * *Status:* Done

### **🔌 Backlog Phase 4: Interface Adapters & CLI Integration**

* **[[TSK-04](TSK-04.md)]: Low-Level CLI Input/Output Handlers (io.asm)**  
  * *Epic/Requirement Link:* RF02, RF04  
  * *Estimation/Priority:* Medium  
  * *TDD Test File:* `tests/unit_tests.c`  
  * *Status:* To Do

* **[[TSK-05](TSK-05.md)]: Main Console Router Menu Loop (main.asm)**  
  * *Epic/Requirement Link:* RF02  
  * *Estimation/Priority:* High  
  * *TDD Test File:* `tests/e2e_tests.bat`  
  * *Status:* To Do

---

## **3. 📋 Basic Markdown Kanban Board**

### **🔴 To Do (Ready for Development)**

* [ ] **[[TSK-04](TSK-04.md)]:** Low-Level CLI Input/Output Handlers (io.asm)
* [ ] **[[TSK-05](TSK-05.md)]:** Main Console Router Menu Loop (main.asm)

### **🟡 In Progress (Actively Being Built)**

* [ ] None

### **🔵 In Review (QA & Test Verification)**

* [ ] None

### **🟢 Done (Merged & Verified in Main Trunk)**

* [x] **[[TSK-01](TSK-01.md)]:** Toolchain Verification & Makefile Bootstrap (Folder structure initialized)
* [x] **[[TSK-02](TSK-02.md)]:** Core Arithmetic Procedures (math.asm)
* [x] **[[TSK-03](TSK-03.md)]:** C Test Harness for Math Routines

---

**Signature:** Kalyel N. Laurindo / Project Owner
