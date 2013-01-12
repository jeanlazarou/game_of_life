Game of Life
============

Game of life presents a network with cells that die, survive or born, depending
on their neighbours. Each cell has a maximum of 8 neighbours. 

Think of the network as a grid of squares, each square beeing a cell.

The way the cells live follows next rules:
- if a cell has less than 2 neighbours it dies
- if a cell has more than 3 neighbours it dies
- if a cell has 3 neighbours cell they generate 1

See [Conway's Game of Life](http://en.wikipedia.org/wiki/Conway's_Game_of_Life), 
[also](http://www.tech.org/~stuart/life/rules.html).

The project
-----------

The implemenation was inspired by episode #13 from Ruby Tapas: Singleton Object 
(see [ http://devblog.avdi.org/2012/10/22/rubytapas-episode-13-singleton-objects/](http://devblog.avdi.org/2012/10/22/rubytapas-episode-13-singleton-objects/).

It starts with a random network, then applies the above rules.

As the network may end in cycling states (a network that does not change anymore
or the same states come over and over), the implementation uses a history of 
last states to detect such cases and restart a new random network.

## Output

The output is a simple Text UI (terminal output) using the cursus library.

As it only runs on Unix-like systems, I added a basic implementation of the 
curses library for jRuby using the Java/Swing GUI layer, so that it can run
on all systems. The curses support is limited to make the game run and is 
not 'curses' compatible.

## Running the game

Run the application with:

```bash
ruby game_of_life.rb
```
  
With jRuby:

```bash
jruby --1.9 -Ilib game_of_life.rb
```

## Implementation

The implementation contains a class named `NetBuilder` that helps
creating networks (see the test in `tests.rb`).

The builder expects a block like:

    net = NetBuilder.build {
       head '  0 1 2 3 4 5 6 7 8 9'
       line '0 . . . . . . . . . .'
       line '1 . . . . . . . . . .'
       line '2 . . . . . . . . . .'
       line '3 . . # # . . . . . .'
       line '4 . . . . . . # . . .'
       line '5 . . . . . # . . . .'
       line '6 . . . . # . . . . .'
       line '7 . . . . . . . . . .'
       line '8 . . . . . . . . . .'
       line '9 . . . . . . . . . #'
    }

## "game_of_life.rb" script usage

  Usage: game_of_life.rb [options]

  Where options include:
      -w, --width w                    Width for the board width (defaults to 20)
      -h, --height h                   Height for the board height (defaults to 20)
      -r, --rate sec                   Next generation rate (in seconds, can be a float)
                                       (defaults to 2)
      -n, --no-cycle-detection         Disable cycle detection and network restart
                                       (defaults to 'enabled')
      -s, --shape file                 A file containing a network shape as startup network
                                       Using the network builder.
      -?, --help                       Show this message

A you can see the script can start with predefined shapes (see samples in
the _shapes_ directory) using the `shape` option.

See [conwaylie site ](http://www.conwaylife.com/wiki/List_of_common_oscillators) for
other shapes (I created the ones available after their list).

## Note

Unfortunately, both RMI 1.9.2 and 1.9.3 did not include 'curses' after
installing them with rvm, I managed to make it work by copying the 
'curses.so' from 1.9.1 to 'lib/ruby/1.9.1/i686-linux'.

- Jean Lazarou
