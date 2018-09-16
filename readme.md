SuperCollider listens for OSC messages from Python on port 10000 for cleaned data values (copx, copy), and for heel and toe pressure from nodejs and triggers corresponding sounds/sonic events.

## Installation
For SuperCollider to find the Able.sc SuperCollider extension, this folder needs to be in the SuperCollider Extensions directory

On windows:
  C:\Users\<user>\AppData\Local\SuperCollider\Extensions
  (if no 'Extensions' library exists, just create a folder in ...\SuperCollider and name it Extensions)

On Mac:
  ~/Library/Application\ Support/SuperCollider/Extensions
  (if no 'Extensions' library exists, just create a folder in ...\SuperCollider and name it Extensions)

Either create an alias in the SuperCollider Extensions directory pointing to this folder, or clone this submodule directly into the SuperCollider Extensions directory:

```
cd ....../SuperCollider/Extensions
git clone https://github.com/Pulse-Lab/ABLE-sound.git
```

## Booting:
```
(
~able = Able(
	motion:\walk,
	sensors:nil,
	initialMelody: Melody.new([60,64,67],Scale.major.degrees+60,mutateEvery:4),
	pythonRecvPort:10000,
	unrealIP:"127.0.0.1",
	unrealPort:8000,
	automaticMotions: false
);
~able.boot()
)
```

(or see ```test-file.scd```)

## OSC tutorial
sc-osc-tutorials.scd has some brief instructions on how to use OSC in SuperCollider (SuperCollider makes OSC really easy and might be useful to anyone debugging OSC-related things in other parts of the project)

## Synths
synths.scd is a growing file of supercollider synthesizers (things we can call to make sound). ./samples is where samples we're using should be installed so the synthesizers can find them.
Samples/sources.txt is a list of where sound files were retrieved from (urls). If you add more sound files please update the sources.txt file so we can cite properly. Also note that if you move any of the files in samples (or any of the project folders) you may need to update synths.scd so that the synthesizers have the correct 'path' to the folders.
