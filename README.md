# VHDL Stopwatch Project

A digital stopwatch implemented in VHDL, designed for FPGA platforms. The project features precise time measurement, pause/resume functionality, and a memory system for storing split times.

## 🇬🇧 English Description

### Project Overview
The main goal of this project was to design and implement a functional digital stopwatch using VHDL. The system operates on a **50 MHz** system clock and provides precise time tracking in **MM:SS** format.

### Key Features
* **Time Control:** Start, Pause, and Resume functionality.
* **Memory System:** Ability to store up to **3 independent split times**.
* **Automated Reporting:** The testbench generates a `stoper_results.txt` file containing the simulation log.
* **Display Modes:** Toggle between live counting and viewing stored results via the `memory_select` input.
* **Reset:** Global asynchronous reset to clear all counters and memory.

### Technical Specification
* **Language:** VHDL (Hardware Description Language)
* **Clock:** 50 MHz
* **Architecture:** Finite State Machine (FSM) logic.

---

## 🇵🇱 Opis po Polsku

### Cel Projektu
Projekt cyfrowego stopera w języku VHDL, przystosowany do pracy z zegarem systemowym **50 MHz**. Układ umożliwia precyzyjne odliczanie czasu i prezentację wyników w formacie **MM:SS**.

### Funkcjonalności
* **Sterowanie:** Start, wstrzymanie (Pauza) oraz wznowienie pracy.
* **Pamięć Międzyczasów:** Zapis do **3 wyników** w wewnętrznych rejestrach.
* **Raportowanie:** Testbench automatycznie generuje plik `stoper_results.txt` z przebiegiem symulacji (wykorzystanie biblioteki `TEXTIO`).
* **Tryby Wyświetlania:** Przełącznik `memory_select` pozwala na podgląd czasu "na żywo" lub wyników z pamięci.
* **Reset:** Pełne zerowanie urządzenia.

---

## 📂 Project Structure / Struktura Projektu

* `src/` - Source files / Pliki źródłowe (`STOPER.vhd`)
* `sim/` - Testbench files / Pliki symulacji (`STOPER_testbench.vhd`)
* `docs/` - Technical documentation / Sprawozdanie (PDF)
* `output/` - Simulation logs / Wyniki symulacji (`stoper_results.txt`)

---
**Author:** Kacper Sosnowski
