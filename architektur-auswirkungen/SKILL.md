---
name: architektur-auswirkungen
description: Erstellt aus einer Feature-Beschreibung (User Story) eine High-Level-Analyse der Architektur-Auswirkungen, bevor Code geschrieben wird. Diese Skill immer verwenden, wenn der Nutzer eine neue User Story, ein Feature, eine Anforderung oder eine größere Änderung beschreibt und wissen will, wie sie sich auf die Architektur auswirkt — auch wenn er nicht explizit nach einer "Architektur-Analyse" fragt, sondern z. B. sagt "wir wollen Feature X bauen", "analysiere diese Story", "was bedeutet das für unser System" oder "bereite die Umsetzung von X vor". Ziel ist bessere Code-Review-Qualität und langfristige Wartbarkeit.
---

# Architektur-Auswirkungen

Diese Skill verwandelt eine Feature-Beschreibung (User Story) in eine High-Level-Analyse der Architektur-Auswirkungen. Sie dient dazu, Architekturentscheidungen sichtbar zu machen, *bevor* Code entsteht — dort, wo Korrekturen am billigsten sind.

## Grundprinzipien

Diese Prinzipien gelten für den gesamten Workflow und haben Vorrang vor Abkürzungen:

1. **Analyse vor Implementierung.** Diese Skill schreibt keinen Feature-Code. Sie liefert die Analyse, auf deren Basis Menschen (und ggf. spätere Agent-Sessions) implementieren.
2. **Erst Freigabe, dann Dateien.** Bis zur expliziten Freigabe durch den Nutzer wird ausschließlich im Chat gearbeitet. Dateien werden erst im letzten Schritt geschrieben — niemals vorher, auch nicht "vorsorglich".
3. **Kein zentrales, lebendes Architekturdokument.** Die Analyse ist ein eigenständiges Artefakt pro Feature. Es wird kein globales Architekturdokument gepflegt oder aktualisiert.
4. **Spannungen nur benennen, wenn sie wirklich signifikant sind.** Nicht jede Abweichung von einem Ideal ist erwähnenswert. Eine Spannung gehört nur in die Analyse, wenn sie voraussichtlich echte Wartbarkeits- oder Umbaukosten verursacht. Im Zweifel: weglassen. Eine Analyse voller Kleinigkeiten trainiert Leser darauf, Warnungen zu ignorieren.
5. **ADRs vorschlagen, nicht automatisch erstellen.** Wenn die Analyse eine architektonisch relevante Entscheidung aufdeckt, wird ein Architecture Decision Record *vorgeschlagen*. Erstellt wird er nur, wenn der Nutzer zustimmt.
6. **Kein Drift-Check.** Der Abgleich zwischen dokumentierten Entscheidungen und tatsächlichem Code-Zustand ist bewusst nicht Teil dieser Skill (für eine spätere Version vorgesehen).

## Workflow (8 Schritte)

Die Schritte 1–6 sind reine Analyse- und Entwurfsarbeit im Chat. Schritt 7 ist das Freigabe-Gate. Erst Schritt 8 schreibt Dateien.

### Schritt 1: User Story erfassen und Kontext klären

Die Feature-Beschreibung des Nutzers lesen. Wenn wesentliche Punkte unklar sind (Zielgruppe, Umfang, Nicht-Ziele, betroffene fachliche Domäne), gezielt nachfragen — aber nur, was für die Architektur-Analyse wirklich nötig ist. Keine Detailfragen zur Implementierung.

### Schritt 2: Betroffene Teile des Systems identifizieren

Die Codebasis explorieren (Verzeichnisstruktur, zentrale Module, Schnittstellen, ggf. vorhandene ADRs im Repository), um zu verstehen, welche Komponenten die Story berührt. High-Level bleiben: Es geht um Module, Grenzen und Verantwortlichkeiten, nicht um einzelne Funktionen.

### Schritt 3: Auswirkungen analysieren

Für jede betroffene Komponente bewerten:
- **Struktur:** Entstehen neue Komponenten oder Verantwortlichkeiten? Verschieben sich bestehende Grenzen?
- **Schnittstellen und Verträge:** Ändern sich APIs, Events, Datenformate — intern oder nach außen?
- **Datenfluss und Persistenz:** Neue oder geänderte Datenmodelle, Migrationsbedarf?
- **Querschnittsthemen:** Auswirkungen auf Sicherheit, Berechtigungen, Performance, Beobachtbarkeit — nur soweit relevant.

### Schritt 4: Spannungen bewerten

Prüfen, ob die Story mit bestehenden Strukturen oder dokumentierten Entscheidungen in Konflikt steht. Gemäß Grundprinzip 4 nur signifikante Spannungen aufnehmen: solche, die absehbar Umbau-, Kopplungs- oder Wartungskosten erzeugen. Für jede aufgenommene Spannung kurz begründen, *warum* sie signifikant ist. Gibt es keine, steht in der Analyse explizit "Keine signifikanten Spannungen identifiziert" — das ist ein wertvolles Ergebnis, kein Mangel.

### Schritt 5: Entscheidungsbedarf prüfen (ADR-Vorschlag)

Wenn die Analyse eine Entscheidung aufdeckt, die zukünftige Entwicklung bindet (z. B. Wahl eines Integrationsmusters, Zuschnitt einer neuen Komponente), diese als ADR-Kandidat markieren: Titel, Kontext in zwei Sätzen, die realistischen Optionen. Nicht mehr — das ADR selbst entsteht nur nach Zustimmung des Nutzers in Schritt 8.

### Schritt 6: Analyse-Entwurf erstellen

Den vollständigen Entwurf nach der Vorlage unten formulieren — im Chat, nicht als Datei.

### Schritt 7: Entwurf zur Freigabe vorlegen

Den Entwurf dem Nutzer zeigen und explizit um Freigabe bitten. Dabei konkret fragen:
- Stimmt der Zuschnitt (zu detailliert / zu grob)?
- Sind die als signifikant markierten Spannungen aus Nutzersicht wirklich signifikant?
- Sollen die vorgeschlagenen ADRs erstellt werden (einzeln entscheidbar)?

Änderungswünsche einarbeiten und erneut vorlegen, bis der Nutzer freigibt. Ohne Freigabe endet der Workflow hier.

### Schritt 8: Dateien schreiben

Erst jetzt, nach expliziter Freigabe:
1. Die Analyse als Markdown-Datei ablegen: `docs/architektur/auswirkungen/<JJJJ-MM-TT>-<kurzer-story-titel>.md` (bzw. an dem Ort, den der Nutzer nennt oder der im Projekt bereits etabliert ist).
2. Nur die ADRs erstellen, denen der Nutzer zugestimmt hat, im etablierten ADR-Verzeichnis und -Format des Projekts (falls keines existiert: `docs/architektur/adr/` mit fortlaufender Nummer vorschlagen).
3. Kurz zusammenfassen, welche Dateien geschrieben wurden.

## Vorlage für die Analyse

```markdown
# Architektur-Auswirkungen: <Story-Titel>

**Datum:** <JJJJ-MM-TT>
**Story:** <Ein-Satz-Zusammenfassung oder Referenz/Ticket-Nr.>

## Zusammenfassung
<3–5 Sätze: Was ändert sich am System, was ist die wichtigste Erkenntnis?>

## Betroffene Komponenten
<Pro Komponente: Name, Art der Auswirkung (neu / geändert / erweitert), ein bis zwei Sätze.>

## Schnittstellen und Datenfluss
<Nur Änderungen an Verträgen, Events, Datenmodellen. "Keine Änderungen" ist eine gültige Aussage.>

## Signifikante Spannungen
<Nur wirklich signifikante, jeweils mit Begründung der Signifikanz.
Sonst: "Keine signifikanten Spannungen identifiziert.">

## Vorgeschlagene ADRs
<Titel + Zwei-Satz-Kontext + Optionen. Sonst: "Kein Entscheidungsbedarf.">

## Hinweise für das Code-Review
<2–4 Punkte: Worauf sollten Reviewer bei der späteren Umsetzung besonders achten?>
```

## Stil der Analyse

- High-Level und knapp: Die Analyse soll in wenigen Minuten lesbar sein. Zielgröße ein bis zwei Seiten.
- Deutsch als Dokumentationssprache; etablierte Fachbegriffe (z. B. "Event Sourcing", "Bounded Context") bleiben englisch.
- Behauptungen über den Ist-Zustand der Codebasis müssen aus der Exploration in Schritt 2 stammen, nicht aus Annahmen. Bei Unsicherheit die Unsicherheit benennen.
