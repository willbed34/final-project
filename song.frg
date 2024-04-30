#lang forge
option solver Glucose

-- Signatures define the basic elements
// abstract sig Tone {}

// rule of three
// -note -> chord -> chord progression
// key -> scale

// define the 12 tones
// one sig C, CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B extends Tone {}
// C = 0, CSharp = 1, D = 2, DSharp = 3, E = 4, F = 5, FSharp = 6, G = 7, GSharp = 8, A = 9, ASharp = 10, B = 11

sig Note {
    tone: one Int,
    next: lone Note
}

// sig CMajorScale extends Note {}

sig Chord {
    root, third, fifth: one Note,
    // notesInChord: set Note,
    nextChord: lone Chord
}

// generalize
// sig Scale {
//     notesInScale: set Note
// }

// sig Phrase {
//     chordsInPhrase: pfunc Int -> Chord
// }

one sig RootChord extends Chord {}

pred ValidTone {
    all n: Note | n.tone >= 0 and n.tone < 12 and n.next != n
    // all n: Note | n.next != n.prev
}

pred CMajorScaleValid {
    // C = 0
    // D = 2
    // E = 4
    // F = 5
    // G = 7
    // A = 9
    // B = 11
    all n: Note | {
        n.tone = 0 or n.tone = 2 or n.tone = 4 or n.tone = 5 or n.tone = 7 or n.tone = 9 or n.tone = 11
    }
}

// TODO: ADD MORE SCALES AND CHORDS


pred equalTone[n1: Note, n2: Note] {
    n1.tone = n2.tone
    n1.next = n2.next
}

// TODO: Generalize this to all chords
pred validChord {
    // major chord
    //2 + 1
    // find the min of the two things
    // min(a - b + 1 % 2, b - a + 13 % 2) = 1
    all c: Chord | {
        // remainder[min[add[subtract[c.third.tone, c.root.tone], 1], add[subtract[c.root.tone, c.third.tone], 13]], 2] = 1
        // remainder[min[add[subtract[c.fifth.tone, c.third.tone], 1], add[subtract[c.third.tone, c.fifth.tone], 13]], 2] = 1
        // add[subtract[c.third.tone, c.root.tone], 1] < add[subtract[c.root.tone, c.third.tone], 13] => remainder[add[subtract[c.third.tone, c.root.tone], 1], 2] = 0 else remainder[add[subtract[c.root.tone, c.third.tone], 13], 2] = 0
        // add[subtract[c.fifth.tone, c.third.tone], 1] < add[subtract[c.third.tone, c.fifth.tone], 13] => remainder[add[subtract[c.fifth.tone, c.third.tone], 1], 2] = 0 else remainder[add[subtract[c.third.tone, c.fifth.tone], 13], 2] = 0
        (c.root.tone = 0 => c.third.tone = 4 and c.fifth.tone = 7) and
        (c.root.tone = 2 => c.third.tone = 5 and c.fifth.tone = 9) and
        (c.root.tone = 4 => c.third.tone = 7 and c.fifth.tone = 11) and
        (c.root.tone = 5 => c.third.tone = 9 and c.fifth.tone = 0) and
        (c.root.tone = 7 => c.third.tone = 11 and c.fifth.tone = 2) and
        (c.root.tone = 9 => c.third.tone = 0 and c.fifth.tone = 4) and
        (c.root.tone = 11 => c.third.tone = 2 and c.fifth.tone = 5) and
        no c.fifth.next
        equalTone[c.root.next, c.third] and equalTone[c.third.next, c.fifth]

    }
}

//makes it unsat, unsure why
pred allButOneHaveNext {
    some c: Chord | {
        c.nextChord = none
        all c1: Chord | {
            (c1 != c) => (c1.nextChord != none)
        }
    }
}

// pred validMinorChord[c: MinorChord] {
//     c.root.tone = c.third.tone - 3 and
//     c.third.tone = c.fifth.tone - 4  // Example intervals for a minor chord
// }

// pred validMajorChord[c: Chord] {
//     // c.root.tone = 
//     c.third.tone - c.root.tone < c.root.tone + 12 - c.third.tone => c.third.tone = c.root.tone + 4 else 
//     c.fifth.tone - c.third.tone < c.third.tone + 12 - c.fifth.tone => c.fifth.tone - c.third.tone = 3 else c.third.tone + 12 - c.fifth.tone = 3
// }

pred ValidChordProgression[c1: Chord, c2: Chord] {
    (c1.root.tone = 0 or c1.root.tone = 2 or c1.root.tone = 7)
    c1.root.tone = 0 => c2.root.tone = 7
    c1.root.tone = 2 => c2.root.tone = 7
    c1.root.tone = 7 => c2.root.tone = 0
}

pred ChordProgression {
    all c: Chord | some c.nextChord => ValidChordProgression[c, c.nextChord]  
    // all c: Chord | reachable[c, c.nextChord, nextChord]
}

pred CircularChordProgression {
    all c: Chord | reachable[c, RootChord, nextChord]
}

pred NonRepetitiveProgression {
    all c: Chord | c.nextChord != none => (c != c.nextChord)
}

pred generatePhrase {
    all p: Phrase | {
        p.chordsInPhrase[0] = RootChord and
        p.chordsInPhrase[1] = RootChord.nextChord and
        p.chordsInPhrase[2] = RootChord.nextChord.nextChord and
        p.chordsInPhrase[3] = RootChord.nextChord.nextChord.nextChord and
        no p.chordsInPhrase[4] and
        no p.chordsInPhrase[5] and
        no p.chordsInPhrase[6] and
        no p.chordsInPhrase[7] and
        no p.chordsInPhrase[8] and
        no p.chordsInPhrase[9] and
        no p.chordsInPhrase[10] and
        no p.chordsInPhrase[11] and
        no p.chordsInPhrase[12] and
        no p.chordsInPhrase[13] and
        no p.chordsInPhrase[14] and
        no p.chordsInPhrase[15] and
        no p.chordsInPhrase[-16] and no p.chordsInPhrase[-15] and no p.chordsInPhrase[-14] and no p.chordsInPhrase[-13] and no p.chordsInPhrase[-12] and no p.chordsInPhrase[-11] and no p.chordsInPhrase[-10] and no p.chordsInPhrase[-9] and no p.chordsInPhrase[-8] and no p.chordsInPhrase[-7] and no p.chordsInPhrase[-6] and no p.chordsInPhrase[-5] and no p.chordsInPhrase[-4] and no p.chordsInPhrase[-3] and no p.chordsInPhrase[-2] and no p.chordsInPhrase[-1]
    }
}

pred gernerateMusic {
    CMajorScaleValid
    ValidTone
    // all c: Chord | validMajorChord[c]
    validChord
    ChordProgression
    NonRepetitiveProgression
    // allButOneHaveNext
    // CircularChordProgression // not working anymore because of the needed intermediate steps (define more chord progressions)
    // generatePhrase
}

run {gernerateMusic} for 5 Int, exactly 3 Chord