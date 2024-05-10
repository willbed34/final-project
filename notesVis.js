d3 = require("d3");
require("tone");

d3.selectAll("svg > *").remove();

const synth = new tone.PolySynth().toDestination();
const notes = [
  "C4",
  "C#4",
  "D4",
  "D#4",
  "E4",
  "F4",
  "F#4",
  "G4",
  "G#4",
  "A4",
  "A#4",
  "B4",
];


const bottom = 400;
const left = 10;
const w = 15;

function drawStaff() {
  let i;
  for (i = 0; i < 5; i++) {
    let y = bottom - i * w - w;
    d3.select(svg)
      .append("line")
      .attr("x1", left)
      .attr("y1", y)
      .attr("x2", left + 500)
      .attr("y2", y)
      .attr("stroke", "black");
  }
  d3.select(svg)
    .append("text")
    .attr("x", left)
    .attr("y", bottom - 1.5 * w) // Position between the second and third lines from the bottom
    .attr("fill", "black")
    .attr("font-family", "Arial, sans-serif")
    .attr("font-size", "120px") // Adjust size based on your staff
    .text("𝄞");
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

function drawQuarter(x, y) {
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
    .attr("x", x - 18)
    .attr("y", y)
    .attr("fill", "black")
    .attr("font-family", "Arial, sans-serif")
    .attr("font-size", "15px")
    .text("#"); // Use text representation of a sharp symbol
}

function drawNote(note, length, idx) {
  var positionY = 0;
  var positionX = 0;
  var sharp = false;

  if (note != undefined) {
    if (note.pitch.equals(0) | note.pitch.equals(1)) {
      positionY = 0;
      if (note.pitch.equals(1)) {
        sharp = true;
      }
    }
    if (note.pitch.equals(2) | note.pitch.equals(3)) {
      positionY = 1;
      if (note.pitch.equals(3)) {
        sharp = true;
      }
    }
    if (note.pitch.equals(4)) {
      positionY = 2;
    }
    if (note.pitch.equals(5) | note.pitch.equals(6)) {
      positionY = 3;
      if (note.pitch.equals(6)) {
        sharp = true;
      }
    }
    if (note.pitch.equals(7) | note.pitch.equals(8)) {
      positionY = 4;
      if (note.pitch.equals(8)) {
        sharp = true;
      }
    }
    if (note.pitch.equals(9) | note.pitch.equals(10)) {
      positionY = 5;
      if (note.pitch.equals(10)) {
        sharp = true;
      }
    }
    if (note.pitch.equals(11)) {
      positionY = 6;
    }
  }
  if (sharp) {
    drawSharp(left + 50 + idx * 30, bottom - positionY * (w / 2));
  }
  // d3.select(svg)
  // .append("text")
  // .style("fill", "black")
  // .attr("x", 50 + idx * 70 )
  // .attr("y", 50)
  // .text(note.pitch);
  if (length.equals(-6)) {
    drawEigth(left + 50 + idx * 30, bottom - positionY * (w / 2));
  }else if(length.equals(-4)){
      drawQuarter(left + 50 + idx * 30, bottom - positionY * (w / 2));
  }else if (length.equals(0)) {
    drawHalf(left + 50 + idx * 30, bottom - positionY * (w / 2));
  }else if (length.equals(16)) {
    drawFull(left + 50 + idx * 30, bottom - positionY * (w / 2));
  }else if (length.equals(16)) {
    drawFull(left + 50 + idx * 30, bottom - positionY * (w / 2));
  }else{
    drawEigth(left + 50 + idx * 30, bottom - positionY * (w / 2));
  }


}
function drawNotes(chords) {
  chords.forEach((chord, idx) => {
    drawNote(chord.root, chord.length, idx);
    drawNote(chord.third, chord.length, idx);
    drawNote(chord.fifth, chord.length, idx);
    drawNote(chord.seventh, chord.length, idx);
  });
}

function constructVisualization(chords) {
  drawStaff();
  drawNotes(chords);
}

function fam(expr) {
  if (!expr.empty()) return expr.tuples()[0].atoms()[0];
  return "none";
}

function build(Chord) {
  const unOrderedchords = Chord.atoms().map((ltup) => fam(ltup));
  var curChord = unOrderedchords[0];
  var chords = [];
  for (let i = 0; i < unOrderedchords.length; i++) {
    chords.push(curChord);
    curChord = curChord.next;
  }
  // d3.select(svg)
  //   .append("text")
  //   .style("fill", "black")
  //   .attr("x", 70)
  //   .attr("y", 50)
  //   .text(chords);
  constructVisualization(chords);
  playChords(chords);
}

function getNoteFromInt(intValue) {
  if (intValue >= 0 && intValue <= 11) {
    return notes[intValue];
  } else {
    return null;
  }
}

function playChords(chords) {
  const now = tone.now();
  let i;

  // Initialize synth detune (optional)
  synth.set({ detune: -1200 });

  for (i = 0; i < chords.length; i++) {
    // Ensure conversion to integer, then to note name
    const root = getNoteFromInt(parseInt(chords[i].root.pitch.toString()));
    const third = getNoteFromInt(parseInt(chords[i].third.pitch.toString()));
    const fifth = getNoteFromInt(parseInt(chords[i].fifth.pitch.toString()));
    const seventh = getNoteFromInt(
      parseInt(chords[i].seventh.pitch.toString())
    );

    // Filter out invalid note values
    synth.triggerAttackRelease(
      [root, third, fifth, seventh],
      "8n",
      now + i * 0.5
    );

    // Draw the root note for visualization purposes
    d3.select(svg)
      .append("text")
      .style("fill", "black")
      .attr("x", 70 + i * 40)
      .attr("y", 50)
      .text(root || "");
  }
}

build(Chord, Song);
