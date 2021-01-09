# Assembly-Doodle-Jump

Final project for CSC258 class taken in Fall 2020

A doodle jump game programmed comepletely in MIPs assembly language by Ng Bob Shoaun

## How to run:

1. download Mars assembly simulator from http://courses.missouristate.edu/kenvollmar/mars/
2. clone project
3. open doodlejump.s file using Mars
4. configure bitmap display
    1. in mars go to Tools > Bitmap Display
    2. set Unit width and height to 16
    3. set Display width and height to 512
    4. set Base address for display to 0x10008000 ($gp)
    5. connect to MIPS
5. configure keyboard input simulator
    1. in mars go to Tools > Keyboard and Display MMIO simulator
    2. connect to MIPS
6. Run > Assemble, then Run > Go
7. make sure cursor is focused on KEYBOARD section in the Keyboard and Display MMIO simulator
8. enjoy!

## Controls:

- j - move left
- k - move right
- r - retry
- q - quit