SuperCollider listens for OSC messages from Python on port 10000 for cleaned data values and triggers corresponding sounds/sonic events.

sc-osc-tutorials.scd has some brief instructions on how to use OSC in SuperCollider (SuperCollider makes OSC really easy and might be useful to anyone debugging OSC-related things in other parts of the project!)

sc-osc-controller.scd contains the OSC receivers that listen for messages and triggers things. (Currently the don't trigger anything but they will soon when have a clear idea of what motions should trigger what sounds!)

synths.scd is a growing file of supercollider synthesizers (things we can call to make sound)

samples/ is a folder containing sound files that the synthesizers in synths.scd use. Samples/sources.txt is a list of where sound files were retrieved from (urls). If you add more sound files please update the sources.txt file so we can cite properly! Also note that if you move any of the files in samples (or any of the project folders) you may need to update synths.scd so that the synthesizers have the correct 'path' to the folders.