d3 = require("d3");
require("tone");

d3.selectAll("svg > *").remove();

const chorus = new tone.Chorus(2, 2.5, 0.5).start().toDestination();

// Configure the PolySynth with a custom Synth
const synth = new tone.PolySynth().toDestination(); // Chain the effects and connect to the destination

const notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

const position = [0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 6];

const isSharp = [
  false,
  true,
  false,
  true,
  false,
  false,
  true,
  false,
  true,
  false,
  true,
  false,
];

const bottom = 400;
const top = 300;
const left = 20;
const right = 500;
const w = 15;

function drawStaff() {
  let i;
  for (i = 0; i < 5; i++) {
    let yB = bottom - i * w - w;
    let yT = top - i * w - w;
    d3.select(svg)
      .append("line")
      .attr("x1", left)
      .attr("y1", yB)
      .attr("x2", left + right)
      .attr("y2", yB)
      .attr("stroke", "black");

    d3.select(svg)
      .append("line")
      .attr("x1", left)
      .attr("y1", yT)
      .attr("x2", left + right)
      .attr("y2", yT)
      .attr("stroke", "black");
  }
  d3.select(svg)
    .append("text")
    .attr("x", left)
    .attr("y", top) // Position between the second and third lines from the bottom
    .attr("fill", "black")
    .attr("font-family", "Arial, sans-serif")
    .attr("font-size", "120px") // Adjust size based on your staff
    .text("𝄞");
  d3.select(svg)
    .append("text")
    .attr("x", left)
    .attr("y", bottom - 1.5 * w) // Position between the second and third lines from the bottom
    .attr("fill", "black")
    .attr("font-family", "Arial, sans-serif")
    .attr("font-size", "80px") // Adjust size based on your staff
    .text("𝄢");
  d3.select(svg)
    .append("line")
    .attr("x1", left)
    .attr("y1", top - w * 5)
    .attr("x2", left)
    .attr("y2", bottom - w)
    .attr("stroke", "black");
  d3.select(svg)
    .append("line")
    .attr("x1", left + right)
    .attr("y1", top - w * 5)
    .attr("x2", left + right)
    .attr("y2", bottom - w)
    .attr("stroke", "black");
  d3.select(svg)
    .append("line")
    .attr("x1", left + right - 5)
    .attr("y1", top - w * 5)
    .attr("x2", left + right - 5)
    .attr("y2", bottom - w)
    .attr("stroke", "black");
}

function drawEigth(x, y) {
  // Draw notehead (ellipse)
  d3.select(svg)
    .append("ellipse")
    .attr("cx", x)
    .attr("cy", y)
    .attr("rx", 6)
    .attr("ry", 4)
    .attr("fill", "black")
    .attr("transform", `rotate(-15, ${x}, ${y})`);

  // Draw stem (line)
  d3.select(svg)
    .append("line")
    .attr("x1", x + 5)
    .attr("y1", y)
    .attr("x2", x + 8)
    .attr("y2", y - 30) // Stem length upwards from the notehead
    .attr("stroke", "black")
    .attr("stroke-width", 2);

  d3.select(svg)
    .append("path")
    .attr(
      "d",
      `M ${x + 8}, ${y - 30} C ${x + 12}, ${y - 35} ${x + 10}, ${y - 45} ${
        x + 8
      }, ${y - 40}`
    )
    .attr("stroke", "black")
    .attr("stroke-width", 2)
    .attr("fill", "none");
}

function drawQuarter(x, positionY, chord) {
  var stemY = -30;
  var stemX = 5;
  var y = top - positionY * (w / 2);

  if (chord) {
    stemY = 30;
    stemX = -5;
    y = bottom - 2.5 * w - positionY * (w / 2);
  }

  if (positionY < 2) {
    var stemY = -30;
    var stemX = 5;
  }

  var sharp = isSharp[positionY.toString()];

  if (sharp) {
    drawSharp(x, y);
  }

  // Draw notehead (ellipse)
  d3.select(svg)
    .append("ellipse")
    .attr("cx", x)
    .attr("cy", y)
    .attr("rx", 6)
    .attr("ry", 4)
    .attr("fill", "black")
    .attr("transform", `rotate(-15, ${x}, ${y})`);

  // Draw stem (line)
  d3.select(svg)
    .append("line")
    .attr("x1", x + stemX)
    .attr("y1", y)
    .attr("x2", x + stemX)
    .attr("y2", y + stemY) // Stem length upwards from the notehead
    .attr("stroke", "black")
    .attr("stroke-width", 2);
}

function drawHalf(x, y) {
  // Draw notehead (ellipse)
  d3.select(svg)
    .append("ellipse")
    .attr("cx", x)
    .attr("cy", y)
    .attr("rx", 6)
    .attr("ry", 4)
    .attr("fill", "black")
    .attr("stroke", "transparent")
    .attr("stroke-width", 3)
    .attr("transform", `rotate(-15, ${x}, ${y})`);

  // Draw stem (line)
  d3.select(svg)
    .append("line")
    .attr("x1", x + 5)
    .attr("y1", y)
    .attr("x2", x + 8)
    .attr("y2", y - 30) // Stem length upwards from the notehead
    .attr("stroke", "black")
    .attr("stroke-width", 2);
}

function drawFull(x, y) {
  // Draw notehead (ellipse)
  d3.select(svg)
    .append("ellipse")
    .attr("cx", x)
    .attr("cy", y)
    .attr("rx", 6)
    .attr("ry", 4)
    .attr("fill", "transparent")
    .attr("stroke", "black")
    .attr("stroke-width", 3)
    .attr("transform", `rotate(-15, ${x}, ${y})`);
}

function drawSharp(x, y) {
  d3.select(svg)
    .append("text")
    .attr("x", x - 14)
    .attr("y", y + 5)
    .attr("fill", "black")
    .attr("font-family", "Arial, sans-serif")
    .attr("font-size", "15px")
    .text("#"); // Use text representation of a sharp symbol
}

function drawNote(note, idx, isChord) {
  var positionY = position[note.pitch.toString()];
  drawQuarter(left + 50 + idx * 30, positionY, isChord);
  // if (length.equals(-6)) {
  //   drawEigth(left + 50 + idx * 30, bottom - positionY * (w / 2), isBass);
  // }else if(length.equals(-4)){
  //     drawQuarter(left + 50 + idx * 30, bottom - positionY * (w / 2), isBass);
  // }else if (length.equals(0)) {
  //   drawHalf(left + 50 + idx * 30, bottom - positionY * (w / 2), isBass);
  // }else if (length.equals(16)) {
  //   drawFull(left + 50 + idx * 30, bottom - positionY * (w / 2), isBass);
  // }else if (length.equals(16)) {
  //   drawFull(left + 50 + idx * 30, bottom - positionY * (w / 2), isBass);
  // }else{

  // }
}

function drawNotes(chords, melody) {
  chords.forEach((chord, idx) => {
    if (!chord.root.empty()) {
      drawNote(chord.root, idx, true);
    }

    if (!chord.third.empty()) {
      drawNote(chord.third, idx, true);
    }

    if (!chord.fifth.empty()) {
      drawNote(chord.fifth, idx, true);
    }

    if (!chord.seventh.empty()) {
      drawNote(chord.seventh, idx, true);
    }
  });

  melody.forEach((note, idx) => {
    if (!note.empty()) {
      drawNote(note, idx, false);
    }
  });
}

function constructVisualization(chords, melody) {
  drawStaff();
  drawNotes(chords, melody);
}

function fam(expr) {
  if (!expr.empty()) return expr.tuples()[0].atoms()[0];
  return "none";
}

function build(Chord, Melody) {
  const chord = Chord.atoms().map((ltup) => fam(ltup))[0];
  const m = Melody.atoms().map((ltup) => fam(ltup))[0];
  var curChord = chord;
  var chords = [];
  var melody = [];
  for (let i = 0; i < 10; i++) {
    melody.push(m.melodyNotes[i]);
    chords.push(chord.songChords[i]);
  }
  constructVisualization(chords, melody);
  playChords(chords, melody);
}

function getNoteFromInt(intValue) {
  if (intValue >= 0 && intValue <= 11) {
    return notes[intValue];
  } else {
    return null;
  }
}

function playChords(chords, melody) {
  const now = tone.now();
  let i;
  synth.set({ detune: -1200 });

  for (i = 0; i < chords.length; i++) {
    var root;
    var third;
    var fifth;
    var seventh;
    var melodyNote;
    if (!chords[i].root.empty()) {
      root = getNoteFromInt(chords[i].root.pitch.toString()) + "3";
    }
    if (!chords[i].third.empty()) {
      third = getNoteFromInt(chords[i].third.pitch.toString()) + "3";
    }
    if (!chords[i].fifth.empty()) {
      fifth = getNoteFromInt(chords[i].fifth.pitch.toString()) + "3";
    }
    if (!chords[i].seventh.empty()) {
      seventh = getNoteFromInt(chords[i].seventh.pitch.toString()) + "3";
    }
    if (!melody[i].pitch.empty()) {
      melodyNote = getNoteFromInt(melody[i].pitch.toString()) + "4";
    }

    d3.select(svg)
      .append("text")
      .style("fill", "black")
      .attr("x", 70 + i * 40)
      .attr("y", 50)
      .text(root);
    synth.triggerAttackRelease(
      [root, third, fifth, seventh, melodyNote],
      "8n",
      now + i * 0.5
    );
  }
}

build(Song, Melody);
